function [ result ] = LeaveOneOutValidification( Data, Label, ClothesID, classifier, para )

clothes = unique(ClothesID);

labelNum = length(clothes);

Test_Label = [];
Predict_Label = [];

Accuracy = zeros(1,labelNum);

for i = 1:labelNum
    clothes_i = clothes(i);
    
    testIndex = find(ClothesID==clothes_i);
    trainIndex = find(ClothesID~=clothes_i);
    
    if strcmp(classifier, 'myGP')
        % The multi-Class Laplace Gaussian Process Classification
        training_inst = Data(trainIndex,:);
        training_label = Label(trainIndex);
        testing_inst = Data(testIndex,:);
        testing_label = Label(testIndex);
        
        if para.isnorm
            [ training_inst norm_obj ] = NormData(training_inst);
            testing_inst = NormData(testing_inst, norm_obj);
        end
        
% %         [ hyp ] = modelSelection(para, training_inst, training_label);
        hyp = 0.1;
        % estimate the posterior probility of p(f|X,Y)
        
        [ K ] = covMultiClass(hyp, para, training_inst, []);
        [ model ] = LaplaceApproximation(hyp, para, K, training_inst, training_label);
        %[ model ] = multiClassLaplaceApproximation_classic(training_inst, training_label, para);
        % predictin
        [ predict_label prob fm ] = predictGPC_classic(hyp, para, training_inst, training_label, model, testing_inst);
        %[ predict_label prob fm ] = predictGPC_classic(training_inst, training_label, model, testing_inst, para);
    end
    
    if strcmp(classifier,'SVM')
        training_inst = Data(trainIndex,:);
        training_label = Label(trainIndex);
        testing_inst = Data(testIndex,:);        
        testing_label = Label(testIndex);
        model = libsvmtrain( training_label, training_inst, para.opt );
        [predict_label, accuracy, dec_values] = libsvmpredict(testing_label, testing_inst, model);
    end
    
    accuracy = sum(predict_label == testing_label) / length(testing_label);
            
    test_label = Label(testIndex);
    Test_Label = [ Test_Label; test_label ];
    Predict_Label = [ Predict_Label; predict_label ];
    
    Accuracy(i) =  accuracy(1);
end

accuracy = mean(Accuracy);
[ confMat ] = getConfusionMatrix(Test_Label, Predict_Label, 4);

if para.flag
    figure('name','The confusion matrix');
    c = length(unique(Test_Label));
    [ Test_Label ] = label2binary(Test_Label, c, 'mat');
    [ Predict_Label ] = label2binary(Predict_Label, c, 'mat');
    plotconfusion(Test_Label', Predict_Label');
end

result.accuracy = accuracy;
result.Accuracy = Accuracy;
result.confMat = confMat;

    