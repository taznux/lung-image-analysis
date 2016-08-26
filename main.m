%% main function
clc;
clear;

%% toolbox
addpath(genpath([pwd '/toolbox']))


%% module path values
util_path=[pwd '/util'];
input_path=[pwd '/input'];
interpolation_path=[pwd '/interpolation'];
segmentation_path=[pwd '/segmentation'];
nodule_seg_path=[pwd '/nodule_seg'];
candidates_path=[pwd '/nodule_candidate_detection'];
feature_extraction_path=[pwd '/feature_extraction'];
evaluation_path=[pwd '/evaluation'];

%% module addpath
addpath(genpath(util_path));
addpath(genpath(input_path));
addpath(genpath(interpolation_path));
addpath(genpath(segmentation_path));
addpath(genpath(nodule_seg_path));
addpath(genpath(candidates_path));
addpath(genpath(feature_extraction_path));
addpath(genpath(evaluation_path));

%% set global values

global path_nodule;
global path_data;

path_nodule = [pwd '/output_data']; %pwd : returns the current directory
path_data = [pwd '/DATA/LIDC_old']; %dcm files directory

%% set values
iso_px_size=1; % a standard unit ('mm-unit')

%% get pid
[dicom_path_list,pid_list]=fn_scan_pid(path_data);

%% directory path values
ct_img_path=[path_nodule '/CT_Images/'];
interpol_img_path=[path_nodule '/interpolation_nodule_images/'];
seg_img_path=[path_nodule '/segmentation_images/'];
candidates_img_path=[path_nodule '/nodule_candidate_detection_images/'];
feature_path=[path_nodule '/features/'];
evaluation_detection_result_path=[path_nodule '/evalation_result/'];
nodule_seg_path=[path_nodule '/nodule_segmentation/'];
nodule_seg_eval_path=[path_nodule '/nodule_segmentation_evaluation/'];

%% make directory
if ~isdir(ct_img_path); mkdir(ct_img_path); end
if ~isdir(interpol_img_path); mkdir(interpol_img_path); end
if ~isdir(seg_img_path); mkdir(seg_img_path); end
if ~isdir(candidates_img_path); mkdir(candidates_img_path); end
if ~isdir(feature_path); mkdir(feature_path); end
if ~isdir(evaluation_detection_result_path); mkdir(evaluation_detection_result_path); end
if ~isdir(nodule_seg_path); mkdir(nodule_seg_path); end;
if ~isdir(nodule_seg_eval_path); mkdir(nodule_seg_eval_path); end
%% data load or not
load_input = false;
load_interpoltaion = false;
load_segmentation = false;
load_nodule_seg = false;
load_nodule_seg_eval= false;
load_nodule_candidate_detection = false;
load_nodule_feature_extraction=false;
load_evaluation_detection=false;

%% main process
for idx = 1:numel(pid_list)
    pid = pid_list{idx};
    tic % tic starts a stopwatch timer
    fprintf('%d %s\n', idx, pid);
    %% input part
    
    filename_input = [ct_img_path num2str(pid,'%03d') '_input.mat'];
    
    if(fn_check_load_data(filename_input, load_input))
        dicom_path = dicom_path_list{idx};
        [lung_img_3d nodule_img_3d dicom_tags thick pixelsize nodule_info cc] = fn_dicom_read(dicom_path,pid);
        
        save(filename_input, 'lung_img_3d', 'nodule_img_3d' ,'dicom_tags', 'thick' ,'pixelsize', 'nodule_info', 'cc');
    else
        load(filename_input);
    end
    fprintf('dicom images loaded ... \t\t\t %6.2f sec\n', toc);
    %% minimum resoultion
    min_resolution=max([thick pixelsize(1) pixelsize(2)]);
    
    %% interpolation part
    
    filename_interpolation = [interpol_img_path num2str(pid,'%03d') '_'  num2str(iso_px_size,'%3.1f') '_interpolation.mat'];
    
    if(fn_check_load_data(filename_interpolation, load_interpoltaion))
        [interpol_lung_img_3d,interpol_nodule_img_3d]=fn_interpol3d(lung_img_3d,nodule_img_3d,thick,pixelsize,iso_px_size);
        save(filename_interpolation, 'interpol_lung_img_3d','interpol_nodule_img_3d','iso_px_size');
    else
        load(filename_interpolation);
    end
    fprintf('interpolation completed ... \t\t\t %6.2f sec\n', toc);
    
    %% lung segmentation part
    
    filename_segmentation = [seg_img_path num2str(pid,'%03d') '_'  num2str(iso_px_size,'%3.1f') '_segmentation.mat'];
    
    if(fn_check_load_data(filename_segmentation, load_segmentation))
        [lung_seg_img_3d,T]=fn_segmentation(interpol_lung_img_3d);
        
        save(filename_segmentation,'lung_seg_img_3d','T');
    else
        load(filename_segmentation);
    end
    fprintf('segmentation completed ... \t\t\t %6.2f sec\n', toc);   
    
    
    %% nodule candidate detection
    
    filename_nodule_candidate_detection_images = [candidates_img_path num2str(pid,'%03d') '_'  num2str(iso_px_size,'%3.1f') '_candidates.mat'];
    
    if(fn_check_load_data(filename_nodule_candidate_detection_images, load_nodule_candidate_detection))
        [nodule_candidates_morphology_img_3d]=fn_nodule_candidate_detection(interpol_lung_img_3d,lung_seg_img_3d);
        
        save(filename_nodule_candidate_detection_images,'nodule_candidates_morphology_img_3d');
    else
        load(filename_nodule_candidate_detection_images);
    end
    fprintf('nodule candidate detection completed ... \t %6.2f sec\n', toc);
    
    
    %% feature extraction
    filename_nodule_feature_extraction = [feature_path num2str(pid,'%03d') '_'  num2str(iso_px_size,'%3.1f') '_feature.mat'];
    
    if(fn_check_load_data(filename_nodule_feature_extraction, load_nodule_feature_extraction))
        
        [nodule_candidates_features ] = fn_feature_extraction(idx, nodule_candidates_morphology_img_3d, interpol_lung_img_3d, iso_px_size);
        
        save(filename_nodule_feature_extraction,'nodule_candidates_features');
    else
        load(filename_nodule_feature_extraction);
    end
    fprintf('nodule feature extreaction completed ... \t %6.2f sec\n', toc);
    
    
    
    %% Evalutation of detection
    filename_load_evaluation_detection = [evaluation_detection_result_path num2str(pid,'%03d') '_'  num2str(iso_px_size,'%3.1f') '_Evalutation_detection .mat'];
    
    if(fn_check_load_data(filename_load_evaluation_detection, load_evaluation_detection))
        [nodule_candidates_features nodule_info]=fn_evaluation(nodule_candidates_features,nodule_info,min_resolution);
        save(filename_load_evaluation_detection,'nodule_candidates_features', 'nodule_info');
    else
        load(filename_load_evaluation_detection);
    end
    
    fprintf('nodule candidate detection completed ... \t %6.2f sec\n', toc);
    
end

% FPs reduction



% Overall Evaluation




% module rmpath
% rmpath('./input');
% rmpath('./interpolation');
% rmpath('./segmentation');
% rmpath('./nodule_candidate_detection');


