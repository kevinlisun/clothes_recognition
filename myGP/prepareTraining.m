function [inst, label] = prepareTraining(inst, label)

    [a b] = sort(label);
    
    label = a;  
    inst = inst(b,:);
    
    % use standard labels instead of original labels
    origlabel = sort(unique(label));
    stalabel = label;
    labelNum = length(origlabel);
    
    if labelNum == 2
        newlabel = -1:1;
    else
        newlabel = 1:labelNum;
    end
    
    for i=1:length(origlabel)
        stalabel(find(label==origlabel(i)))=Inf;
        stalabel(isinf(stalabel))=newlabel(i);
    end
    label = stalabel;
    