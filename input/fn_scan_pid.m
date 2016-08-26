function [dicom_path_list,pid_list]=fn_scan_pid(path_data)

dirlist = dir(path_data);
dirnum = size(dirlist,1);

dicom_path_list = cell(0);
pid_list= cell(0);

j = 1;

%% get directory lists

for idx = 1:dirnum
    if dirlist(idx).name(1) == '.' || strcmp(dirlist(idx).name, '.') || strcmp(dirlist(idx).name, '..')
        continue
    end
    pid = dirlist(idx).name;
    patient_path = [path_data '/' dirlist(idx).name];
    file = dir(patient_path);
    nn = size(file, 1);
    pid_list{j}=pid;
    
    
    for idx1 = 1:nn
        if file(idx1).name(1) == '.' || strcmp(file(idx1).name, '.') || strcmp(file(idx1).name, '..')
            continue
        end
        study_path = [patient_path '/' file(idx1).name];
        file1 = dir([study_path '/*']);
        nn = size(file1, 1);
        for idx2 = 1:nn
            if file1(idx2).name(1) == '.' || strcmp(file1(idx2).name, '.') || strcmp(file1(idx2).name, '..')
                continue
            end
            serise_path = [study_path '/' file1(idx2).name '/'];
            
            dicom_path_list{j} = serise_path; % get the last directory lists
            j = j+1;
        end
    end
end

end