function [ nodule_edge_axis_list,np ] = fn_nodule_edge( interpol_nodule_img_3d_ext )
%% make nodule edge image from nodule 3d image
[x_n,y_n,z_n]=size(interpol_nodule_img_3d_ext);
nodule_edge=zeros(x_n,y_n,z_n);

for edn=1:z_n
    nodule_edge(:,:,edn)=edge(interpol_nodule_img_3d_ext(:,:,edn),'canny');
end
%% get x ,y, z axis

np=sum(nodule_edge(:));
nodule_edge_axis_list=zeros(np,3);

m=0;
for i=1:z_n
    [y,x]= find(nodule_edge(:,:,i)==1);
    if sum(y)>0&&sum(x)>0
        l=size(y,1);
        for j=1:l
            nodule_edge_axis_list(j+m,:)=[x(j) y(j) i];
        end
        m=m+l;
    end
    
end

end

