%% Method of RBF class
% L. LAURENT -- 15/08/2017 -- luc.laurent@lecnam.net

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


%% Show the result of the CV
% INPUTS:
% - none
% OUTPUTS:
% - none

function showCV(obj)
%use QQ-plot
opt.newfig=false;
figure;
subplot(1,3,1);
opt.title='Normalized data (CV R)';
QQplot(obj.resp,obj.cvResults.cvZR,opt);
subplot(1,3,2);
opt.title='Normalized data (CV F)';
QQplot(obj.resp,obj.cvResults.cvZ,opt);
subplot(1,3,3);
opt.title='SCVR (Normalized)';
opt.xlabel='Predicted' ;
opt.ylabel='SCVR';
SCVRplot(obj.cvResults.cvZR,obj.cvResults.scvrR,opt);
end
