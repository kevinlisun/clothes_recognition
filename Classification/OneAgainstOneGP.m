function [ predict_label accuracy ] = OneAgainstOneGP( train_inst, train_label, test_inst, test_label, opt )


    labels = unique(train_label);
    labelNum = length(labels);
    
    Model = [];
    for i = 1:labelNum
        for j = i+1:labelNum
            Inx = [ find(train_label==labels(i)); find(train_label==labels(j)) ];
            GPmodel = gptrain( train_inst(Inx,:), train_label(Inx) );         
            Model = [ Model; GPmodel ];
        end
    end
    
    prediction = zeros( length(test_label), length(Model) );
    
    for i = 1:length(Model)
       GPmodel = Model(i);
       [ prediction(:,i) prob ] = gppredict( test_inst, test_label, GPmodel );
    end
    

   predict_label = mode(prediction,2);
   
   accuracy = sum(predict_label==test_label)/length(test_label);
   
            
      
        
    
    