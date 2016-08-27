function [nodule_candidates_morphology_img_3d]=fn_nodule_candidate_detection(interpol_lung_img_3d,lung_seg_img_3d)
%% get the seed points
nodule_sub_img_3d=(lung_seg_img_3d.*(interpol_lung_img_3d>-700)).*(interpol_lung_img_3d+1000);
nodule_peak_img_3d=((nodule_sub_img_3d-smooth3(nodule_sub_img_3d,'gaussian',[5 5 5], 3)));

%extracted_lung_3d_img = (lung_seg_img_3d.*interpol_lung_img_3d - ~lung_seg_img_3d*2000);
cc = bwconncomp(nodule_peak_img_3d>0);
s = regionprops(cc, 'Centroid', 'Area');
%p = floor(reshape([s.Centroid], 3, size(s,1))');
sel = [s.Area] > 10;

cc.NumObjects = sum(sel);
cc.PixelIdxList = cc.PixelIdxList(sel);

L = labelmatrix(cc);

nodule_candidates_morphology_img_3d = L > 0;
end