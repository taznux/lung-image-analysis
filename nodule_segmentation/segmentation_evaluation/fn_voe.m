function [ voe ] = fn_voe( v, ref_v )

v_sum= v+ref_v;
v_uni=v_sum>0;
v_inter=v_sum>1;

voe=(1-(sum(v_inter(:))/sum(v_uni(:))));

end

