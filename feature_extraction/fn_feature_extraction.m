function [ nodule_candidates_features ] = fn_feature_extraction(pid, nodule_candidates_morphology_img_3d, interpol_lung_img_3d, iso_px_size)
    

    nodule_candidates_region_features=regionprops(nodule_candidates_morphology_img_3d>0, interpol_lung_img_3d,'all');
    
    fnum=size(nodule_candidates_region_features,1);
    
    felements=7;
    
    nodule_candidates_features=zeros(fnum,felements+1);
    nodule_candidates_features(:,1) = pid;
    nodule_candidates_features(:,2) = 0;
    
    for f=1:fnum
        nodule_candidates_features(f,3:5)=(nodule_candidates_region_features(f).WeightedCentroid-1)*iso_px_size;
        nodule_candidates_features(f,6:8)=(nodule_candidates_region_features(f).BoundingBox(4:6))*iso_px_size;
    end


end

