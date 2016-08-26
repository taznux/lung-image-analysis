function [ completed ] = fn_check_load_data(filename_data, flag_load_data)
% filename_data
% flag_load_data : default true
%
% return 
%  0 : works well
% -1 : flag is false
% -2 : data file is not exist

    if nargin < 2
        flag_load_data == true;
    end
    
    
    if flag_load_data == false
        completed = -1;
    else
        fid = fopen(filename_data, 'r');
        if fid > 0 
            completed = 0;
        else
            completed = -2;
        end       
    end
end
