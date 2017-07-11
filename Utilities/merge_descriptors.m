function merge_descriptors(filename, descriptors_new, para, opt)

    load(filename);
    
    if strcmp(opt, 'global')

        if para.global.si
            global_descriptors.si = descriptors_new.si;
        end
        if para.global.lbp
            global_descriptors.lbp = descriptors_new.lbp;
        end
        if para.global.topo
            global_descriptors.topo = descriptors_new.topo;
        end
        if para.global.dlcm
            global_descriptors.dlcm = descriptors_new.dlcm;
        end
        if para.global.imm
            global_descriptors.imm = descriptors_new.imm;
        end
        if para.global.vol
            global_descriptors.vol = descriptors_new.vol;
        end
        
        save(filename, 'global_descriptors');
        
    elseif strcmp(opt, 'local')

        if para.local.bsp
            local_descriptors.bsp = descriptors_new.bsp;
        end
        if para.local.finddd
            local_descriptors.finddd = descriptors_new.finddd;
        end
        if para.local.lbp
            local_descriptors.lbp = descriptors_new.lbp;
        end
        if para.local.sc
            local_descriptors.sc = descriptors_new.sc;
        end
        if para.local.dlcm
            local_descriptors.dlcm = descriptors_new.dlcm;
        end        
        if para.local.sift
            local_descriptors.sift = descriptors_new.sift;
        end      
        
        save(filename, 'local_descriptors');
        
    else
        disp('incorrect opt!');
    end

    