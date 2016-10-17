function [nodule_img_3d, nodule_info] = fn_nodule_info_update(lung_img_3d,nodule_img_3d,nodule_info,thick,pixelsize)
px_xsize=pixelsize(2);
px_ysize=pixelsize(1);

nodule_info.SolidVolume = zeros(size(nodule_info.Volume));

%% get the nodule 3d image & information
for ni = 1:height(nodule_info)
    nodule = nodule_info(ni,:);
    
    padding = [0 0 1];
    bbox_idx = [nodule.BoundingBox_idx(1:3)-padding nodule.BoundingBox_idx(4:6)+2*padding];
    region_idx = [bbox_idx([2,1,3]);bbox_idx([2,1,3])+bbox_idx([5,4,6])];
    region = round(region_idx);

    bbox = [region(1,[2,1,3]),region(2,[2,1,3])-region(1,[2,1,3])];
    
    lung_img_3d_ext=lung_img_3d(region(1,1):region(2,1),region(1,2):region(2,2),region(1,3):region(2,3));
    nodule_img_3d_ext=nodule_img_3d(region(1,1):region(2,1),region(1,2):region(2,2),region(1,3):region(2,3));
    
    nodule_region_values=regionprops(nodule_img_3d_ext>0,lung_img_3d_ext, ...
                'Area','FilledArea','Centroid','BoundingBox','WeightedCentroid', ...
                'MeanIntensity','MinIntensity','MaxIntensity','Image','FilledImage', ...
                'SubarrayIdx','PixelIdxList','PixelList','PixelValues');
            
    nodule_area=[nodule_region_values.Area];

    [~ , i_r] = max(nodule_area);

    solidRatio = sum(nodule_region_values(i_r).PixelValues>-700)/numel(nodule_region_values(i_r).PixelValues);
    nodule.SolidVolume = nodule.Volume*solidRatio;
    
    nodule_info(ni,:) = nodule;

%     nodule.Volume = nodule_region_values(i_r).Area*px_xsize*px_ysize*thick;% acctually volume
%     nodule.FilledVolume = nodule_region_values(i_r).FilledArea*px_xsize*px_ysize*thick;
%     nodule.BoundingBox = (nodule_region_values(i_r).BoundingBox-1).*[px_xsize px_ysize thick px_xsize px_ysize thick]+1;
%     nodule.Centroid = (nodule_region_values(i_r).Centroid-1).*[px_xsize px_ysize thick]+1;
%     nodule.WeightedCentroid = (nodule_region_values(i_r).WeightedCentroid-1).*[px_xsize px_ysize thick]+1;
% 
%     nodule.MeanIntensity=nodule_region_values(i_r).MeanIntensity;
%     nodule.MinIntensity=nodule_region_values(i_r).MinIntensity;
%     nodule.MaxIntensity=nodule_region_values(i_r).MaxIntensity;
% 
%     nodule.Image={nodule_region_values(i_r).Image};
%     nodule.FilledImage={nodule_region_values(i_r).FilledImage};
% 
%     nodule.Centroid_idx=nodule_region_values(i_r).Centroid;
%     nodule.WeightedCentroid_idx=nodule_region_values(i_r).WeightedCentroid;
%     nodule.BoundingBox_idx=nodule_region_values(i_r).BoundingBox;
% 
%     nodule.SubarrayIdx={nodule_region_values(i_r).SubarrayIdx};
%     nodule.PixelIdxList={nodule_region_values(i_r).PixelIdxList};
%     nodule.PixelList={nodule_region_values(i_r).PixelList};
%     nodule.PixelValues={nodule_region_values(i_r).PixelValues};

%     nodule.Characteristics = c;
end
end

