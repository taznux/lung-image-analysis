%% main function
clc;
clear;

%% toolbox
addpath(genpath([pwd '/toolbox']))


%% module path values
util_path=[pwd '/util'];
input_path=[pwd '/io'];
interpolation_path=[pwd '/interpolation'];
segmentation_path=[pwd '/lung_segmentation'];
nodule_segmentation_path=[pwd '/nodule_segmentation'];
candidates_path=[pwd '/nodule_candidate_detection'];
feature_extraction_path=[pwd '/feature_extraction'];
evaluation_path=[pwd '/evaluation'];

%% module addpath
addpath(genpath(util_path));
addpath(genpath(input_path));
addpath(genpath(interpolation_path));
addpath(genpath(segmentation_path));
addpath(genpath(nodule_segmentation_path));
addpath(genpath(candidates_path));
addpath(genpath(feature_extraction_path));
addpath(genpath(evaluation_path));

%% set global values

global path_nodule;
global path_data;

path_nodule = [pwd '/output_data']; %pwd : returns the current directory
path_data = [pwd '/DATA/LIDC-IRDI']; %dcm files directory

%% set values
iso_px_size=[]; % a standard unit ('mm-unit')


%% directory paths
ct_img_path=[path_nodule '/CT_Images/'];
img_path=[path_nodule '/interpolation_nodule_images/'];
seg_img_path=[path_nodule '/lung_segmentation_images/'];
candidates_img_path=[path_nodule '/nodule_candidate_detection_images/'];
feature_path=[path_nodule '/features/'];
evaluation_detection_result_path=[path_nodule '/evalation_result/'];
nodule_segmentation_path=[path_nodule '/nodule_segmentation/'];
nodule_segmentation_eval_path=[path_nodule '/nodule_segmentation_evaluation/'];

%% make directory
if ~isdir(ct_img_path); mkdir(ct_img_path); end
if ~isdir(img_path); mkdir(img_path); end
if ~isdir(seg_img_path); mkdir(seg_img_path); end
if ~isdir(candidates_img_path); mkdir(candidates_img_path); end
if ~isdir(feature_path); mkdir(feature_path); end
if ~isdir(evaluation_detection_result_path); mkdir(evaluation_detection_result_path); end
if ~isdir(nodule_segmentation_path); mkdir(nodule_segmentation_path); end;
if ~isdir(nodule_segmentation_eval_path); mkdir(nodule_segmentation_eval_path); end


%% saved data load or not
load_input = true;
load_interpoltaion = true;
load_segmentation = true;
load_nodule_segmentation = false;
load_nodule_segmentation_eval = false;
load_nodule_candidate_detection = true;
load_nodule_feature_extraction = true;
load_evaluation_detection = true;


%% get pids
filename_pid_list = [path_nodule '/dicom_pid_list.mat'];
if(fn_check_load_data(filename_pid_list, load_input))
    [dicom_path_list,pid_list]=fn_scan_pid(path_data);
    
    save(filename_pid_list, 'dicom_path_list', 'pid_list');
else
    load(filename_pid_list);
end

nodule_segmentation_evaluation = [];

%% main process
for idx = 1:numel(pid_list)
    fclose('all'); % to avoid too many files open
    
    pid = pid_list{idx};
    tic % tic starts a stopwatch timer
    fprintf('%d %s\n', idx, pid);
    %% input part
    filename_input = [ct_img_path pid '_input.mat'];
    if(fn_check_load_data(filename_input, load_input))
        dicom_path = dicom_path_list{idx};
        [lung_img_3d, nodule_img_3d, dicom_tags, thick, pixelsize, nodule_info] = fn_dicom_read(dicom_path,pid);
        
        save(filename_input, 'lung_img_3d', 'nodule_img_3d' ,'dicom_tags', 'thick' ,'pixelsize', 'nodule_info');
    else
        load(filename_input);
    end
    fprintf('dicom images loaded ... \t\t\t %6.2f sec\n', toc);
    %% minimum resoultion
    min_resolution=max([thick pixelsize(1) pixelsize(2)]);
    
    %% nodule segmentation part
    % type
    %     type=1; % sphere ring model and general deformable model adaptation
    %     type=2; % cube ring model and general deformable model adaptation
    %     type=3; % sphere ring model and SMSM adaptation
    %     type=4; % cube ring model and SMSM adaptation
    %     type=5; % triangle mesh sphere model and proposed adaptation
    type = 1;
    
    if size(nodule_info,1) == 0
        continue
    end
    filename_nodule_segmentation = [ nodule_segmentation_path pid '_'  num2str(iso_px_size,'%3.1f') '_' num2str(type,'%3.1f') '_nodule_segmentation.mat'];
    if(fn_check_load_data(filename_nodule_segmentation, load_nodule_segmentation))
        %[s_list,v_list]=fn_nodule_segmentation(nodule_img_3d,lung_img_3d,nodule_info,thick,pixelsize,type);
        s_list=[];
        v_list = fn_nodule_segmentation_multitreshold(lung_img_3d,nodule_info,thick, pixelsize,iso_px_size);
        save(filename_nodule_segmentation, 's_list','v_list','type');
    else
        load(filename_nodule_segmentation);
    end
    fprintf('nodule segmentaion completed ... \t\t\t %6.2f sec\n', toc);
    
    %% evaluation part
    % nodule segmentation evaluation
    filename_nodule_segmentation_eval = [ nodule_segmentation_eval_path pid '_'  num2str(iso_px_size,'%3.1f') '_' num2str(type,'%3.1f') '_nodule_segmentation_eval.mat'];
    if(fn_check_load_data(filename_nodule_segmentation_eval, load_nodule_segmentation_eval))
        [ ravd,voe,assd,v_r_list,lung_ext_list ] = fn_nodule_segmentation_eval(nodule_img_3d,lung_img_3d,nodule_info,thick,pixelsize,iso_px_size,[],v_list);
        nodule_segmentation = [nodule_info(:,{'pid','sid','nid'}), table(ravd,voe,assd)]
        if(numel(nodule_info)>0)
            pt = [];
            for sid = unique(nodule_info.sid)'
                ravd = mean(nodule_segmentation(cell2mat(nodule_segmentation.sid(:)) == sid{1},:).ravd);
                voe = mean(nodule_segmentation(cell2mat(nodule_segmentation.sid(:)) == sid{1},:).voe);
                assd = mean(nodule_segmentation(cell2mat(nodule_segmentation.sid(:)) == sid{1},:).assd);
                session = table;
                session.pid = {pid};
                session.sid = sid;
                session.ravd = ravd;
                session.voe = voe;
                session.assd = assd;
                
                pt = [pt; session];
            end
            pt = [pt; {pt.pid(1), {'a'}, mean(pt.ravd), mean(pt.voe), mean(pt.assd)}];
            pt
            nodule_segmentation_evaluation = [nodule_segmentation_evaluation; pt];
        end
        save(filename_nodule_segmentation_eval, 'nodule_segmentation','ravd','voe','assd','v_r_list','lung_ext_list','type');
    else
        load(filename_nodule_segmentation_eval);
    end
    fprintf('nodule evaluation completed ... \t\t\t %6.2f sec\n', toc);
end


% Overall Evaluation
nodule_segmentation_summary = [];
for sid = unique(nodule_segmentation_evaluation.sid)'
    ravd = mean(nodule_segmentation_evaluation(cell2mat(nodule_segmentation_evaluation.sid(:)) == sid{1},:).ravd);
    voe = mean(nodule_segmentation_evaluation(cell2mat(nodule_segmentation_evaluation.sid(:)) == sid{1},:).voe);
    assd = mean(nodule_segmentation_evaluation(cell2mat(nodule_segmentation_evaluation.sid(:)) == sid{1},:).assd);
    session = table;
    session.sid = sid;
    session.ravd = ravd;
    session.voe = voe;
    session.assd = assd;
    
    nodule_segmentation_summary = [nodule_segmentation_summary; session];
end
nodule_segmentation_summary
