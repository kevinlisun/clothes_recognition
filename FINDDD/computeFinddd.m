function [finddd] = computeFinddd(img, para)

    img(isnan(img)) = 0;
    
    s = para.s;
    o = para.o;
    k = 4;
    bin_center = para.bin_center;
    
    w = fix(size(img,2)/para.s(2));
    h = fix(size(img,1)/para.s(1));
    
    img = imresize(img, [h*para.s(1),w*para.s(2)]);
    
    [x y z] = surfnorm(img);
    
    finddd = [];
    
    for i = 1:s(1)
        for j = 1:s(2)
           normalij_x = x((i-1)*h+1:i*h, (j-1)*w+1:j*w);
           normalij_y = y((i-1)*h+1:i*h, (j-1)*w+1:j*w);
           normalij_z = z((i-1)*h+1:i*h, (j-1)*w+1:j*w);
           
           normalij = [ normalij_x(:), normalij_y(:), normalij_z(:) ];
           [ distanceMat ] = ComputeDistance( normalij, bin_center );
           
           findddij = zeros(1,para.o);
           for n = 1:k
               [ a b ] = min(distanceMat, [], 2);
               % distance voting
               for m = 1:length(b)
                  findddij(b(m)) = findddij(b(m)) + a(m);
                  distanceMat(m,b(m)) = realmax;
               end
           end
           finddd = [ finddd, findddij ];
        end
    end
    
    finddd(isnan(finddd)) = 0;
    finddd = finddd ./ sum(finddd); % L1 norm
    
    if sum(finddd~=0) == 0
        finddd = [];
    end
           
    