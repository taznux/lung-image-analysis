function [T, i]= fn_select_max_area_slice(V)
z = size(V,3);
a = zeros(z,1);
for i = 1:z
    I = V(:,:,i);
    a(i) = sum(I(:));
end
[~, ii] = sort(a);
T = V(:,:,ii(end));
end
