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


%% Renormalization of gradients
% INPUTS:
% - in: array of normalized gradients
% - concat: flag at true if the input data corresponds to concatenate
% (optional)
% gradients
% OUTPUTS:
% - out: array of non-normalized gradients

function out=reNormG(obj,in,concat)
% if concat (gradients concatenate in vector)
if nargin<3;concat=false;end
% if empty normalization data
if isempty(obj.stdS)||isempty(obj.stdR)
    Gfprintf(' ++ Caution: normalization data not defined for gradient\n');
    out=in;
else
    nS=size(in,1);
    if concat
        correct=obj.stdR./obj.stdS;
        nbv=numel(obj.stdS);
        out=in.*repmat(correct(:),nS/nbv,1);
    else
        out=in*obj.stdR./obj.stdS(ones(nS,1),:);
    end
end
end