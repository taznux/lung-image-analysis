%% main function
clc;
clear;

%% selected patients who have ground truth
%% selected patients who have ground truth
selected = {'LIDC-IDRI-0072'
    'LIDC-IDRI-0090'
    'LIDC-IDRI-0138'
    'LIDC-IDRI-0149'
    'LIDC-IDRI-0162'
    'LIDC-IDRI-0163'
    'LIDC-IDRI-0166'
    'LIDC-IDRI-0167'
    'LIDC-IDRI-0168'
    'LIDC-IDRI-0171'
    'LIDC-IDRI-0178'
    'LIDC-IDRI-0180'
    'LIDC-IDRI-0183'
    'LIDC-IDRI-0185'
    'LIDC-IDRI-0186'
    'LIDC-IDRI-0187'
    'LIDC-IDRI-0191'
    'LIDC-IDRI-0203'
    'LIDC-IDRI-0211'
    'LIDC-IDRI-0212'
    'LIDC-IDRI-0233'
    'LIDC-IDRI-0234'
    'LIDC-IDRI-0242'
    'LIDC-IDRI-0246'
    'LIDC-IDRI-0247'
    'LIDC-IDRI-0249'
    'LIDC-IDRI-0256'
    'LIDC-IDRI-0257'
    'LIDC-IDRI-0265'
    'LIDC-IDRI-0267'
    'LIDC-IDRI-0268'
    'LIDC-IDRI-0270'
    'LIDC-IDRI-0271'
    'LIDC-IDRI-0273'
    'LIDC-IDRI-0275'
    'LIDC-IDRI-0276'
    'LIDC-IDRI-0277'
    'LIDC-IDRI-0283'
    'LIDC-IDRI-0286'
    'LIDC-IDRI-0289'
    'LIDC-IDRI-0290'
    'LIDC-IDRI-0314'
    'LIDC-IDRI-0325'
    'LIDC-IDRI-0332'
    'LIDC-IDRI-0377'
    'LIDC-IDRI-0385'
    'LIDC-IDRI-0399'
    'LIDC-IDRI-0405'
    'LIDC-IDRI-0454'
    'LIDC-IDRI-0470'
    'LIDC-IDRI-0493'
    'LIDC-IDRI-0510'
    'LIDC-IDRI-0522'
    'LIDC-IDRI-0543'
    'LIDC-IDRI-0559'
    'LIDC-IDRI-0562'
    'LIDC-IDRI-0568'
    'LIDC-IDRI-0580'
    'LIDC-IDRI-0610'
    'LIDC-IDRI-0624'
    'LIDC-IDRI-0766'
    'LIDC-IDRI-0771'
    'LIDC-IDRI-0811'
    'LIDC-IDRI-0875'
    'LIDC-IDRI-0905'
    'LIDC-IDRI-0921'
    'LIDC-IDRI-0924'
    'LIDC-IDRI-0939'
    'LIDC-IDRI-0965'
    'LIDC-IDRI-0994'
    'LIDC-IDRI-1002'
    'LIDC-IDRI-1004'};

%% toolbox
addpath(genpath([pwd '/toolbox']))

%% module path values
util_path=[pwd '/util'];
input_path=[pwd '/io'];

%% module addpath
addpath(genpath(util_path));
addpath(genpath(input_path));


%% set global values
global path_nodule;
global path_data;

path_nodule = ['D:/works_lu_group/Projects/LungScreening/DATA/']; %pwd : returns the current directory
path_data = [pwd '/../../LIDC-IDRI/']; %dcm files directory

%% set values
iso_px_size=1; % a standard unit ('mm-unit')


%% directory paths
ct_img_path=[path_nodule '/CT_Images/'];
nrrd_img_path=[path_nodule '/LIDC-radiomics/'];

%% make directory
if ~isdir(ct_img_path); mkdir(ct_img_path); end

merged_nodule_info = [];

%% main process
for idx = 1:numel(selected)
    pid = selected{idx};
    
    if strcmp(pid, 'LIDC-IDRI-0405') == 0 || sum(strcmp(selected, pid)) == 0
        continue
    end
    
    tic % tic starts a stopwatch timer
    fprintf('%d %s\n', idx, pid);
    %% input part
    
    filename_input = [ct_img_path pid '_input.mat'];
    load(filename_input);
    
    if numel(nodule_info) == 0
        continue
    end
    %% merge nodule info
    merged_nodule_info = [merged_nodule_info; nodule_info(:,[1:3 5:6 10:12 15:17]) nodule_info.Characteristics];
    
end

writetable(merged_nodule_info, [nrrd_img_path 'nodule_info.csv'])


% module rmpath
% rmpath('./io');
% rmpath('./interpolation');
% rmpath('./segmentation');
% rmpath('./nodule_candidate_detection');


