function [nodule_img_3d nodule_info] = fn_nodule_info(lung_img_3d,pid,dicom_tags,filename)

%% unblinded read nodule
num=size(dicom_tags,2);
%% get the images thick & pixelsize
thick = abs((dicom_tags{end}.ImagePositionPatient(3) - dicom_tags{1}.ImagePositionPatient(3))/(num - 1));
%     thick = dicom_tags.SliceThickness;
pixelsize = dicom_tags{1}.PixelSpacing;

px_xsize=pixelsize(2);
px_ysize=pixelsize(1);

%% get nodule infomation(xml file)

xDoc = xmlread(filename); %xDoc = xml file load, and then save them.
xRoot = xDoc.getDocumentElement; % xDoc's nodes call and save.
root = xRoot.getChildNodes; % xRoot's chile nodes call and save.

sessions = root.getElementsByTagName('readingSession');
sn = sessions.getLength; %one xml file's # of reading session

%% initializing the value
nodule_info = [];
cc = [];

nodule_img_3d = zeros(size(lung_img_3d));

%% get the nodule 3d image & information

for si = 1:sn
    %         cc=[cc, cc_in];
    session = sessions.item(si - 1); %sessions informations store
    
    nodules = session.getElementsByTagName('unblindedReadNodule'); %unblindedReadNodule's elements store
    n = nodules.getLength; % # of unblindedreadnodule in one of reading sessions
    
    % initializing the values
    
    
    nodule_characteristic = struct('subtlety',0,'internalstruc',0,'calcification',0,'sphericity',0,'margin',0,...
        'lobulation',0,'spiculation',0,'texture',0,'malignancy',0); % store the nodule's characteristic by using structure shape
    
    
    for i = 1:n
        nodule_img_3d_in = zeros(size(lung_img_3d));
        
        nodule = nodules.item(i - 1);
        id = nodule.getElementsByTagName('noduleID');
        id = char(id.item(0).getTextContent);%id = noduleID values store,
        %noduleID: Nodule numbers or
        %noduleID: numbers
        %ex) noduleID: Nodule 001 or
        %    noduleID: 1514
        if size(str2num(id),1) == 0
            [aid bid] = strtok(id, ' '); %% get the numbers in noduleID
            id = bid;
        end
        
        id = 100000 * si + str2num(id);
        %final nodule id(first: human & last things nodule id)
        
        
        % get the roi elements & # of them in nodule
        rois = nodule.getElementsByTagName('roi'); % 'roi' is edge map (x&y-coordinate values)
        m = rois.getLength; % # of roi elements
        
        
        %% extract characteristics
        
        ch =  nodule.getElementsByTagName('characteristics'); % characteristics elements store
        
        c = nodule_characteristic; % use initial value which we made before via structure shape
        
        %
        if ch.getLength > 0 &&m>1
            sub = ch.item(0).getElementsByTagName('subtlety');
            c.subtlety = str2num(sub.item(0).getTextContent);
            
            int = ch.item(0).getElementsByTagName('internalStructure');
            c.internalstrue = str2num(int.item(0).getTextContent);
            
            cal = ch.item(0).getElementsByTagName('calcification');
            c.calcification = str2num(cal.item(0).getTextContent);
            
            sph = ch.item(0).getElementsByTagName('sphericity');
            c.sphericity = str2num(sph.item(0).getTextContent);
            
            mar = ch.item(0).getElementsByTagName('margin');
            c.margin = str2num(mar.item(0).getTextContent);
            
            lob = ch.item(0).getElementsByTagName('lobulation');
            c.lobulation = str2num(lob.item(0).getTextContent);
            
            spi = ch.item(0).getElementsByTagName('spiculation');
            c.spiculation = str2num(spi.item(0).getTextContent);
            
            tex = ch.item(0).getElementsByTagName('texture');
            c.texture = str2num(tex.item(0).getTextContent);
            
            mal = ch.item(0).getElementsByTagName('malignancy');
            c.malignancy = str2num(mal.item(0).getTextContent);
        else
            c.subtlety =0;
            c.internalstruc =0;
            
        end
        % this 'if statement' can store the values in 'c structure'.
        %             cc(i) = c;
        
        %initializing the values
        
        l_Mx = [];
        l_mx = [];
        l_My = [];
        l_my = [];
        l_z = [];
        %
        
        
        
        
        
        % get roi coordinate , uid, inclusion values
        for j = 1:m
            roi = rois.item(j-1);
            xx = roi.getElementsByTagName('xCoord');
            yy = roi.getElementsByTagName('yCoord');
            uid = roi.getElementsByTagName('imageSOP_UID');
            uid = char(uid.item(0).getTextContent);
            zpos=roi.getElementsByTagName('imageZposition');
            zpos=char(zpos.item(0).getTextContent);
            inc = roi.getElementsByTagName('inclusion');
            inc = char(inc.item(0).getTextContent);
            if(strcmp(inc,'FALSE')) %if inclusion is FALSE = nodule does not exist.
                continue;
            end
            
            mm = xx.getLength; % # of x-coordinate values is one of rois
            x = zeros(1,mm);
            y = zeros(1,mm);
            for k = 1:mm
                x(k) = str2num(xx.item(k-1).getTextContent); % x-coordinates of a piece of rois store
                y(k) = str2num(yy.item(k-1).getTextContent); % y-coordinates of a piece of rois store
            end
            
            % maximum & minimum values from x & y-coordinates stored
            
            Mx = max(x);
            mx = min(x);
            My = max(y);
            my = min(y);
            
            
            % get the z values from uid in dicom_tags
            z = fn_uid_to_zindex(uid,dicom_tags,zpos);
            
            %nodule images stack via z values & x,y values
            nodule_img_3d_in(:,:,z) = nodule_img_3d_in(:,:,z)|double(poly2mask(x',y',512,512));
            
            
        end
        
        if sum(nodule_img_3d_in(:)) > 0
            
            nodule_region_values=regionprops(nodule_img_3d_in,lung_img_3d,'WeightedCentroid','Area','BoundingBox');
            
            nodule_area=[nodule_region_values.Area];
            
            [~ , i_r] =max(nodule_area);
            
            
            
            nodule_centroid=nodule_region_values(i_r).WeightedCentroid;
            nodule_boundingbox=nodule_region_values(i_r).BoundingBox;
            
            
            nodule_centroid_mm=(nodule_centroid-1).*[px_xsize px_ysize thick];
            nodule_boundingbox_mm=nodule_boundingbox.*[px_xsize px_ysize thick px_xsize px_ysize thick];
            
            nodule = struct('pid', pid, 'nid', id, 'characteristic',c,'centroid',nodule_centroid, 'boundingbox',nodule_boundingbox,'centroid_mm',nodule_centroid_mm, 'boundingbox_mm',nodule_boundingbox_mm,'hit',0);
            
            nodule_info = [nodule_info; nodule] ;
            
            nodule_img_3d=nodule_img_3d+nodule_img_3d_in.*(2^(si-1)); % add binary weight values, for easy to comparing reading session
        else
            
        end
        
        
    end
    
end
end

