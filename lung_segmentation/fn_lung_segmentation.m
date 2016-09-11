function [lung_seg_img_3d,T]=fn_lung_segmentation(lung_img_3d)
% get image size
[xnum,ynum,znum]=size(lung_img_3d);

%% Tresholding
% otzu thresholding for each slice with initial threshold T
T_i=-500;
for i=1:znum
    T_n_logic_l=(lung_img_3d(:,:,i))<T_i;
    T_n_l=lung_img_3d(:,:,i).*T_n_logic_l;
    T_n_logic_h=T_n_l>-1000;
    T_n=lung_img_3d(:,:,i).*T_n_logic_h;
    
    T_b_logic_h=(lung_img_3d(:,:,i))>T_i;
    T_b_h=lung_img_3d(:,:,i).*T_b_logic_h;
    T_b_logic_l=T_b_h<1000;
    T_b=lung_img_3d(:,:,i).*T_b_logic_l;
    
    u_n=mean(T_n(:));
    u_b=mean(T_b(:));
    T_ip=(u_n+u_b)/2;
    
    if abs(T_i-T_ip)<0.3
        T_v=T_ip;
        break;
    else
        T_i=T_ip;
    end
end

T=(lung_img_3d)<T_v;


%%  lung_extraction
%get the center points
xcenter=round(xnum/2);
ycenter=round(ynum/2);
zcenter=round(znum/2);


lung_seg_label=bwlabeln(T,18); %label connected components in threshold lung images

%get the left & right side via centerpoints
lung_left=lung_seg_label(ycenter,1:xcenter,zcenter);
lung_right=lung_seg_label(ycenter,xcenter:end,zcenter);

%get the intensity value which has the most # of intensities bigger than zero.
lung_left_table=tabulate(lung_left(lung_left>0));
lung_right_table=tabulate(lung_right(lung_right>0));

%get the region grown 3d lung image
lung_seg_img_3d_rg = 0;
if numel(lung_left_table)
    lung_left_label=lung_left_table(end,1);
    lung_seg_img_3d_rg=lung_seg_img_3d_rg|(lung_seg_label==lung_left_label);
end
if numel(lung_right_table)
    lung_right_label=lung_right_table(end,1);
    lung_seg_img_3d_rg=lung_seg_img_3d_rg|(lung_seg_label==lung_right_label);
end


%% morphological process
se=strel('disk', 2); %make disk for processing the dilation
se_erode=strel('disk', 1); %make disk for processing the erosion

lung_seg_img_3d = false(size(lung_img_3d)); %initialize the segmented lung image
%morphological close and erode the lung 3d images and stack them
for z=1:znum
    lung_seg_img_3d(:,:,z) = imerode(imclose(lung_seg_img_3d_rg(:,:,z),se),se_erode);
end


%% Contour correction
for z=1:znum
    % fill the holes
    s = bwfill(lung_seg_img_3d(:,:,z),'holes');
   
    % remove cirtical section
    corrected_s = fn_remove_critical_section(s, 20); %% critical section
        
    lung_seg_img_3d(:,:,z) = corrected_s;
end


end