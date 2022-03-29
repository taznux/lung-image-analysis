function ok = fn_nrrdwrite(filename, matrix, meta)
% fn_nrrdwrite
%   ok = fn_nrrdwrite(filename, matrix, meta) writes the image volume and associated
%   metadata to the NRRD-format file specified by filename.
% 
% filename  - 'myimage.ext' - 'veins.nrrd'
% matrix    - data - Matlab matrix
% meta      - meta data of image
% ex) meta = 
%                   type: 'float'
%              dimension: '4'
%                  space: 'left-posterior-superior'
%                  sizes: '3 129 127 40'
%        spacedirections: 'none (1.1718999999999999,0,0) (0,1.1718999999999999,0) (0,0,4)'
%                  kinds: 'vector domain domain domain'
%                 endian: 'little'
%               encoding: 'raw'
%            spaceorigin: '(-59.179699999999997,-74.414100000000005,-24)'
%    itk_inputfiltername: 'NrrdImageIO'
%
% original code from https://www.mathworks.com/matlabcentral/fileexchange/48621-nrrdwriter-filename--matrix--pixelspacing--origin--encoding-
% 
% It was modified to support 4D deformation vector field with meta data
% structure by Wookjin Choi March 2016.
%

% This line gets the path, name and extension of our file:
% pathf = /home/mario/.../myfile.myext
% fname = myfile
% ext = .myext
[pathf, fname, ext] = fileparts(filename);

format=ext(2:end); % We remove the . from .ext

% so we extract the output format from the argument filename, instead of
% put two different arguments
dims=(size(matrix));    % matrix dimensions (size NxMxP)
ndims=length(dims);     % number of dimensions (dim n)
if ndims <= 3
    matrix = permute(matrix, [2 1 3]); % so we undo permute of index in nrrdreader
elseif isequal (ndims, 4)
    matrix = permute(matrix, [1 3 2 4]); % so we undo permute of index in nrrdreader
end
dims=(size(matrix));    % matrix dimensions (size NxMxP)
ndims=length(dims);     % number of dimensions (dim n)


meta.sizes = sprintf('%d ',dims);
meta.dimension = sprintf('%d',ndims);

% Get the size of the data.
assert(isfield(meta, 'encoding') && ...
       isfield(meta, 'spaceorigin') && ...
       isfield(meta, 'spacedirections') && ...
       isfield(meta, 'endian'), ...
       'Missing required metadata fields.')

% =====================================================================
% Conditions to make sure our file is goint to be created succesfully.
% 
% First the code puts the argument 'encoding' in lowercase
encoding = lower(meta.encoding);

encodingCond = isequal(encoding, 'ascii') || isequal(encoding, 'raw') || isequal(encoding, 'gzip');
assert(encodingCond, 'Unsupported encoding')

% The same with output format
format = lower(format);
formatCond = isequal(format,'nhdr') || isequal(format,'nrrd');
assert(formatCond, 'Unexpected format');

% ======================================================================

% Now, if our conditions are satisfied:
if (encodingCond && formatCond)
    
    % Header
    
    % Open, filename (which specifies output format) and write binary
    fid = fopen(filename, 'wb');
    fprintf(fid,'NRRD0004\n');      % NRRD type 4
    
    % Type of variable we're storing in our file
    mtype=class(matrix);
    outtype=setDatatype(mtype);
    fprintf(fid,['type: ', outtype, '\n']);
    
    % 
    fprintf(fid,['dimension: ', num2str(ndims), '\n']);
    
    if isequal(ndims, 2)
        fprintf(fid,'space: left-posterior\n');
    elseif isequal (ndims, 3)
        fprintf(fid,'space: left-posterior-superior\n');
    elseif isequal (ndims, 4)
        fprintf(fid,'space: left-posterior-superior\n');
    end

    fprintf(fid,['sizes: ', strrep(strrep(strrep(mat2str(dims),'[',''),';',' '),']',''), '\n']);    
    
    if isequal(ndims, 2)
        fprintf(fid,['space directions: ',...
            strrep(strrep(strrep(mat2str(meta.spacedirections(:,1)),'[','('),';',','),']',')'), ' ' ...
            strrep(strrep(strrep(mat2str(meta.spacedirections(:,2)),'[','('),';',','),']',')'), ...
         '\n']);
        fprintf(fid,'kinds: domain domain\n');
    elseif isequal (ndims, 3)
        fprintf(fid,['space directions: ',...
            strrep(strrep(strrep(mat2str(meta.spacedirections(:,1)),'[','('),';',','),']',')'), ' ' ...
            strrep(strrep(strrep(mat2str(meta.spacedirections(:,2)),'[','('),';',','),']',')'), ' ' ...
            strrep(strrep(strrep(mat2str(meta.spacedirections(:,3)),'[','('),';',','),']',')'), ...
         '\n']);
        fprintf(fid,'kinds: domain domain domain\n');
    elseif isequal (ndims, 4)
        fprintf(fid,['space directions: none ',...
            strrep(strrep(strrep(mat2str(meta.spacedirections(:,1)),'[','('),';',','),']',')'), ' ' ...
            strrep(strrep(strrep(mat2str(meta.spacedirections(:,2)),'[','('),';',','),']',')'), ' ' ...
            strrep(strrep(strrep(mat2str(meta.spacedirections(:,3)),'[','('),';',','),']',')'), ...
         '\n']);
        fprintf(fid,'kinds: vector domain domain domain\n');
    end
    
    fprintf(fid,['encoding: ', encoding, '\n']);
    
    [~,~,endian] = computer();
    
    if (isequal(endian, 'B'))
        fprintf(fid,'endian: big\n');
    else
        fprintf(fid,'endian: little\n');
    end
    
    fprintf(fid,['space origin: ',strrep(strrep(strrep(mat2str(meta.spaceorigin),'[','('),' ',','),']',')'),'\n']);
    
    if (isequal(format, 'nhdr')) % Si hay que separar
        % Escribir el nombre del fichero con los datos
        fprintf(fid, ['data file: ', [fname, '.', encoding], '\n']);
        
        fclose(fid);
        if isequal(length(pathf),0)
            fid = fopen([fname, '.', encoding], 'wb');
        else
            fid = fopen([pathf, filesep, fname, '.', encoding], 'wb');
        end
    else
        fprintf(fid,'\n');
    end
    
    ok = writeData(fid, matrix, outtype, encoding);
    fclose(fid);
end


% ========================================================================
% Determine the datatype --> From mtype (matlab) to outtype (NRRD) -->    
% ========================================================================
function datatype = setDatatype(metaType)

% Determine the datatype
switch (metaType)
 case {'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64',...
       'uint64', 'double'}
   datatype = metaType;
  
 case {'single'}
  datatype = 'float';
  
 otherwise
  assert(false, 'Unknown datatype')
end
   
% HACER!!!!!!!!!!!!!!!!!!!!!!!!!
% ========================================================================
% writeData -->
% fidIn is the open file we're overwriting
% matrix - data that have to be written
% datatype - type of data: int8, string, double...
% encoding - raw, gzip, ascii
% ========================================================================
function ok = writeData(fidIn, matrix, datatype, encoding)

switch (encoding)
 case {'raw'}
  
  ok = fwrite(fidIn, matrix(:), datatype);
  
 case {'gzip'}
     
     % Store in a raw file before compressing
     tmpBase = tempname();
     tmpFile = [tmpBase '.gz'];

     fidTmpRaw = fopen(tmpBase, 'wb');
     assert(fidTmpRaw > 3, 'Could not open temporary file for GZIP compression');

     try
        fwrite(fidTmpRaw, matrix(:), datatype);      
     catch
     end
     fclose(fidTmpRaw);
     try
         % Now we gzip our raw file
        gzip(tmpBase);
     catch
     end
     delete (tmpBase);
     
     % Finally, we put this info into our nrrd file (fidIn)
     fidTmpRaw = fopen(tmpFile, 'rb');
     try
         tmp = fread(fidTmpRaw, inf, 'uint8=>uint8');
     catch
     end
     fclose(fidTmpRaw);
     delete (tmpFile);
     
     %cleaner = onCleanup(@() fclose(fidTmpRaw));
     ok = fwrite (fidIn, tmp, 'uint8');

 case {'ascii'}
  
  ok = fprintf(fidIn,'%u ',matrix(:));
  %ok = fprintf(fidIn,matrix(:), class(matrix));
  
 otherwise
  assert(false, 'Unsupported encoding')
end

