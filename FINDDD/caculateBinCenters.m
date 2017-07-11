function [ bin_center ] = caculateBinCenters(para)



    % caculate bin centers
    is_done = 0;
    
    while ~is_done
        [V,Tri,~,Ue] = ParticleSampleSphere('N',2*para.o);
        index = find(V(:,3)>0);
        bin_center = V(index,:);
        if length(index) == para.o
            is_done = 1;
        end
    end
    