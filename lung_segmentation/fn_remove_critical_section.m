function new_L = fn_remove_critical_section(L, r)  
    b = bwboundaries(L);
    [xnum,ynum] = size(L);
    
    new_L = zeros(size(xnum,ynum));
    
    for rpath = b'
        path = rpath{1};
        if size(path, 1) < 100 %% 
            %new_L = new_L | poly2mask(path(:,2),path(:,1),xnum,ynum);
            continue;
        end
        
        dpath = diff(path);
        t = zeros(size(dpath,1),1);
        for i = 1:size(dpath,1)
            if dpath(i,:) == [1 0]
                t(i) = 0;
            elseif dpath(i,:) == [1 1]
                t(i) = 1;
            elseif dpath(i,:) == [0 1]
                t(i) = 2;
            elseif dpath(i,:) == [-1 1]
                t(i) = 3;
            elseif dpath(i,:) == [-1 0]
                t(i) = 4;
            elseif dpath(i,:) == [-1 -1]
                t(i) = 5;
            elseif dpath(i,:) == [0 -1]
                t(i) = 6;
            elseif dpath(i,:) == [1 -1]
                t(i) = 7;
            end
        end
        
        t = t*pi/4;
        %t = smooth(t);
        t = medfilt1(t,3);
        dt = asin(sin(diff(t)));
        %dt = smooth(dt);
        %dt = medfilt1(dt,3);
       
        crs = abs(dt) > 0.5;
        crs = [true(1); crs];
        
        path(crs,3) = find(crs);
        
%         cr_path = path(crs,:);
%         plot(path(:,2),path(:,1)); hold on;
%         plot(cr_path(:,2),cr_path(:,1),'r.');

        if(sum(crs) == 0)
            continue;
        end
        new_path = path_reduce(path, L, r);

%         plot(new_path(:,2),new_path(:,1),'y');
        new_L = new_L | poly2mask(new_path(:,2),new_path(:,1),xnum,ynum) | poly2mask(path(:,2),path(:,1),xnum,ynum);
    end
end

function new_path = path_reduce(path, L, r)
    rot_c90 = [cos(pi/2) -sin(pi/2); sin(pi/2) cos(pi/2)];
    rot_cc90 = [cos(-pi/2) -sin(-pi/2); sin(-pi/2) cos(-pi/2)];
    
    cr_path = path(path(:,3)>0,:);
    
    Y = pdist(cr_path(:,1:2));
    S = squareform(Y);
    %R = tril(triu(S,2)),round(r));
    R = triu(S);
    T = (R < r & R > 2);

    [r c] = find(T);  
    t = [r c];
    
    new_path = path;

    for x = t'
        %x(1) start
        %x(2) end
%         if(R(x(1), x(2)) > r | R(x(1), x(2)) < 2)
%             R(x(1), x(2))
%         end
        s = cr_path(x(1),1:2);
        e = cr_path(x(2),1:2);
        
        m = (s + e)/2;
        
        ee = (e - m)/2;
        
        c1 = round((rot_c90 * ee')' + m);
        c2 = round((rot_cc90 * ee')' + m);
        
        try
            if(L(c1(1), c1(2)) || L(c2(1), c2(2)))
                %'in'
            else
                %'out'
                %mx = min(x(1),x(2));
                %Mx = max(x(1),x(2));
                range = cr_path(x(1),3)+1:cr_path(x(2),3)-1;
                if size(range,2) > size(path,1)/2
                    range = [1:cr_path(x(1),3)+1 cr_path(x(2),3)-1:size(path,1)];
                end
                
                for k = range
                    new_path(k,1:2) = [0 0];
                end
                %x(2) - x(1)
            end
        catch
            lasterr
        end
    end
    
    new_path2 = [];

    for x = new_path'
        if(x(1) == 0 & x(2) == 0)
        else
            new_path2 = [new_path2; x'];
        end
    end
    if size(new_path2) ~= 0
        new_path = new_path2(:,1:2);
    end
end