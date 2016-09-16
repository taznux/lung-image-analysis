function v_list=fn_nodule_segmentation_multitreshold(interpol_lung_img_3d,nodule_info,thick,pixelsize,iso_px_size)
nnum = size(nodule_info,1);

%% resample
if numel(iso_px_size)
    arearate = iso_px_size^2;
    volrate = iso_px_size^3;
else
    arearate = double(pixelsize(1)^2);
    volrate = double(arearate*thick);
end

min_area_filt = (2/2)^2*pi;
max_area_filt = (35/2)^2*pi;
min_vol_filt = (2/2)^3*pi*(4/3);
max_vol_filt = (35/2)^3*pi*(4/3);

%% Multi-thresholding
Th_l = -1000:100:1000;
qstep = numel(Th_l);


Th_vessel = 0;

v_list=cell(nnum,1);
%%
for n=1:nnum
    padding = [0 0 1];
    bbox_idx = [nodule_info.BoundingBox_idx(n,1:3)-padding nodule_info.BoundingBox_idx(n,4:6)+2*padding];
    region_idx = [bbox_idx([2,1,3]);bbox_idx([2,1,3])+bbox_idx([5,4,6])];
    if numel(iso_px_size)
        region = round((region_idx-1).*repmat([pixelsize' thick],2,1)/iso_px_size) + 1;
    else
        region = round(region_idx);
    end
    lung_img_3d_ext=interpol_lung_img_3d(region(1,1):region(2,1),region(1,2):region(2,2),region(1,3):region(2,3));
    [ynum,xnum,znum]=size(lung_img_3d_ext);
    
    %% Thresholding
    %   tic
    Th_l1 = Th_l+mean(lung_img_3d_ext(:));
    roi_3d = uint8(zeros(ynum,xnum,znum));
    for j = 1:numel(Th_l);
        se = strel('disk',1);
        roi_3d(imclose(imgaussfilt(lung_img_3d_ext,0.1) > Th_l1(j),se)) = j;
    end
    
    
    remain_3d = false(ynum,xnum,znum);
    vessel_3d = uint8(zeros(ynum,xnum,znum));
    
    %% prunning
    for k = qstep:-1:1
        %% 3D filtering
        s_3D = regionprops(bwareaopen(roi_3d>=k,round(min_area_filt/arearate)), 'BoundingBox','Centroid', 'Image', 'Area', 'PixelIdxList', 'PixelList');
        if(size(s_3D,1) == 0)
            continue;
        end
        %remain_3d(:) = 0;
       
        [~, i]=max([s_3D.Area]);
        
        s = s_3D(i);
        vol = s.Area*volrate;
        
        if s.Area / numel(roi_3d) > 0.8
            continue
        end

        if(s.BoundingBox(4)*pixelsize(1) < 3 ...
                || s.BoundingBox(5)*pixelsize(2) < 3 ) % noise
            continue;
        end

        compactness = s.Area / prod(s.BoundingBox(4:6));

        if(vol > max_vol_filt) % vessel
            if Th_l1(k) >= Th_vessel && compactness < 0.5
                vessel_3d(s.PixelIdxList) = vessel_3d(s.PixelIdxList) + 1;
            end
            continue;
        end

        p = fn_principal_axis_length(s.PixelList, [pixelsize' thick]);

        elongation = (p(3)*pixelsize(1))/sqrt(4*vol/(pi*p(3)));

        if elongation > 5  && vol > min_vol_filt
            if Th_l(k) >= Th_vessel
                vessel_3d(s.PixelIdxList) = vessel_3d(s.PixelIdxList) + 1;
            end
            continue
        end

        if(s.BoundingBox(4)*pixelsize(1) > 40 ...
                || s.BoundingBox(5)*pixelsize(2) > 40 ) % noise
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

        [area, perimeter, r, compact, var_n] = fn_shape_feature(I,pixelsize);
        %[area, perimeter, r, compact, var_n]

        %feature = [feature; s.Centroid(3) s.Centroid(1:2) s.BoundingBox(4:5)*iso_px_size s.BoundingBox(6)*iso_px_size vol elongation area, perimeter, r, compact, var_n];

        if(compact > 0.2 && area > min_area_filt && area < max_area_filt)
            remain_3d(s.PixelIdxList) = 1;
        end
        
    end
    
    %         [ nodule_edge_axis_list,np ] = fn_nodule_edge( lung_img_3d_ext );
    v=false(size(remain_3d));
    v_z=size(remain_3d,3);
    s_3D = regionprops(bwareaopen(imerode(remain_3d,se),round(min_area_filt/arearate)), 'Area', 'PixelIdxList');
    [~, i]=max([s_3D.Area]);
    if numel(i)
        v(s_3D(i).PixelIdxList)=1;
    end
    
    %for z=1:v_z
    %    new_L = fn_remove_critical_section(~v(:,:,z), 20);
    %    v(:,:,z)=v(:,:,z)+(~new_L);
    %end
    %
    %
    v_list(n)={v};
    %         ref=struct('axis_list',nodule_edge_axis_list,'num_of_point',np);
    %         ref_val(n)={ref};
    %
end


end