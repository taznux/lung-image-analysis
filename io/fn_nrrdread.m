function [X, meta] = fn_nrrdread(filename)
%fn_nrrdread  Import NRRD imagery and metadata.
%   [X, meta] = fn_nrrdread(filename) reads the image volume and associated
%   metadata from the NRRD-format file specified by filename.
%
%   Current limitations/caveats:
%   * "Block" datatype is not supported.
%   * Only tested with "gzip" and "raw" file encodings.
%   * Very limited testing on actual files.
%   * I only spent a couple minutes reading the NRRD spec.
%
%   See the format specification online:
%   http://teem.sourceforge.net/nrrd/format.html
%
% Copyright 2012 The MathWorks, Inc.
%
% orignal code from https://www.mathworks.com/matlabcentral/fileexchange/34653-nrrd-format-file-reader
%
% It was modified to support deformation 4D deformation vector field by
% Wookjin Choi March 2016.


% Open file.
fid = fopen(filename, 'rb');
assert(fid > 0, 'Could not open file.');
cleaner = onCleanup(@() fclose(fid));

% Magic line.
theLine = fgetl(fid);
assert(numel(theLine) >= 4, 'Bad signature in file.')
assert(isequal(theLine(1:4), 'NRRD'), 'Bad signature in file.')

% The general format of a NRRD file (with attached header) is:
% 
%     NRRD000X
%     <field>: <desc>
%     <field>: <desc>
%     # <comment>
%     ...
%     <field>: <desc>
%     <key>:=<value>
%     <key>:=<value>
%     <key>:=<value>
%     # <comment>
% 
%     <data><data><data><data><data><data>...

meta = struct([]);

% Parse the file a line at a time.
while (true)

  theLine = fgetl(fid);
  
  if (isempty(theLine) || feof(fid))
    % End of the header.
    break;
  end
  
  if (isequal(theLine(1), '#'))
      % Comment line.
      continue;
  end
  
  % "fieldname:= value" or "fieldname: value" or "fieldname:value"
  parsedLine = regexp(theLine, ':=?\s*', 'split','once');
  
  assert(numel(parsedLine) == 2, 'Parsing error')
  
  field = lower(parsedLine{1});
  value = parsedLine{2};
  
  field(isspace(field)) = '';
  meta(1).(field) = value;
  
end

datatype = getDatatype(meta.type);

% Get the size of the data.
assert(isfield(meta, 'sizes') && ...
       isfield(meta, 'dimension') && ...
       isfield(meta, 'encoding'), ...
       'Missing required metadata fields.')
   
if ~isfield(meta, 'endian')
    meta.endian = 'L'; % default endian
end

dims = sscanf(meta.sizes, '%d');
ndims = sscanf(meta.dimension, '%d');
assert(numel(dims) == ndims);

meta.sizes = dims;
meta.dimension = ndims;

data = readData(fid, meta, datatype);
data = adjustEndian(data, meta);


if ndims == 4;
    meta.spacedirections = reshape(cell2mat(textscan(meta.spacedirections, 'none (%f,%f,%f) (%f,%f,%f) (%f,%f,%f)')),3,3);
    meta.spaceorigin = cell2mat(textscan(meta.spaceorigin, '(%f,%f,%f)'));
elseif ndims == 3;
    meta.spacedirections = reshape(cell2mat(textscan(meta.spacedirections, '(%f,%f,%f) (%f,%f,%f) (%f,%f,%f)')),3,3);
    meta.spaceorigin = cell2mat(textscan(meta.spaceorigin, '(%f,%f,%f)'));
else
    meta.spacedirections = reshape(cell2mat(textscan(meta.spacedirections, '(%f,%f) (%f,%f)')),2,2);
    meta.spaceorigin = cell2mat(textscan(meta.spaceorigin, '(%f,%f)'));
end
meta.pixelspacing = diag(meta.spacedirections);

% Reshape and get into MATLAB's order.
X = reshape(data, dims');
if ndims < 4
    X = permute(X, [2 1 3]);
else
    X = permute(X, [1 3 2 4]);
end



function datatype = getDatatype(metaType)

% Determine the datatype
switch (metaType)
 case {'signed char', 'int8', 'int8_t'}
  datatype = 'int8';
  
 case {'uchar', 'unsigned char', 'uint8', 'uint8_t'}
  datatype = 'uint8';

 case {'short', 'short int', 'signed short', 'signed short int', ...
       'int16', 'int16_t'}
  datatype = 'int16';
  
 case {'ushort', 'unsigned short', 'unsigned short int', 'uint16', ...
       'uint16_t'}
  datatype = 'uint16';
  
 case {'int', 'signed int', 'int32', 'int32_t'}
  datatype = 'int32';
  
 case {'uint', 'unsigned int', 'uint32', 'uint32_t'}
  datatype = 'uint32';
  
 case {'longlong', 'long long', 'long long int', 'signed long long', ...
       'signed long long int', 'int64', 'int64_t'}
  datatype = 'int64';
  
 case {'ulonglong', 'unsigned long long', 'unsigned long long int', ...
       'uint64', 'uint64_t'}
  datatype = 'uint64';
  
 case {'float'}
  datatype = 'single';
  
 case {'double'}
  datatype = 'double';
  
 otherwise
  assert(false, 'Unknown datatype')
end



function data = readData(fidIn, meta, datatype)

switch (meta.encoding)
 case {'raw'}
  
  data = fread(fidIn, inf, [datatype '=>' datatype]);
  
 case {'gzip', 'gz'}

  tmpBase = tempname();
  tmpFile = [tmpBase '.gz'];
  fidTmp = fopen(tmpFile, 'wb');
  assert(fidTmp > 3, 'Could not open temporary file for GZIP decompression')
  
  tmp = fread(fidIn, inf, 'uint8=>uint8');
  fwrite(fidTmp, tmp, 'uint8');
  fclose(fidTmp);
  try
    gunzip(tmpFile)
  catch
  end
  delete (tmpFile);
  fidTmp = fopen(tmpBase, 'rb');
  %cleaner = onCleanup(@() fclose(fidTmp));
  
  meta.encoding = 'raw';
  try
    data = readData(fidTmp, meta, datatype);
  catch
  end
  fclose(fidTmp);
  delete (tmpBase);
  
 case {'txt', 'text', 'ascii'}
  
  data = fscanf(fidIn, '%f');
  data = cast(data, datatype);
  
 otherwise
  assert(false, 'Unsupported encoding')
end



function data = adjustEndian(data, meta)

[~,~,endian] = computer();

needToSwap = (isequal(endian, 'B') && isequal(lower(meta.endian), 'little')) || ...
             (isequal(endian, 'L') && isequal(lower(meta.endian), 'big'));
         
if (needToSwap)
    data = swapbytes(data);
end