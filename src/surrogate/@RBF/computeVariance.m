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


%% Compute variance
% INPUTS:
% - rr: kernel vector at the evaluation point
% OUTPUTS:
% - variance: value of the kriging variance

function variance=computeVariance(obj,rr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute variance of the surrogate model (Bompard 2011,Sobester 2005, Gibbs 1997)
if ~dispWarning;warning off all;end
%correction for taking into account gradients (debug ....)
rrb=rr;
if obj.flagG
    iXs=ns+1-obj.missData.nbMissResp;
    rrb(iXs:end)=-rrb(iXs:end);
end
%
variance=1-rr*(obj.matrices.iK*rrb');
if ~dispWarning;warning on all;end
end
