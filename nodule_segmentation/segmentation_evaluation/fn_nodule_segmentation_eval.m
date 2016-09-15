function [ ravd,voe,assd,v_r_list,lung_ext_list ] = fn_nodule_segmentation_eval(nodule_img_3d,lung_img_3d,nodule_info,thick,pixelsize,iso_px_size,s,v)
nnum = size(nodule_info,1);

ravd=zeros(nnum,1);
voe=zeros(nnum,1);
assd=zeros(nnum,1);
v_r_list=cell(nnum,1);
lung_ext_list=cell(nnum,1);

for n=1:nnum
    padding = [0 0 1];
    bbox = round(nodule_info.BoundingBox_idx(n,:));
    region = [bbox([2,1,3])-padding;bbox([2,1,3])+bbox([5,4,6])+padding];
    lung_img_3d_ext_o=lung_img_3d(region(1,1):region(2,1),region(1,2):region(2,2),region(1,3):region(2,3));
    nodule_img_3d_ext_o=nodule_img_3d(region(1,1):region(2,1),region(1,2):region(2,2),region(1,3):region(2,3));
    nodule_img_3d_ext_o=single(bitand(uint8(nodule_img_3d_ext_o),2^(str2double(nodule_info.sid(n))-1)));
    
    %% upsampling
    if numel(iso_px_size)
        [lung_img_3d_ext,nodule_img_3d_ext]=fn_interpol3d(lung_img_3d_ext_o,nodule_img_3d_ext_o,thick,pixelsize,iso_px_size);
        thick=iso_px_size;
        pixelsize(:)=iso_px_size;
    else
        lung_img_3d_ext=lung_img_3d_ext_o;
        nodule_img_3d_ext=nodule_img_3d_ext_o;
    end
    
    v_c=v{n,1};
    if numel(s)
        mass_pos=s{n,1}.vertices;
        [ assd(n) ] = fn_assd( nodule_edge_axis_list,mass_pos,np );
    end
    
    [ voe(n) ] = fn_voe( v_c,nodule_img_3d_ext );
    [ ravd(n) ] = fn_ravd( v_c,nodule_img_3d_ext );
    
    [ nodule_edge_axis_list,np ] = fn_nodule_edge( nodule_img_3d_ext );
    
    
    v_z=size(v_c,3);
    v_r=zeros(size(v_c));
    
    for z=1:v_z
        v_r(:,:,z)=edge(v_c(:,:,z),'canny');
    end
    
    v_r_list{n,1}=v_r;
    lung_ext_list{n,1}=lung_img_3d_ext;
    
end

end

