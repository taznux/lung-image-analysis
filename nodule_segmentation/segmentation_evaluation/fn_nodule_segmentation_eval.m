function [ ravd,voe,assd,v_r_list,lung_ext_list ] = fn_nodule_segmentation_eval(interpol_nodule_img_3d,interpol_lung_img_3d,nodule_info,thick,pixelsize,iso_px_size,s,v)
nnum = size(nodule_info,1);

ravd=zeros(nnum,1);
voe=zeros(nnum,1);
assd=zeros(nnum,1);
v_r_list=cell(nnum,1);
lung_ext_list=cell(nnum,1);

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
    nodule_img_3d_ext=interpol_nodule_img_3d(region(1,1):region(2,1),region(1,2):region(2,2),region(1,3):region(2,3));
    nodule_img_3d_ext=single(bitand(uint8(nodule_img_3d_ext),2^(str2double(nodule_info.sid(n))-1)));
        
    v_c=v{n,1};
    [ nodule_edge_axis_list,np ] = fn_nodule_edge( nodule_img_3d_ext );
    if numel(s)
        mass_pos=s{n,1}.vertices;
    else
        [ mass_pos,np ] = fn_nodule_edge( v_c );
    end
    
    if np == 0
      assd(n) = 0;
    else
        [ assd(n) ] = fn_assd( nodule_edge_axis_list,mass_pos,np );
    end
    
    [ voe(n) ] = fn_voe( v_c,nodule_img_3d_ext );
    [ ravd(n) ] = fn_ravd( v_c,nodule_img_3d_ext );
    
    v_z=size(v_c,3);
    v_r=zeros(size(v_c));
    
    for z=1:v_z
        v_r(:,:,z)=edge(v_c(:,:,z),'canny');
    end
    
    v_r_list{n,1}=v_r;
    lung_ext_list{n,1}=lung_img_3d_ext;
    
end

end

