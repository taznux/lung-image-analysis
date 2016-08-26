function [nodule_candidates_features nodule_info]=fn_evaluation(nodule_candidates_features,nodule_info,min_resolution)
cnum= size(nodule_candidates_features,1);
nnum= size(nodule_info,1);

%     evaluation_result=[];
num_of_nodule_info=[];
max_resolution=min_resolution*2;

for j=1:nnum
    for i=1:cnum
        evaluations=sqrt(sum((nodule_candidates_features.Centroid(i,:)-nodule_info.centroid_mm(1,:)).^2));
        %             evaluation_result=[evaluation_result;evaluations];
        if evaluations < max_resolution
            num_of_nodule_info=[num_of_nodule_info;i,j];
            nodule_candidates_features(i,2)=nodule_candidates_features(i,2)+1;
            nodule_info.hit(j)=nodule_info.hit(j)+1;
        else
            continue;
        end
    end
end






end