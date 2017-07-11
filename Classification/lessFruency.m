function [ predict ] = lessFruency( prediction )
    
    labels = unique(prediction);
    predict = zeros(size(prediction,1),1);
    
    for i = 1:size(prediction,1)
        temp = prediction(i,:);
        
        lessF = realmax;
        for j = 1:length(labels)
            tempF = sum(temp==labels(j));
            if lessF > tempF
                lessF = tempF;
                tempL = labels(j);
            end
        end
        predict(i) = tempL;
    end
            
        