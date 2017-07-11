clear all
clc

clothes = 1:51
captures = 0:20
coding_opt = 'LLC'

dataset_dir = '~/clothes_dataset_RH'
rep_dir = '~/clothes_dataset_RH/ProcessedData';

if ~exist(rep_dir,'dir')
    mkdir(rep_dir);
end

for i = 1:length(clothes)
    clothesi = clothes(i);
    
    if clothesi < 10
        cur_data_dir = strcat(dataset_dir,'/0',num2str(clothesi),'/');
        cur_rep_dir = strcat(rep_dir,'/0',num2str(clothesi),'/');
    else
        cur_data_dir = strcat(dataset_dir,'/',num2str(clothesi),'/');
        cur_rep_dir = strcat(rep_dir,'/',num2str(clothesi),'/');
    end
    
    if ~exist(cur_rep_dir,'dir')
        mkdir(cur_rep_dir);
    end
    
    cmd = [ 'cp ',cur_data_dir,'info.mat', ' ',cur_rep_dir ];
    system(cmd);

    % clear old data
    cmd = [ 'rm ',cur_rep_dir,'global_descriptors_capture*.mat' ];
    system(cmd);
    cmd = [ 'rm ',cur_rep_dir, coding_opt,'_codes_capture*.mat' ];
    system(cmd);
    
    for j = 1:length(captures)
        capturej = captures(j);
        cmd = [ 'cp ',cur_data_dir,'Features/global_descriptors_capture',num2str(capturej),'.mat', ' ',cur_rep_dir ];
        system(cmd);
        
        cmd = [ 'cp ',cur_data_dir,'Codes/',coding_opt,'_codes_capture',num2str(capturej),'.mat', ' ',cur_rep_dir ];
        system(cmd);
        
        cmd = [ 'cp ',cur_data_dir,'info.mat', ' ',cur_rep_dir ];
        system(cmd);
    end
end
