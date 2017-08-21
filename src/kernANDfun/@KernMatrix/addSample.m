%% Method of KernMatrix class
% L. LAURENT -- 18/07/2017 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017-2017  Luc LAURENT <luc.laurent@lecnam.net>
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


%% Add new sample points in the database
% INPUTS:
% - newS: array of sample points (must have the same number of columns as
% the sample points already included in the database). New sample points
% that are duplicate will be removed
% OUTPUTS:
% - flag: fix at true if duplicate sample points have been removed


function flag=addSample(obj,newS)
flag=false;
%remove dulicate
[~,l,~]=unique(newS,'rows');
newS=newS(sort(l),:);
%flag at true if duplicate sample points are removed
if size(newS,1)==numel(l);flag=true;end
%check if new sample point already exists
[~,Ln]=ismember(obj.sampling,newS,'rows');
%
Ln=Ln(Ln>0);
if ~isempty(Ln)
    Gfprintf(' >> Duplicate sample points detected: remove it\n');
    newS(Ln,:)=[];
end
%
flag=(flag||~isempty(Ln));
%
obj.newSample=newS;
%
if ~isempty(obj.newSample)
    obj.requireUpdate=true;
end
end
