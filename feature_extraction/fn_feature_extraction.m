function [ nodule_candidates_features ] = fn_feature_extraction(pid, nodule_candidates_morphology_img_3d, interpol_lung_img_3d, iso_px_size)
    % simple image features from regionprops
    nodule_candidates_region_features=regionprops(nodule_candidates_morphology_img_3d>0, interpol_lung_img_3d, ...
    'Area','Centroid','BoundingBox','SubarrayIdx','FilledImage','FilledArea','PixelIdxList','PixelList', ... 
    'PixelValues','WeightedCentroid','MeanIntensity','MinIntensity','MaxIntensity');
    
    nnum = size(nodule_candidates_region_features,1);
    
    nodule_candidates_features = table;
    nodule_candidates_features.pid = repmat(pid, nnum,1);
    nodule_candidates_features.nid = (1:nnum)';
    nodule_candidates_features.hit = false(nnum,1);
    
    for n=1:nnum
        nodule_candidates_region_features(n).Area = nodule_candidates_region_features(n).Area*iso_px_size^3;% acctually volume
        nodule_candidates_region_features(n).BoundingBox = nodule_candidates_region_features(n).BoundingBox*iso_px_size;
        nodule_candidates_region_features(n).Centroid = nodule_candidates_region_features(n).Centroid*iso_px_size;
        nodule_candidates_region_features(n).FilledArea = nodule_candidates_region_features(n).FilledArea*iso_px_size;
        nodule_candidates_region_features(n).WeightedCentroid = nodule_candidates_region_features(n).WeightedCentroid*iso_px_size;
    end
    
    nodule_candidates_features = [nodule_candidates_features struct2table(nodule_candidates_region_features)];
end

