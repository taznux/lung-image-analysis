function [nodule_candidates_morphology_img_3d]=fn_nodule_candidate_detection(interpol_lung_img_3d,lung_seg_img_3d)
se=strel('disk', 1);

%% get the seed points
nodule_sub_img_3d=(lung_seg_img_3d.*(interpol_lung_img_3d>-900)).*(interpol_lung_img_3d+1000);
nodule_peak_img_3d=((nodule_sub_img_3d-smooth3(nodule_sub_img_3d,'gaussian',[5 5 5], 3)));

%extracted_lung_3d_img = (lung_seg_img_3d.*interpol_lung_img_3d - ~lung_seg_img_3d*2000);
nodule_candidates = imdilate(nodule_peak_img_3d, se)>200;
cc = bwconncomp(nodule_candidates);
s = regionprops(cc, 'Centroid', 'Area', 'BoundingBox');
%p = floor(reshape([s.Centroid], 3, size(s,1))');
bbox = reshape([s.BoundingBox],6,numel(s));
sel = [s.Area] > 10 & max(bbox(4:5,:))./min(bbox(4:5,:)) < 4;

cc.NumObjects = sum(sel);
cc.PixelIdxList = cc.PixelIdxList(sel);

L = labelmatrix(cc);

nodule_candidates_morphology_img_3d = L > 0;
end