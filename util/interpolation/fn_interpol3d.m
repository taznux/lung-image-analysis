function [interpol_lung_img_3d,interpol_nodule_img_3d]=fn_interpol3d(lung_img_3d,nodule_img_3d,thick,pixelsize,iso_px_size)
[ynum,xnum,znum]=size(lung_img_3d);

xsize=pixelsize(1);
ysize=pixelsize(2);
iso_px_size=single(iso_px_size);
thick=single(thick);

if znum == 1
    znum = 2;
end

xmm=(xnum-1)*xsize+1;
ymm=(ynum-1)*ysize+1;
zmm=(znum-1)*thick+1;



[x,y,z]=meshgrid(1:xsize:xmm, 1:ysize:ymm, 1:thick:zmm); % origianl x y z axis ('mm'-unit)
[xi,yi,zi] = meshgrid(1:iso_px_size:xmm, 1:iso_px_size:ymm ,1:iso_px_size:zmm); % new x y z axis ('mm'-unit)


%% interpolation via two method interpolation 3d & interpolation 3d using GPU
try
    interpol_lung_img_3d=interp3_gpu(x,y,z,lung_img_3d,xi,yi,zi);
catch
    interpol_lung_img_3d=interp3(x,y,z,lung_img_3d,xi,yi,zi);
end

interpol_nodule_img_3d=0;
if numel(nodule_img_3d)
    %% masking the results for distingushing reading sessions
    for si = 1:4
        mask = (2^(si-1));
        v=single(bitand(uint8(nodule_img_3d), mask));
        
        try
            interpol_nodule_img_3d = interpol_nodule_img_3d + single(interp3_gpu(x,y,z,v,xi,yi,zi) > 0.9)*mask;
        catch
            interpol_nodule_img_3d = interpol_nodule_img_3d + single(interp3(x,y,z,v,xi,yi,zi) > 0.9)*mask;
        end
        %after interpolation method, the value is not bit function.
        %Therefore, we use '> 0.9' operator for make bit function
    end
    
end
