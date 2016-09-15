function [nodule_candidates_img_3d]=fn_nodule_candidate_detection_multithreshold(interpol_lung_img_3d,lung_seg_img_3d)
% get image size
[ynum,xnum,znum]=size(interpol_lung_img_3d);

iso_px_size = 1;

volrate = iso_px_size^3;
arearate =  iso_px_size^2;

min_area_filt = (3/2)^2*pi;
max_area_filt = (30/2)^2*pi;
min_vol_filt = (3/2)^3*pi*(4/3);
max_vol_filt = (30/2)^3*pi*(4/3);

R = uint8(zeros(ynum,xnum));
mlung_3d = zeros(ynum,xnum,znum);
for i = 1:znum
    R(:) = 0;
    s = lung_seg_img_3d(:,:,i);
    if(i<znum/4 && sum(s(:)) < min_area_filt);
        mlung_3d(:,:,i) = -2000;
        continue;
    end
    
    I = double(interpol_lung_img_3d(:,:,i));
    T1 = (I.*double(s));
    T = (T1 + -2000*(1-double(s)));
    
    mlung_3d(:,:,i) = T;
end
clear interpol_lung_img_3d;
clear R;
clear T;
clear lung_seg_img_3d;


%% Multi-thresholding
Th_l = [-900 -800 -700 -600 -500 -400 -300 -200 -100    0  100  200];
se_l = [   0    0    0    0    1    1    1    1    1    1    1    1];
qstep = numel(Th_l);


Th_vessel = 0;


%% Thresholding
%   tic
roi_3d = uint8(zeros(ynum,xnum,znum));
for j = 1:numel(Th_l);
    se = strel('disk',se_l(j));
    roi_3d(imclose(imgaussfilt(mlung_3d,se_l(j)+0.5) > Th_l(j),se)) = j;
end
clear R;


remain_3d = false(ynum,xnum,znum);
vessel_3d = uint8(zeros(ynum,xnum,znum));

%% prunning
for k = qstep:-1:1
    %% 3D filtering
    s_3D = regionprops(bwareaopen(roi_3d>=k,round(min_area_filt/arearate)), 'BoundingBox','Centroid', 'Image', 'Area', 'PixelIdxList', 'PixelList');
    
    cn = size(s_3D,1);
    %remain_3d(:) = 0;
    
    for i = 1:cn
        s = s_3D(i);
        vol = s.Area*volrate;
        
        if(s.BoundingBox(4)*iso_px_size < 3 ...
                || s.BoundingBox(5)*iso_px_size < 3 ) % noise
            continue;
        end
        
        compactness = vol / prod(s.BoundingBox(4:6));
        
        if(vol > max_vol_filt) % vessel
            if Th_l(k) >= Th_vessel && compactness < 0.5
                vessel_3d(s.PixelIdxList) = vessel_3d(s.PixelIdxList) + 1;
            end
            continue;
        end
        
        p = fn_principal_axis_length(s.PixelList, [iso_px_size iso_px_size iso_px_size]);
        
        elongation = (p(3)*iso_px_size)/sqrt(4*vol/(pi*p(3)));
        
        if elongation > 5  && vol > min_vol_filt
            if Th_l(k) >= Th_vessel
                vessel_3d(s.PixelIdxList) = vessel_3d(s.PixelIdxList) + 1;
            end
            continue
        end
        
        if(s.BoundingBox(4)*iso_px_size > 35 ...
                || s.BoundingBox(5)*iso_px_size > 35 ) % noise
            continue;
        end
        
        overlaped = sum(vessel_3d(s.PixelIdxList)>0)/sum(s.Image(:));
        if overlaped > 0.5
            display(overlaped)
            vessel_3d(s.PixelIdxList) = vessel_3d(s.PixelIdxList) + 1;
            continue;
        end
        
        %% 2D filtering
        % select maximum area slice
        I = fn_select_max_area_slice(s.Image);
        
        [area, perimeter, r, compact, var_n] = fn_shape_feature(I,[iso_px_size iso_px_size]);
        %[area, perimeter, r, compact, var_n]
        
        %feature = [feature; s.Centroid(3) s.Centroid(1:2) s.BoundingBox(4:5)*iso_px_size s.BoundingBox(6)*iso_px_size vol elongation area, perimeter, r, compact, var_n];
        
        if(compact > 0.2 && area > min_area_filt && area < max_area_filt)
            remain_3d(s.PixelIdxList) = 1;
        end
    end
    
end

nodule_candidates_img_3d = remain_3d;

clear remain_3d;




