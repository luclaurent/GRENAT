%% Method of GRENAT class
% L. LAURENT -- 26/06/2016 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017  Luc LAURENT <luc.laurent@lecnam.net>
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% Define the reference surface
% INPUTS:
% - varargin: input arguments for defining the reference data
% (points,responses,gradients or 'sampleRef',val1,'respRef',val2,'gradRef',val3
% OUTPUTS:
% - none

function defineRef(obj,varargin)
%accepted keyword
keyOk={'sampleRef','respRef','gradRef'};
%two kind of input variables list (with keywords or not)
%depend on the first argument: double for classical list of
%argument or string if the use of keywords
execOk=true;
if isa(varargin{1},'double')
    if nargin>1;obj.sampleRef=varargin{1};obj.nonSamplePts=varargin{1};end
    if nargin>2;obj.respRef=varargin{2};end
    if nargin>3;obj.gradRef=varargin{3};end
elseif isa(varargin{1},'char')
    if mod(nargin-1,2)==0
        for itV=1:2:nargin-1
            %load key and associated value
            keyTxt=varargin{itV};
            keyVal=varargin{itV+1};
            %check if the keyword is usable
            if ismember(keyTxt,keyOk)
                %store the data
                obj.(keyTxt)=keyVal;
                %specific case
                if keyTxt=='sampleRef'
                    obj.nonSamplePts=keyVal;
                end
            else
                execOk=false;
            end
        end
    else
        execOk=false;
    end
else
    execOk=false;
end
%display error message if wrong syntax
if ~execOk
    fprintf('Wrong syntax for the method\n')
    fprintf('defineref(sampleRef,respRef,gradRef)\n')
    fprintf('or defineref(''sampleRef'',val1,''respRef'',val2,''gradRef'',val3)\n')
end
end