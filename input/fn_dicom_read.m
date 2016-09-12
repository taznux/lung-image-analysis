function [lung_img_3d, nodule_img_3d, dicom_tags, thick, pixelsize, nodule_info] = fn_dicom_read(ipath,pid)

%% get dcm files and # of files

dcms = dir([ipath '*.dcm']); %get the *.dcm files
num = size(dcms, 1);


%% load dicom
dicom_tags = cell(num,1);
for i = 1:num
    dicom_tags{i} = dicominfo([ipath dcms(i).name]); %%get the dcm files information
end




%% sorting
for i = 1:num
    for j = i+1:num
        if dicom_tags{i}.ImagePositionPatient(3) < dicom_tags{j}.ImagePositionPatient(3)
            temp = dicom_tags{i};
            dicom_tags{i} = dicom_tags{j};
            dicom_tags{j} = temp;
        end
    end
end


%% get the images thick & pixelsize
thick = single(abs((dicom_tags{end}.ImagePositionPatient(3) - dicom_tags{1}.ImagePositionPatient(3))/(num - 1)));
%     thick = dicom_tags.SliceThickness;
pixelsize = single(dicom_tags{1}.PixelSpacing);


%% get the nodule 3d img & lung 3d img
lung_img_3d = single(ones(512,512,num)) * -2000; % for mathching HU field.

for i = 1:num
    I = int16(single(dicomread(dicom_tags{i})) + dicom_tags{i}.RescaleIntercept); % HU= SV*Rescaleslope+RescaleIntercept , SV=stored value
    lung_img_3d(:,:,i) = I; % lung_3d = 512x512 ct image.
end

%% LIDC xml parsing if exist the file in the series folder
file = dir([ipath '*.xml']); % xml file information is stored by using structure shape (name,date...)
if size(file, 1) > 0
    filename = [ipath file(1).name]; % xml file path
    
    % nodule information
    [nodule_img_3d, nodule_info] = fn_nodule_info(lung_img_3d,pid,dicom_tags,filename);
else
    nodule_img_3d = zeros(size(lung_img_3d));
    nodule_info = [];
end


end


