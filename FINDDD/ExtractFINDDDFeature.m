function [ finddd_descriptors ] = ExtractFINDDDFeature( rangeMap, masks, para )

sampling_rate = para.sampling_rate;
PatchSize = para.PatchSize;
layerNum = size(PatchSize,1);

mask = masks == 2;
mask = imresize(mask,sampling_rate,'nearest');

[Y X] = find(mask==1);
scale = 1/sampling_rate;
Y = Y*scale-0.5*scale;
X = X*scale-0.5*scale;


batchNum = fix(length(X)/12);
restNum = length(X) - 12*batchNum;

for i = 1:12
    pX{i} = X((i-1)*batchNum+1:i*batchNum);
    pY{i} = Y((i-1)*batchNum+1:i*batchNum);
end
for i = 1:restNum
    pX{i} = [ pX{i}; X(12*batchNum+i) ];
    pY{i} = [ pY{i}; Y(12*batchNum+i) ];
end
    
finddd_descriptors = cell(12,1);

parfor b = 1:12
    finddd_descriptors{b} = zeros(length(pX{b}),para.o*para.s(1)*para.s(2));
    
    for i = 1:length(pX{b})
        x = pX{b}(i);
        y = pY{b}(i);
        
        for layeri=1:layerNum
            patchSize = PatchSize(layeri,:);
            [ patch ] = GetPatch( rangeMap, [y x], fix(patchSize(1)/2) );
            
            uSize = fix(patchSize(2)/2)*2+1; % patch height
            wSize = fix(patchSize(1)/2)*2+1; % patch length
            
            if size(patch,1)~=uSize || size(patch,2)~=wSize
                continue;
            end
            
            [ finddd_descriptori ] = computeFinddd( patch, para );
        end
        finddd_descriptors{b}(i,:) =  finddd_descriptori;
    end
end

finddd_descriptors = cell2mat(finddd_descriptors);