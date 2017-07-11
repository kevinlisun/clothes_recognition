
close all

addpath('../SurfaceFeature');

clothes = double(clothes)/255;
clothes = rgb2ind(clothes,32);

%[  clothes ] = SurfaceFeatureFiltMex( double(clothes), 7 );
clothes(isnan(clothes)) = 0;

target = [276 190];

if clothes(target(1), target(2)) > 0 % check whether Table 1 is empty
    labeli = clothes(target(1), target(2));
    if sum(sum(clothes==labeli)) > 2500 && clothes(405,692) ~= labeli && clothes(128,676) ~= labeli && clothes(112,360) ~= labeli && clothes(405,692) ~= labeli && clothes(396,365) ~= labeli
        selectedClothes = clothes==labeli;
    end
    
else
    
    % Table 2 is empty
    labels = unique(clothes);
    
    labels(labels==0) = [];
    % % labels = labels(1:sum(~isnan(labels))+1);
    
    labelNum = length(labels);
    
    array_label = zeros(1,labelNum);
    array_area = zeros(1,labelNum);
    
    for i = 1:labelNum
        labeli = labels(i);
        
        array_label(i) = labeli;
        
        if clothes(405,692) ~= labeli && clothes(128,676) ~= labeli && clothes(112,360) ~= labeli && clothes(405,692) ~= labeli && clothes(396,365) ~= labeli
            array_area(i) = sum(sum(clothes==labeli));
        end
    end
    
    [ a b ] = sort( array_area, 'descend' );
    
    
    selectedClothes = clothes==array_label(b(1));
    
    %se = strel('disk', 10, 4);
    %selectedClothes = imerode(selectedClothes,se);
    %selectedClothes = imdilate(selectedClothes,se);
    selectedClothes = imfill(selectedClothes,'holes');
    
    if sum(sum(selectedClothes)) < 2500
        selectedClothes = zeros(size(clothes));
    end
end

% % figure('name','Selected clothes for recognition');
% % imagesc(selectedClothes);


