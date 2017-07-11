function [ inst label norm ] = prepareData( inst, label, norm )

% this script normalizes the data (inst) to [ 0 1 ] for each colum, and also using -1
% for negative 1 for positive labels
    
    % data normlization
    if nargin < 2
        [ inst, norm ] = mapminmax(inst',0,1);
        label = [];
        inst = inst';
        return;
    elseif nargin < 3
        [ inst, norm ] = mapminmax(inst',0,1);
        inst = inst';
    else
        [ inst ] = mapminmax( 'apply', inst' , norm ); 
        inst = inst';
    end

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
    

    
    
    
    