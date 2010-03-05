function varargout = subdir(varargin)
%SUBDIR Performs a recursive file search
%
% subdir
% subdir(name)
% files = subdir(...)
%
% This function performs a recursive file search.  The input and output
% format is identical to the dir function.
%
% Input variables:
%
%   name:   pathname or filename for search, can be absolute or relative
%           and wildcards (*) are allowed.  If ommitted, the files in the
%           current working directory and its child folders are returned    
%
% Output variables:
%
%   files:  m x 1 structure with the following fields:
%           name:   full filename
%           date:   modification date timestamp
%           bytes:  number of bytes allocated to the file
%           isdir:  1 if name is a directory; 0 if no
%
% Example:
%
%   >> a = subdir(fullfile(matlabroot, 'toolbox', 'matlab', '*.mat'))
%
%   a = 
%
%   67x1 struct array with fields:
%       name
%       date
%       bytes
%       isdir
%
%   >> a(2)
%
%   ans = 
%
%        name: '/Applications/MATLAB73/toolbox/matlab/audiovideo/chirp.mat'
%        date: '14-Mar-2004 07:31:48'
%       bytes: 25276
%       isdir: 0
%
% See also:
%
%   dir
%
% From: http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=15859&objectType=file

%Copyright (c) 2009, Kelly Kearney
%All rights reserved.
%
%Redistribution and use in source and binary forms, with or without 
%modification, are permitted provided that the following conditions are 
%met:
%
%    * Redistributions of source code must retain the above copyright 
%      notice, this list of conditions and the following disclaimer.
%    * Redistributions in binary form must reproduce the above copyright 
%      notice, this list of conditions and the following disclaimer in 
%      the documentation and/or other materials provided with the distribution
%      
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
%AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
%IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
%ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
%LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
%CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
%ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
%POSSIBILITY OF SUCH DAMAGE.

%---------------------------
% Get folder and filter
%---------------------------

error(nargchk(0,1,nargin));
error(nargoutchk(0,1,nargout));

if nargin == 0
    folder = pwd;
    filter = '*';
else
    [folder, name, ext] = fileparts(varargin{1});
    if isempty(folder)
        folder = pwd;
    end
    if isempty(ext)
        if isdir(fullfile(folder, name))
            folder = fullfile(folder, name);
            filter = '*';
        end
    else
        filter = [name ext];
    end
end

%---------------------------
% Search all folders
%---------------------------

pathstr = genpath(folder);
seplocs = findstr(pathstr, pathsep);
loc1 = [1 seplocs(1:end-1)+1];
loc2 = seplocs(1:end)-1;
pathfolders = arrayfun(@(a,b) pathstr(a:b), loc1, loc2, 'UniformOutput', false);

Files = [];
for ifolder = 1:length(pathfolders)
    NewFiles = dir(fullfile(pathfolders{ifolder}, filter));
    if ~isempty(NewFiles)
        fullnames = cellfun(@(a) fullfile(pathfolders{ifolder}, a), {NewFiles.name}, 'UniformOutput', false); 
        [NewFiles.name] = deal(fullnames{:});
        Files = [Files; NewFiles];
    end
end

%---------------------------
% Output
%---------------------------
    
if nargout == 0
    if ~isempty(Files)
        fprintf('\n');
        fprintf('%s\n', Files.name);
        fprintf('\n');
    end
elseif nargout == 1
    varargout{1} = Files;
end
