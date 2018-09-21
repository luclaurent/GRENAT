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

%% Train the metamodel
% INPUTS:
% - none
% OUTPUTS:
% - none

function train(obj)
%display information before building
obj.showData('train');
%populate the surrogate model class
obj.dataTrain.sampling=obj.samplingN;
obj.dataTrain.resp=obj.respN;
%populate with gradients of the chosen metamodel allows it
if obj.gradUsed
    obj.dataTrain.grad=obj.gradN;
end
%populate with configuration and missing data
obj.dataTrain.manageOpt(obj.confMeta,obj.miss);
%train the metamodel
obj.dataTrain.train;
%change state of flags
obj.runTrain=false;
obj.runErr=true;

%renormalize specific data if exist
 %variance of kriging process;
if isprop(obj.dataTrain,'sig2')
        obj.sig2N=obj.dataTrain.sig2;
        obj.sig2=obj.sig2N;
end
if obj.confMeta.normOn&&~isempty(obj.norm.stdR)
    %variance of kriging process;
    obj.sig2=obj.sig2N*obj.norm.stdR^2;
 end
end