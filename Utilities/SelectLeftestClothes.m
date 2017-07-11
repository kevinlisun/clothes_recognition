
close all

addpath('../SurfaceFeature');

target = [276 190];

clothes = double(clothes)/255;
clothes = rgb2ind(clothes,32);

%[  clothes ] = SurfaceFeatureFiltMex( double(clothes), 7 );
clothes(isnan(clothes)) = 0;

labels = unique(clothes);

labels(labels==0) = [];

labelNum = length(labels);

array_label = zeros(1,labelNum);
array_location = zeros(1,labelNum);

for i = 1:labelNum
    labeli = labels(i);
    
    array_label(i) = labeli;
    [tmp_row tmp_col] = find(clothes==labeli);
    
    if size(tmp_row,1) < 80*80
        array_location(i) = realmax;
    else
        distMat = ComputeDistance(target, [tmp_row tmp_col]);
        array_location(i) = min(distMat);
    end
end

[ a b ] = sort( array_location, 'ascend' );

selectedClothes = clothes==array_label(b(1));

%se = strel('disk', 10, 4);
%selectedClothes = imerode(selectedClothes,se);
%selectedClothes = imdilate(selectedClothes,se);
selectedClothes = imfill(selectedClothes,'holes');

if sum(sum(selectedClothes)) < 2500 && sum(sum(selectedClothes))  > 300*300
    selectedClothes = zeros(size(clothes));
end

% % figure('name','Selected clothes for recognition');
% % imagesc(selectedClothes);


