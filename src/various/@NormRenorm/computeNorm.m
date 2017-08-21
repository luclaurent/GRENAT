%% Method of NormRenorm class
% L. LAURENT -- 02/08/2017 -- luc.laurent@lecnam.net

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


%% Compute normalization data
% INPUTS:
% - in: array/vector of input data
% - type: kind of input data: sampling, responses or normal (use current statistics data) (optional)
% OUTPUTS:
% - none

function computeNorm(obj,in,type)
%in the case of no type specified
if nargin<3;type='normal';end
if any(isnan(in(:)));Gfprintf(' ++ Caution: NaN detected for normalization OMITTED\n');end
%computation of the means and standard deviations
obj.meanC=mean(in,'omitnan');
obj.stdC=std(in,'omitnan');
%depending on the option the storage is changed
switch type
    case {'resp','Resp','r','R','RESP','response','Responses','RESPONSES'}
        obj.meanR=obj.meanC;
        obj.stdR=obj.stdC;
    case {'sampling','Sampling','s','S','SAMPLING'}
        obj.meanS=obj.meanC;
        obj.stdS=obj.stdC;
    otherwise
        obj.meanN=obj.meanC;
        obj.stdN=obj.stdC;
end
end