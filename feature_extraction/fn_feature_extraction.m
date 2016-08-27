function [ nodule_candidates_features ] = fn_feature_extraction(pid, nodule_candidates_morphology_img_3d, interpol_lung_img_3d, iso_px_size)
% simple image features from regionprops
nodule_candidates_region_features = regionprops(nodule_candidates_morphology_img_3d>0, interpol_lung_img_3d, ...
    'Area','FilledArea','Centroid','BoundingBox','WeightedCentroid', ...
    'MeanIntensity','MinIntensity','MaxIntensity','Image','FilledImage', ...
    'SubarrayIdx','PixelIdxList','PixelList','PixelValues');

nnum = size(nodule_candidates_region_features,1);

nodule_candidates_features = table;
nodule_candidates_features.pid = mat2cell(repmat(pid, nnum,1), ones(nnum,1));  
nodule_candidates_features.nid = (1:nnum)';
nodule_candidates_features.hit = zeros(nnum,1);

nodule_candidates_features.Volume = [nodule_candidates_region_features.Area]'*iso_px_size^3;
nodule_candidates_features.FilledVolume = [nodule_candidates_region_features.FilledArea]'*iso_px_size^3;

nodule_candidates_features.BoundingBox = cell2mat({nodule_candidates_region_features.BoundingBox}')*iso_px_size;
nodule_candidates_features.Centroid = cell2mat({nodule_candidates_region_features.Centroid}')*iso_px_size;
nodule_candidates_features.WeightedCentroid = cell2mat({nodule_candidates_region_features.WeightedCentroid}')*iso_px_size;

nodule_candidates_features.MeanIntensity=[nodule_candidates_region_features.MeanIntensity]';
nodule_candidates_features.MinIntensity=[nodule_candidates_region_features.MinIntensity]';
nodule_candidates_features.MaxIntensity=[nodule_candidates_region_features.MaxIntensity]';

nodule_candidates_features.Image={nodule_candidates_region_features.Image}';
nodule_candidates_features.FilledImage={nodule_candidates_region_features.FilledImage}';

nodule_candidates_features.SubarrayIdx={nodule_candidates_region_features.SubarrayIdx}';
nodule_candidates_features.PixelIdxList={nodule_candidates_region_features.PixelIdxList}';
nodule_candidates_features.PixelList={nodule_candidates_region_features.PixelList}';
nodule_candidates_features.PixelValues={nodule_candidates_region_features.PixelValues}';

end

