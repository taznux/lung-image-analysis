function [ assd ] = fn_assd( nodule_edge_axis_list,mass_pos,np )
n_mp=size(mass_pos,1);
dist_min_list=pdist2(nodule_edge_axis_list,mass_pos);
col_num=size(dist_min_list,1);
row_num=size(dist_min_list,2);
col_min=0;
row_min=0;

for i=1:col_num
    col_min=col_min+min(dist_min_list(i,:));
end

for j=1:row_num
    row_min=row_min+min(dist_min_list(:,j));
end
    assd=(col_min+row_min)/(np+n_mp);
end

