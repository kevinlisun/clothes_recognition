function [ predict_label accuracy ] = OneAgainstOneSVM( train_inst, train_label, test_inst, test_label, opt )


    labels = unique(train_label);
    labelNum = length(labels);
    
    Model = [];
    for i = 1:labelNum
        for j = i+1:labelNum
            Inx = [ find(train_label==labels(i)); find(train_label==labels(j)) ];
            model.SVMStruct = libsvmtrain( train_label(Inx), train_inst(Inx,:), opt );   
            model.label = unique( train_label(Inx) );
            Model = [ Model; model ];
        end
    end
    
    prediction = zeros( length(test_label), length(Model) );
    
    for i = 1:length(Model)
       SVMStruct = Model(i).SVMStruct;
       [ p, acc, dec_values] = libsvmpredict( test_label, test_inst, SVMStruct);
       label = Model(i).label;
       [ notp ] = getNotP( p, label );
       prediction(:,i) = notp;
    end
    
    [ predict_label ] = lessFruency( prediction );

    accuracy = sum(predict_label==test_label)/length(test_label);
   
            
      
        
    
    