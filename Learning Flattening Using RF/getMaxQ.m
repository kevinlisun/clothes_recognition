function [ maxQ, maxQaction isValid ] = getMaxQ( state_tt, normVec, model, approach )

    seg = pi/180;
    action = (-pi:seg:pi)';
    action(1) = [];
    
    % cos(action), sin(action)
    input = [ repmat(state_tt,[length(action),1]), cos(action), sin(action) ];
    
    input = input./repmat(normVec,[size(input,1),1]);
    input(:,1:end-2) = input(:,1:end-2)*2 - 1;
    
    if strcmp(approach,'NN')
        Q = ( model( input','useParallel', 'yes', 'useGPU', 'yes' ) )';
    elseif strcmp(approach,'GP')
        
        % covfuncF = {@covFITC, {covfunc}, u, hyp, model.INPUT, input };
        [m s2] = gp(model.hyp, @infFITC, model.meanfunc, model.covfuncF, model.likfunc, model.INPUT, model.TARGET, input);
       
        Q = m;
        
        figure(1); plot(1:360,m,'b*');hold on;
    end
    
    
    [ maxQ b] = max(Q);
    
    maxQaction = action(b);
    
    if max(Q) - min(Q) < 0.1
        isValid = 0;
    else
        isValid = 1;
    end