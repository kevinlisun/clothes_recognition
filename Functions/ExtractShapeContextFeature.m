function [ sc_descriptors ] = ExtractShapeContextFeature( garment_mask, para, flag )

garment_mask = imresize(garment_mask,para.sampling_rate,'nearest');
[ B ] = bwboundaries(garment_mask);

scale = 1/para.sampling_rate;
B{1} = B{1}*scale;
B{1} = B{1}(:,[2,1]);

bmax = size(B{1},1);
clothes_contour = B{1};

if size(B,1) ~= 1
    for i = 2:size(B,1)
        if size(B{i},1) > bmax
            bmax = size(B{i},1);
            clothes_contour = B{i};
        end
    end
end
mean_dist = para.mean_dist;        
nbins_theta = para.nbins_theta;
nbins_r = para.nbins_r;
r_inner = para.r_inner;
r_outer = para.r_outer;
out_vec = zeros(1,bmax);

[ sc_descriptors,mean_dist ] = sc_compute(clothes_contour',zeros(1,bmax),mean_dist,nbins_theta,nbins_r,r_inner,r_outer,out_vec);

if flag
    subplot(2,2,4);
    title('shape cntext descriptrs');
    imagesc(sc_descriptors);
end