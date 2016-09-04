function [interpol_lung_img_3d,interpol_nodule_img_3d]=fn_interpol3d(lung_img_3d,nodule_img_3d,thick,pixelsize,iso_px_size)
[xnum,ynum,znum]=size(nodule_img_3d);

xsize=pixelsize(1);
ysize=pixelsize(2);


xmm=(xnum-1)*xsize;
ymm=(ynum-1)*ysize;
zmm=(znum-1)*thick;



[x,y,z]=meshgrid(0:xsize:xmm, 0:ysize:ymm, 0:thick:zmm); % origianl x y z axis ('mm'-unit)
[xi,yi,zi] = meshgrid(0:iso_px_size:xmm, 0:iso_px_size:ymm ,0:iso_px_size:zmm); % new x y z axis ('mm'-unit)


%% interpolation via two method interpolation 3d & interpolation 3d using GPU
try
    interpol_lung_img_3d=interp3_gpu(x,y,z,lung_img_3d,xi,yi,zi);
catch
    interpol_lung_img_3d=interp3(x,y,z,lung_img_3d,xi,yi,zi);
end

%% masking the results for distingushing reading sessions

interpol_nodule_img_3d=0;

for si = 1:4
    mask = (2^(si-1));
    v=single(nodule_img_3d & mask);
    
    try
        interpol_nodule_img_3d = interpol_nodule_img_3d + single(interp3_gpu(x,y,z,v,xi,yi,zi) > 0.9)*mask;
    catch
        interpol_nodule_img_3d = interpol_nodule_img_3d + single(interp3(x,y,z,v,xi,yi,zi) > 0.9)*mask;
    end
    %after interpolation method, the value is not bit function.
    %Therefore, we use '> 0.9' operator for make bit function
end

end
