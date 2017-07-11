function [ model ] = trainClassifer( Features, Classes, para, opt )
    
    instances = [];
    
    if strcmp(opt,'coarse')
        if para.coarse.CC.enable
            instances = [ instances, Features.coarse.CC_Feat ];
        end
        if para.coarse.BSD.enable
            instances = [ instances, Features.coarse.BSD_Feat ];
        end
        if para.coarse.SI.enable
            instances = [ instances, Features.coarse.SI_Feat ];
        end
        if para.coarse.HoG.enable
            instances = [ instances, Features.coarse.HoG_Feat ];
        end
        if para.coarse.Topo.enable
            instances = [ instances, Features.coarse.Topo_Feat ];
        end
        if para.coarse.spinImg.enable
            instances = [ instances, Features.coarse.spinImg_Feat ];
        end
        classes = Classes.coarse_class;
        classes = double(classes);
    end
    
    if strcmp(opt,'fine')
        if para.fine.CC.enable
            instances = [ instances, Features.fine.CC_Feat ];
        end
        if para.fine.BSD.enable
            instances = [ instances, Features.fine.BSD_Feat ];
        end
        if para.fine.SI.enable
            instances = [ instances, Features.fine.SI_Feat ];
        end
        if para.fine.HoG.enable
            instances = [ instances, Features.fine.HoG_Feat ];
        end
        if para.fine.Topo.enable
            instances = [ instances, Features.fine.Topo_Feat ];
        end
        if para.fine.spinImg.enable
            instances = [ instances, Features.coarse.spinImg_Feat ];
        end
        classes = Classes.fine_class;
        classes = double(classes);
    end
    
    instances = double(instances);
    % %     maxInst = max(instances);
    % %     minInst = min(instances);
    % %     instances = (instances - repmat(minInst,[size(instances,1),1])) ./ repmat(maxInst,[size(instances,1),1]);
    % %     
    % % % %     testInst = instances(1:round(0.5*size(instances,1)),:);
    % % % %     trainInst = instances(round(0.5*size(instances,1)):end,:);
    % % % %     testLabel = classes(1:round(0.5*size(classes,1)),:);
    % % % %     trainLabel = classes(round(0.5*size(classes,1)):end,:);
    % % % %     model = svmtrain( classes, instances, '-c 1 -g 0.07 -t 0 -h 0' );
    % % % %     [predict_label, accuracy, dec_values] = svmpredict( testLabel, testInst, model);

    if strcmp(opt,'fine')
        if strcmp(para.basic.fineClassifier,'SVM')
            svm_opt = para.train.fine.SVM.opt;
            model = svmtrain( classes, instances, svm_opt );
            
            if para.train.CV.enabe
                [ result ] = x_fold_CV( instances, classes, para, 'SVM', svm_opt );
                disp(['The average accuracy of ',num2str(para.train.CV.xfold),'-fold Cross Validification is: ',num2str(result.accuracy),'.']);
                disp(['The average positive accuracy of ',num2str(para.train.CV.xfold),'-fold Cross Validification is: ',num2str(result.tp),'.']);
                disp(['The average negative accuracy of ',num2str(para.train.CV.xfold),'-fold Cross Validification is: ',num2str(result.tf),'.']);
            end
        end
        
        if strcmp(para.basic.fineClassifier,'GP')
            [ instances classes norm ] = prepareData( instances, classes );
            
            disp('GP parameters:')
            disp('meanfunc = @meanConst; hyp.mean = 0;')
            meanfunc = @meanConst; hyp.mean = 0;
            disp('covfunc = @covSEard;   hyp.cov = log([1 1 1]);')
            covfunc = @covSEard; ell = 1.0; sf = 1.0;  hyp.cov = log([repmat(ell, 1, size(instances,2)), sf]);
            disp('likfunc = @likErf;')
            likfunc = @likErf;
            disp('training... ')
            
            disp('hyp = minimize(hyp, @gp, -40, @infEP, meanfunc, covfunc, likfunc, x, y);')
            hyp = minimize(hyp, @gp, 1, @infEP, meanfunc, covfunc, likfunc, instances, classes);            
           
            model.meanfunc = meanfunc;
            model.covfunc = covfunc;
            model.likfunc = likfunc;
            model.hyp = hyp;
            model.norm = norm;
            model.instances = instances;
            model.classes = classes;
            
            if para.train.CV.enabe
                [ result ] = x_fold_CV( instances, classes, para, 'GP', model );
                disp(['The average accuracy of ',num2str(para.train.CV.xfold),'-fold Cross Validification is: ',num2str(result.accuracy),'.']);
                disp(['The average positive accuracy of ',num2str(para.train.CV.xfold),'-fold Cross Validification is: ',num2str(result.tp),'.']);
                disp(['The average negative accuracy of ',num2str(para.train.CV.xfold),'-fold Cross Validification is: ',num2str(result.tf),'.']);
            end
        end
         if strcmp(para.basic.fineClassifier,'GP-fast')
            [ instances classes norm ] = prepareData( instances, classes );
            
            disp('GP parameters:')
            disp('meanfunc = @meanConst; hyp.mean = 0;')
            meanfunc = @meanConst; hyp.mean = 0;
            disp('covfunc = @covSEard;   hyp.cov = log([1 1 1]);')
            covfunc = @covSEard; ell = 1.0; sf = 1.0;  hyp.cov = log([repmat(ell, 1, size(instances,2)), sf]);
            disp('likfunc = @likErf;')
            likfunc = @likErf;
            disp('training... ')
             
% %             [u1,u2] = meshgrid(linspace(-2,2,5)); u = [u1(:),u2(:)]; clear u1; clear u2
            u = linspace(-1,1,500)'; u = repmat(u,[1 size(instances,2)]);
            covfuncF = {@covFITC, {covfunc}, u};
            inffunc = @infFITC_EP;                       % @infFITC_EP also @infFITC_Laplace is possible
            hyp = minimize(hyp, @gp, 1, inffunc, meanfunc, covfuncF, likfunc, instances, classes);
               
            model.inffunc =inffunc;
            model.meanfunc = meanfunc;
            model.covfuncF = covfuncF;
            model.likfunc = likfunc;
            model.hyp = hyp;
            model.norm = norm;
            model.instances = instances;
            model.classes = classes;
            
            if para.train.CV.enabe
                [ result ] = x_fold_CV( instances, classes, para, 'GP-fast', model );
                disp(['The average accuracy of ',num2str(para.train.CV.xfold),'-fold Cross Validification is: ',num2str(result.accuracy),'.']);
                disp(['The average positive accuracy of ',num2str(para.train.CV.xfold),'-fold Cross Validification is: ',num2str(result.tp),'.']);
                disp(['The average negative accuracy of ',num2str(para.train.CV.xfold),'-fold Cross Validification is: ',num2str(result.tf),'.']);
            end
        end

    end
    if strcmp(opt,'coarse')
        svm_opt = para.train.coarse.SVM.opt;
        model = svmtrain( classes, instances, svm_opt );
        
        if para.train.CV.enabe
            [ result ] = x_fold_CV( instances, classes, para, 'SVM', svm_opt );
            disp(['The average accuracy of ',num2str(para.train.CV.xfold),'-fold Cross Validification is: ',num2str(result.accuracy),'.']);
            disp(['The average positive accuracy of ',num2str(para.train.CV.xfold),'-fold Cross Validification is: ',num2str(result.tp),'.']);
            disp(['The average negative accuracy of ',num2str(para.train.CV.xfold),'-fold Cross Validification is: ',num2str(result.tf),'.']);     
        end
    end
    

    

    

