function [ predict_label, accuracy ] = kNNClassifer( train_inst, train_label, test_inst, test_label )
    
    k = 5;

    [ distanceMat ] = ComputeDistance( test_inst, train_inst );
    predict_label = zeros(size(test_label));
    
    for i = 1:size(test_inst,1)
        temp = distanceMat( i, : );
        [ a b ] = sort(temp,'ascend');
        
        knn = b(1:k);
        knn_labels = train_label(knn);
        label = unique(knn_labels);
        
        num_max = 0;
        for j = 1:length(label)
            if sum(knn_labels==label(j)) > num_max
                num_max = sum(knn_labels==label(j));
                predict_label(i,1) = label(j);
            end
        end
    end
    
    accuracy = sum(predict_label==test_label)/length(test_label);
        
        

