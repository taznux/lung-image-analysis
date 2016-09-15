function [ ravd ] = fn_ravd( v, ref_v )

ravd=abs(sum(v(:)-ref_v(:)))/sum(ref_v(:));

end

