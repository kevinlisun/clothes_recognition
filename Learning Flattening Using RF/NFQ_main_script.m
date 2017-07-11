warning off
clear all
close all
clc


addpath(fullfile(pwd,'FeatureExtraction/BSplineFitting'));
addpath(fullfile(pwd,'FeatureExtraction/SurfaceFeature'));
addpath(fullfile(pwd,'Simulator'));
addpath(fullfile(pwd,'GPML'));

startup

%% experiment setting
% the file is start with date to distinguish
flile_header = '2014-06-20';
%create firectory
dataset_dir = ['/home/kevin/Desktop/',flile_header];

% n_experiment is the number of flattening experiments, n_iteration is the
% number of flattening iteration in each experiment
n_experiment = 20;
n_interation = 10;
n_NFQ = 100;% %     if i_nfq == 1
% %         figure;
% %         hold on
% %     else
% %         net_t = MODEL{i_nfq-1};
% %         net_tt = MODEL{i_nfq};
% %         
% %         DIFF(i_nfq-1) = sqrt(sum((net_t(INPUT','useParallel', 'yes', 'useGPU', 'yes')-net_tt(INPUT','useParallel', 'yes', 'useGPU', 'yes')).^2));
% %     end

rate = 0.5;
approach = 'GP'

MODEL = cell(n_NFQ,1);
MAXQAction = [];
ACTION = [];% %     if i_nfq == 1
% %         figure;
% %         hold on
% %     else
% %         net_t = MODEL{i_nfq-1};
% %         net_tt = MODEL{i_nfq};
% %         
% %         DIFF(i_nfq-1) = sqrt(sum((net_t(INPUT','useParallel', 'yes', 'useGPU', 'yes')-net_tt(INPUT','useParallel', 'yes', 'useGPU', 'yes')).^2));
% %     end

DIFF = zeros(n_NFQ-1,1);


%% main loop

% initialize neural network
net = fitnet([10,5]);

validMAt = ones(n_experiment,n_interation-1);

for i_nfq = 1:n_NFQ
    
    disp(['start learning of NFQ ', num2str(i_nfq), ' ...']);
    
    INPUT = [];
    TARGET = [];
    for exp_i = 1:n_experiment
        
        disp(['start learning of exp ', num2str(exp_i), ' ...']);
        
        % feature extraction
        for iter_i = 1:n_interation-1
            current_dir = [dataset_dir,'/exp_',num2str(exp_i)];
            
            %%
            
            % read stat4e(t) from the disk
            load([current_dir,'/bsp_code_iter',num2str(iter_i),'.mat']);
%             load([current_dir,'/bsp_si_code_iter',num2str(iter_i),'.mat']);
            load([current_dir,'/force_iter',num2str(iter_i),'.mat']);
            load([current_dir,'/reward_iter',num2str(iter_i),'.mat']);
            
            state_t = bsp_code;
            clear bsp_code
            % read state(t+1)
            load([current_dir,'/bsp_code_iter',num2str(iter_i+1),'.mat']);
            state_tt = bsp_code;
            
            % use log mrand_weightax as reward
            reward = 1/(1+exp(-reward/10e2));
            
            % compute the angle of force
            vecA = force.force_vector(1,[1,3]);
            vecB = [ 1, 0 ];
% %             action = acos(dot(vecA,vecB));
% %             if vecA(2) < 0
% %                 action = -action;
% %             end
            
           %  use the force vector as the action
            action = force.force_vector(1,[1,3]);
            
            input = [ state_t, action ];
            
            if i_nfq == 1
                target = reward;
            elseif validMAt(exp_i,iter_i) == 1
                % Q-Learning
                [ maxQvalue maxQaction isValid ] = getMaxQ( state_tt, normVec, MODEL{i_nfq-1}, approach );
                
                MAXQAction = [ MAXQAction; maxQaction ];
                target = reward + rate*maxQvalue;
                
                %update valid Mat
                if i_nfq >= 2
                    validMAt(exp_i,iter_i) = isValid;
                end
                
            end
            
            if validMAt(exp_i,iter_i) == 1
                INPUT = [ INPUT; input ];
                TARGET = [ TARGET; target ];
            end
            
            clear bsp_descriptors si_descriptors bsp_code bsp_si_code state reward action input target;
            
        end
        %%
    end
    % train NFQ offlinerand_weight
    if i_nfq == 1
        normVec = max(INPUT,[],1);
        % %         normVec(1,end) = pi;
        normVec(1,end-1:end) = 1;
    end
    
    % normlize all colums to [ -1 1 ]
    INPUT = INPUT./repmat(normVec,[size(INPUT,1),1]);
    INPUT(:,1:end-2) = INPUT(:,1:end-2)*2 - 1;
    
    if strcmp(approach,'linear')
        % train linear regression
        MODEL{i_nfq} = regress(TARGET,INPUT);
    elseif strcmp(approach,'NN')
        % train neral networks
        MODEL{i_nfq} = train( net, INPUT', TARGET', 'useParallel', 'yes', 'useGPU', 'yes' );
    elseif strcmp(approach,'GP')
        
        meanfunc = {@meanSum, {@meanLinear, @meanConst}};hyp.mean = [0.5; 1];
        covfunc = @covSEiso;ell = 1/4; sf = 1; hyp.cov = log([ell; sf]);
        likfunc = @likGauss;sn = 0.1; hyp.lik = log(sn);

        n = min(size(INPUT,1),3000);
 
        nu = fix(n/2); iu = randperm(n); iu = iu(1:nu); u = INPUT(iu,:);t = TARGET(iu,:);
        
        hyp.mean = zeros(103,1); 
        ell = 1/4; sf = 1; hyp.cov = log([ell; sf]);
        hyp.lik = log(0.1);
        hyp = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, u, t );

        covfuncF = {@covFITC, {covfunc}, u};
        
        
        model.INPUT = INPUT;
        model.TARGET = TARGET;
        model.meanfunc = meanfunc;
        model.covfunc = covfunc;
        model.likfunc = likfunc;
        
        model.covfuncF = covfuncF;
        model.hyp = hyp;
        
        MODEL{i_nfq} = model;
    end
    close all;
% %     if i_nfq == 1
% %         figure;
% %         hold on
% %     else
% %         net_t = MODEL{i_nfq-1};
% %         net_tt = MODEL{i_nfq};
% %         
% %         DIFF(i_nfq-1) = sqrt(sum((net_t(INPUT','useParallel', 'yes', 'useGPU', 'yes')-net_tt(INPUT','useParallel', 'yes', 'useGPU', 'yes')).^2));
% %     end

end

figure;
plot( 1:length(DIFF), DIFF, '-b*' );
figure;
hist(MAXQAction);

model.NFQ = MODEL{i_nfq};
model.normVec = normVec;
save([dataset_dir,'/model/NFQ.mat'],'model');

%% learn code book using k-means clustering

