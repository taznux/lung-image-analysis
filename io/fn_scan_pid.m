function [dicom_path_list,pid_list]=fn_scan_pid(path_data)

dirlist = dir(path_data);
dirnum = size(dirlist,1);

dicom_path_list = cell(0);
pid_list= cell(0);

j = 1;
%% get directory lists

for idx = 1:dirnum
    if dirlist(idx).name(1) == '.'
        continue
    end
    pid = dirlist(idx).name;
    patient_path = [path_data '/' dirlist(idx).name '/'];
    file = dir(patient_path);
    nn = size(file, 1);
    k = 0;
    
    for idx1 = 1:nn
        if file(idx1).name(1) == '.'
            continue
        end
        study_path = [patient_path '/' file(idx1).name '/'];
        file1 = dir(study_path);
        nn = size(file1, 1);
        for idx2 = 1:nn
            if file1(idx2).name(1) == '.'
                continue
            end
            serise_path = [study_path '/' file1(idx2).name '/'];
            
            dcms = dir([serise_path '*.dcm']); %get the *.dcm files
            
            dcm_tag = dicominfo([serise_path dcms(1).name]);
            
            if isfield(dcm_tag, 'ImagePositionPatient') || strcmp(dcm_tag.Modality, 'CT')
                if k == 0
                    pid_list{j}=pid;
                else
                    pid_list{j}=[pid '-' num2str(k)];
                end
                dicom_path_list{j} = serise_path; % get the last directory lists
                j = j+1;
                k = k+1;
            end
        end
    end
end

end