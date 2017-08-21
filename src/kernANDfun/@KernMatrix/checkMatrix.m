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


%% Quick check of the kernel matrice of responses
% INPUTS:
% - none
% OUTPUTS:
% - f: fix at true if the matrix is symetric, with 1 on the diagonal and if
% the computation is converged

function f=checkMatrix(obj)
%check symetry
fS=all(all(obj.KK==obj.KK'));
%check eye
fE=all(diag(obj.KK)==1);
%check the adding process
KKold=obj.KK;
obj.sampling=[obj.sampling;obj.newSample];
obj.requireRun=true;
obj.requireIndices=true;
KKnew=obj.buildMatrix();
fA=all(all(KKold==KKnew));
%
f=(fS&&fE&&fA);
%
fprintf('Matrix ');
if f; fprintf('OK'); else, fprintf('NOK');end
fprintf('\n');
if ~f;keyboard;end
end
