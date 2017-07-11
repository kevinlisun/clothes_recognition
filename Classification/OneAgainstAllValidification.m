function [ result ] = OneAgainstAllValidification( Data, Label, ClothesID, classifier, opt )

clothes = unique(ClothesID);

labelNum = length(clothes);

Accuracy = zeros(1,labelNum);

Test_Label = [];
Predict_Label = [];

for i = 1:labelNum
    clothes_i = clothes(i);
    
    testIndex = find(ClothesID==clothes_i);
    trainIndex = find(ClothesID~=clothes_i);
    
    if strcmp(classifier,'SVM-1vsAll')
        model = libsvmtrain( Label(trainIndex), Data(trainIndex,:), opt );
        [predict_label, accuracy, dec_values] = libsvmpredict( Label(testIndex), Data(testIndex,:), model);
    end
    if strcmp(classifier,'SVM-1vs1')
        [ predict_label accuracy ] = OneAgainstOneSVM( Data(trainIndex,:), Label(trainIndex), Data(testIndex,:), Label(testIndex), opt );
    end
    if strcmp(classifier,'GP-1vs1')
        [ predict_label accuracy ] = OneAgainstOneGP( Data(trainIndex,:), Label(trainIndex), Data(testIndex,:), Label(testIndex), opt );
    end
    if strcmp(classifier,'kNN')
        [ predict_label, accuracy ] = kNNClassifer( Data(trainIndex,:), Label(trainIndex), Data(testIndex,:), Label(testIndex) );
    end
    if strcmp(classifier,'RF')
        model = classRF_train( Data(trainIndex,:), Label(trainIndex), opt.treeNum, opt.mtry );
        predict_label = classRF_predict( Data(testIndex,:), model );
        test_label = Label(testIndex);
        accuracy = sum(predict_label==test_label)/length(test_label);
    end
    if strcmp(classifier,'multiGP')
        %Randomly initialise the covariance function hyperparameter values
        dim = size(Data,2);
        theta = rand(1,dim);
        
        %Some arguments to be passed to the main script
        theta_estimate = 1;             % Turn - on hyper-parameter inference
        Nos_Its = 100;                   % Maximum number of variational EM steps
        Kernel_Type = 'innerprod';          % Covariance function type for example 'invsin' 'gauss' 'innerprod'
        Poly_Kernel_Power = 1;          % Parameter value if using Polynomial kernel
        Thresh = 1e-4;                  % Iteration threshold on the marginal likelihood
        
        fig = figure('name','multi-class Gaussian Processing');
        %Main script
        [ predict_label, TE, PL, LB ] = VarMultProbRegGP(Data(trainIndex,:), Label(trainIndex), Data(testIndex,:), Label(testIndex),...
            theta, theta_estimate, Nos_Its, Kernel_Type, Poly_Kernel_Power, Thresh );
        test_label = Label(testIndex);
        accuracy = sum(predict_label==test_label)/length(test_label);
        [ confMax ] = getConfusionMatrix( test_label, predict_label, labelNum );
        figname= [ 'figure_iter',num2str(i) ];
        print('-dpng','-r0',figname);
        close(fig);
    end
    
    test_label = Label(testIndex);
    Test_Label = [ Test_Label; test_label ];
    Predict_Label = [ Predict_Label; predict_label ];
    
    Accuracy(i) =  accuracy(1);
end

accuracy = mean(Accuracy);
[ confMat ] = getConfusionMatrix( Test_Label, Predict_Label, 4 );

result.accuracy = accuracy;
result.Accuracy = Accuracy;
result.confMat = confMat;

    