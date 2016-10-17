%% main function
clc;
clear;

%% selected patients who have ground truth
selected = {'LIDC-IDRI-0068'
    'LIDC-IDRI-0071'
    'LIDC-IDRI-0072'
    'LIDC-IDRI-0088'
    'LIDC-IDRI-0090'
    'LIDC-IDRI-0091'
    'LIDC-IDRI-0100'
    'LIDC-IDRI-0118'
    'LIDC-IDRI-0124'
    'LIDC-IDRI-0129'
    'LIDC-IDRI-0135'
    'LIDC-IDRI-0137'
    'LIDC-IDRI-0138'
    'LIDC-IDRI-0143'
    'LIDC-IDRI-0149'
    'LIDC-IDRI-0159'
    'LIDC-IDRI-0161'
    'LIDC-IDRI-0162'
    'LIDC-IDRI-0163'
    'LIDC-IDRI-0164'
    'LIDC-IDRI-0165'
    'LIDC-IDRI-0166'
    'LIDC-IDRI-0167'
    'LIDC-IDRI-0168'
    'LIDC-IDRI-0169'
    'LIDC-IDRI-0171'
    'LIDC-IDRI-0173'
    'LIDC-IDRI-0174'
    'LIDC-IDRI-0175'
    'LIDC-IDRI-0176'
    'LIDC-IDRI-0178'
    'LIDC-IDRI-0179'
    'LIDC-IDRI-0180'
    'LIDC-IDRI-0181'
    'LIDC-IDRI-0182'
    'LIDC-IDRI-0183'
    'LIDC-IDRI-0184'
    'LIDC-IDRI-0185'
    'LIDC-IDRI-0186'
    'LIDC-IDRI-0187'
    'LIDC-IDRI-0188'
    'LIDC-IDRI-0189'
    'LIDC-IDRI-0190'
    'LIDC-IDRI-0191'
    'LIDC-IDRI-0192'
    'LIDC-IDRI-0193'
    'LIDC-IDRI-0194'
    'LIDC-IDRI-0197'
    'LIDC-IDRI-0198'
    'LIDC-IDRI-0200'
    'LIDC-IDRI-0202'
    'LIDC-IDRI-0203'
    'LIDC-IDRI-0205'
    'LIDC-IDRI-0207'
    'LIDC-IDRI-0210'
    'LIDC-IDRI-0211'
    'LIDC-IDRI-0212'
    'LIDC-IDRI-0213'
    'LIDC-IDRI-0214'
    'LIDC-IDRI-0217'
    'LIDC-IDRI-0220'
    'LIDC-IDRI-0221'
    'LIDC-IDRI-0222'
    'LIDC-IDRI-0223'
    'LIDC-IDRI-0224'
    'LIDC-IDRI-0225'
    'LIDC-IDRI-0226'
    'LIDC-IDRI-0230'
    'LIDC-IDRI-0231'
    'LIDC-IDRI-0232'
    'LIDC-IDRI-0233'
    'LIDC-IDRI-0234'
    'LIDC-IDRI-0235'
    'LIDC-IDRI-0236'
    'LIDC-IDRI-0237'
    'LIDC-IDRI-0239'
    'LIDC-IDRI-0242'
    'LIDC-IDRI-0243'
    'LIDC-IDRI-0244'
    'LIDC-IDRI-0245'
    'LIDC-IDRI-0246'
    'LIDC-IDRI-0247'
    'LIDC-IDRI-0248'
    'LIDC-IDRI-0249'
    'LIDC-IDRI-0250'
    'LIDC-IDRI-0251'
    'LIDC-IDRI-0252'
    'LIDC-IDRI-0253'
    'LIDC-IDRI-0254'
    'LIDC-IDRI-0255'
    'LIDC-IDRI-0256'
    'LIDC-IDRI-0257'
    'LIDC-IDRI-0258'
    'LIDC-IDRI-0260'
    'LIDC-IDRI-0261'
    'LIDC-IDRI-0264'
    'LIDC-IDRI-0265'
    'LIDC-IDRI-0266'
    'LIDC-IDRI-0267'
    'LIDC-IDRI-0268'
    'LIDC-IDRI-0270'
    'LIDC-IDRI-0271'
    'LIDC-IDRI-0272'
    'LIDC-IDRI-0273'
    'LIDC-IDRI-0274'
    'LIDC-IDRI-0275'
    'LIDC-IDRI-0276'
    'LIDC-IDRI-0277'
    'LIDC-IDRI-0278'
    'LIDC-IDRI-0279'
    'LIDC-IDRI-0280'
    'LIDC-IDRI-0281'
    'LIDC-IDRI-0282'
    'LIDC-IDRI-0283'
    'LIDC-IDRI-0285'
    'LIDC-IDRI-0286'
    'LIDC-IDRI-0287'
    'LIDC-IDRI-0288'
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
    'LIDC-IDRI-0576'
    'LIDC-IDRI-0580'
    'LIDC-IDRI-0610'
    'LIDC-IDRI-0624'
    'LIDC-IDRI-0766'
    'LIDC-IDRI-0771'
    'LIDC-IDRI-0772'
    'LIDC-IDRI-0811'
    'LIDC-IDRI-0818'
    'LIDC-IDRI-0875'
    'LIDC-IDRI-0893'
    'LIDC-IDRI-0905'
    'LIDC-IDRI-0921'
    'LIDC-IDRI-0924'
    'LIDC-IDRI-0939'
    'LIDC-IDRI-0965'
    'LIDC-IDRI-0994'
    'LIDC-IDRI-1002'
    'LIDC-IDRI-1004'
    'LIDC-IDRI-1010'
    'LIDC-IDRI-1011'};

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

path_nodule = [pwd '/output_data']; %pwd : returns the current directory
path_data = [pwd '/../../LIDC-IDRI/']; %dcm files directory

%% set values
iso_px_size=1; % a standard unit ('mm-unit')


%% directory paths
ct_img_path=[path_nodule '/CT_Images/'];
nrrd_img_path=[pwd '/DATA/nodule_radiomics/'];

%% make directory
if ~isdir(ct_img_path); mkdir(ct_img_path); end



%% main process
for idx = 1:numel(selected)
    pid = selected{idx};
    
    if sum(strcmp(selected, pid)) == 0
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
    %% edit nodule info
    [nodule_img_3d, nodule_info] = fn_nodule_info_update(lung_img_3d,nodule_img_3d,nodule_info,thick,pixelsize);
    
    if ~isdir([nrrd_img_path '/' pid]); mkdir([nrrd_img_path '/' pid]); end
    writetable([nodule_info(:,[1:3 5:6 end 10:12 15:17]) nodule_info.Characteristics], [nrrd_img_path pid '/' pid '.csv'])

    
    
    
    
end


% module rmpath
% rmpath('./io');
% rmpath('./interpolation');
% rmpath('./segmentation');
% rmpath('./nodule_candidate_detection');


