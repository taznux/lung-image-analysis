%% main function
clc;
clear;

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

path_nodule = [pwd '/DATA']; %pwd : returns the current directory
path_data = [pwd '/DATA/LIDC-IDRI/']; %dcm files directory

%% set values
iso_px_size=1; % a standard unit ('mm-unit')
l_offset = [0, 0, 0;
    1, 0, 0;
    -1, 0, 0;
    0, 1, 0;
    0, -1, 0;
    0, 0, 1;
    0, 0, -1;
    1, 1, 0;
    -1, 1, 0;
    -1, -1, 0;
    1, -1, 0;
    1, 0, 1;
    -1, 0, 1;
    -1, 0, -1;
    1, 0, -1;
    0, 1, 1;
    0, -1, 1;
    0, -1, -1;
    0, 1, -1;
    1, 1, 1
    -1, 1, 1
    -1, -1, 1
    -1, 1, -1
    -1, -1, -1
    1, -1, 1
    1, -1, -1
    1, 1, -1];


%% directory paths
nrrd_img_path=[path_nodule '/nodule_radiomics/'];

%% make directory
if ~isdir(nrrd_img_path); mkdir(nrrd_img_path); end


%% saved data load or not
load_input = true;

%% get pids
filename_pid_list = [path_nodule '/dicom_pid_list.mat'];
if(fn_check_load_data(filename_pid_list, load_input))
    [dicom_path_list,pid_list]=fn_scan_pid(path_data);

    save(filename_pid_list, 'dicom_path_list', 'pid_list');
else
    load(filename_pid_list);
end

is_pass = 0;

%% main process
%for idx = randperm(numel(pid_list))
for idx = 1:numel(pid_list)
    pid = pid_list{idx};

     if strfind(pid, '0405') > 0
       is_pass = 0;
     else
       is_pass = 1;
     end

    if is_pass > 0 || sum(strfind(pid,'.')) > 0
        continue
    end

    tic % tic starts a stopwatch timer
    fprintf('%d %s\n', idx, pid);
    %% input part

    dicom_path = dicom_path_list{idx};
    [lung_img_3d, nodule_img_3d, dicom_tags, thick, pixelsize, nodule_info] = fn_dicom_read(dicom_path,pid);

    if numel(nodule_info) == 0
        continue
    end

    [nodule_img_3d, nodule_info] = fn_nodule_info_update(lung_img_3d,nodule_img_3d,nodule_info,thick,pixelsize);


    %% nrrd
    if ~isdir([nrrd_img_path '/' pid]); mkdir([nrrd_img_path '/' pid]); end
    writetable([nodule_info(:,[1:3 5:6 end 10:12 15:17]) nodule_info.Characteristics], [nrrd_img_path pid '/' pid '.csv'])

    meta = struct();
    meta.type = 'int16';
    meta.encoding = 'gzip';
    meta.spaceorigin = dicom_tags{1}.ImagePositionPatient';
    meta.spacedirections = [reshape(dicom_tags{1}.ImageOrientationPatient,3,2),[0;0;1]]*diag([pixelsize; thick]);
    meta.endian = 'little';

    fn_nrrdwrite([nrrd_img_path '/' pid '/' pid  '_CT.nrrd'], int16(lung_img_3d(:,:,end:-1:1)), meta);

    meta.type = 'uint8';
    fn_nrrdwrite([nrrd_img_path '/' pid '/' pid '_CT_all-label.nrrd'], uint8(nodule_img_3d(:,:,end:-1:1)>0), meta);
%     for sid = 1:4
%         str_sid = num2str(sid);
%         sid_nodule_image_3d =  uint8(bitand(uint8(nodule_img_3d),2^(sid-1))>0);
%         sid_nodules = strcmp(nodule_info.sid, str_sid);
%         if sum(sid_nodules) > 0
%             fn_nrrdwrite([nrrd_img_path '/' pid '/' pid '_CT_Phy' str_sid '-label.nrrd'], sid_nodule_image_3d(:,:,end:-1:1), meta)
%         end
%     end

    %% nrrd 1mm
    [interpol_lung_img_3d,interpol_nodule_img_3d]=fn_interpol3d(lung_img_3d,nodule_img_3d,thick,pixelsize,iso_px_size);

    meta.type = 'int16';
    meta.spacedirections = [reshape(dicom_tags{1}.ImageOrientationPatient,3,2),[0;0;1]];
    fn_nrrdwrite([nrrd_img_path '/' pid '/' pid  '_CT-1mm.nrrd'], int16(interpol_lung_img_3d(:,:,end:-1:1)), meta);
    meta.type = 'uint8';
    fn_nrrdwrite([nrrd_img_path '/' pid '/' pid '_CT_all-1mm-label.nrrd'], uint8(interpol_nodule_img_3d(:,:,end:-1:1)>0), meta);



    fprintf('dicom images and annotations converted ... \t\t\t %6.2f sec\n', toc);


    %% blocks
    lung_img_3d = interpol_lung_img_3d;
    nodule_img_3d = interpol_nodule_img_3d;
    meta_lung_img_3d = meta;
    sz_img_3d = size(lung_img_3d);

    lung_img_3d(lung_img_3d<-1000) = -1000;
    lung_img_3d(lung_img_3d>400) = 400;

    lung_img_3d = (double(lung_img_3d)+1000)/1400;

    meta.type = 'float';
    meta.encoding = 'gzip';
    meta.endian = 'little';

    if ~isdir(['output/' pid]); mkdir(['output/' pid]); end
    non_nodule_count = 0;
    for nid = 1:size(nodule_info,1)
        o_volume = table2array(nodule_info(nid,5));
        o_centroid = round(table2array(nodule_info(nid,8)));
        if sum(isnan(o_centroid)) > 0; continue; end

        % nodules
        for oid = 1:size(l_offset,1)
            offset = l_offset(oid,:);
            centroid = o_centroid + offset;% one voxel offset
            bbox = [centroid-16+1,centroid+16];

            if sum(bbox(1:3) < 1) > 0 || sum(bbox(4:6) > sz_img_3d) > 0
                continue
            end

            lung_blk_3d = lung_img_3d(bbox(2):bbox(5),bbox(1):bbox(4),bbox(3):bbox(6));
            nodule_blk_3d = nodule_img_3d(bbox(2):bbox(5),bbox(1):bbox(4),bbox(3):bbox(6));


            if sum(nodule_blk_3d(:))/o_volume < 0.5
                continue
            end

            %display(mean(lung_blk_3d(:)))

            meta.spaceorigin = meta_lung_img_3d.spaceorigin+bbox(1:3)-1;
            fn_nrrdwrite(['output/' pid '/' pid sprintf('_%03d_%03d_%03d',centroid([3 1 2])) '_32_N_' num2str(mean(lung_blk_3d(:)),2) '_' num2str(oid-1, '%02d') '.nrrd'], double(lung_blk_3d), meta);
            % if oid == 1
            %   for rot = 1:3
            %       fn_nrrdwrite(['output/' pid '/' pid sprintf('_%03d_%03d_%03d',centroid([3 1 2])) '_32_N_' num2str(mean(lung_blk_3d(:)),2) '_r' num2str(rot*90, '%03d') '.nrrd'], double(rot90(lung_blk_3d,rot)), meta);
            %   end
            % end
        end

        % non nodules
        for a = randn(3,round(rand()*500))
            offset = round(a'*32);
            centroid = o_centroid + offset;% background sample
            bbox = [centroid-16+1,centroid+16];
            if sum(bbox(1:3) < 1) > 0 || sum(bbox(4:6) > sz_img_3d) > 0
                continue
            end
            lung_blk_3d = lung_img_3d(bbox(2):bbox(5),bbox(1):bbox(4),bbox(3):bbox(6));
            nodule_blk_3d = nodule_img_3d(bbox(2):bbox(5),bbox(1):bbox(4),bbox(3):bbox(6));
            if  mean(nodule_blk_3d(:)) == 0 && std(lung_blk_3d(:)) ~= 0
                %display(mean(lung_blk_3d(:)))
                meta.spaceorigin = meta_lung_img_3d.spaceorigin+bbox(1:3)-1;
                fn_nrrdwrite(['output/' pid '/' pid sprintf('_%03d_%03d_%03d',centroid([3 1 2])) '_32_B_' num2str(mean(lung_blk_3d(:)),2) '.nrrd'], double(lung_blk_3d), meta);
                non_nodule_count = non_nodule_count + 1;
            end
            if non_nodule_count > 1000
                break
            end
        end
    end

    fprintf('block images saved ... \t\t\t %6.2f sec\n', toc);


    fclose all;
  end


% module rmpath
% rmpath('./io');
% rmpath('./interpolation');
% rmpath('./segmentation');
% rmpath('./nodule_candidate_detection');
