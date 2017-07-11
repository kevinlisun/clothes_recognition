clear all
clc

clothes = 15
captures = 0:30
coding_opt = 'LLC'

dataset_dir = '/home/kevin/clothes_dataset_kinect'

for i = 1:length(clothes)
    clothesi = clothes(i);
    
    if clothesi < 10
        cur_data_dir = strcat(dataset_dir,'/0',num2str(clothesi),'/');
    else
        cur_data_dir = strcat(dataset_dir,'/',num2str(clothesi),'/');
    end
    
    [ list ] = dir(cur_data_dir);
    
    list([1,2,end]) = [];
    for j = 1:length(list)
        capturei = captures(j);
        dataFile = strcat(cur_data_dir,'clothes_',num2str(clothesi),'_capture_',num2str(capturei));
        cmd = [ 'cp ', cur_data_dir, list(j).name, '/rgb.png ', dataFile, '_rgb.png' ];
        
        system(cmd);
        
        dataFile = strcat(cur_data_dir,'clothes_',num2str(clothesi),'_capture_',num2str(capturei));
        cmd = [ 'cp ', cur_data_dir, list(j).name, '/fDepth.png ', dataFile, '_depth.png' ];
                  
        system(cmd);
        
        cmd = [ 'rm -rf ', cur_data_dir, list(j).name ];
        
        system(cmd);
    end   
end
