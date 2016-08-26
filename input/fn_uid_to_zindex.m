function z = fn_uid_to_zindex(uid,dicom_tags,zpos)

    num = numel(dicom_tags);
    
    % When the dicom_tags's SOPInstanceUID values are equal to uid values
    % k value store in z
    for k = 1:num
        if (dicom_tags{k}.ImagePositionPatient(3)==str2num(zpos))||strcmp(dicom_tags{k}.SOPInstanceUID, uid)
            z = k;  
            break;
        end
    end
end