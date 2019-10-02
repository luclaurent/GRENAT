%% Method of xLS class
% L. LAURENT -- 31/07/2017 -- luc.laurent@lecnam.net

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


%% Compute regressors
% INPUTS:
% - flagRun: execute computation or not (optional, default true)
% OUTPUTS:
% - none

function compute(obj,flagRun)
%if no flagRun specified
if nargin==1;flagRun=true;end
%
obj.nbMonomialTerms=size(obj.valFunPoly,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%determine regressors
obj.XX=[obj.valFunPoly;obj.valFunPolyD];
obj.YYtot=[obj.YY;obj.YYD];
obj.fct=obj.XX'*obj.XX;
obj.fcY=obj.XX'*obj.YYtot;
%deal with insufficent number of equations
if flagRun
    Gfprintf(' ++ Build regressors\n');
    if obj.nbMonomialTerms>numel(obj.YYtot)
        Gfprintf(' > !! matrix ill-conditionned (%i mono., %i resp. and grad.)!! (use pinv)\n',...
            obj.nbMonomialTerms,numel(obj.YYtot));
        obj.beta=pinv(obj.fct)*obj.fcY;
    else
        obj.beta=obj.fct\obj.fcY;
        %
        %                     tic
        %                     obj.fct=obj.XX'*obj.XX;
        %                     [obj.Q,obj.R]=qr(obj.fct);
        %                     obj.beta=obj.R\(obj.Q'*obj.fcY);
        %                     toc
        %                     tic
        %                     fct=obj.XX'*obj.XX;
        %                     fcY=obj.XX'*obj.YYtot;
        %                     zz=fct\fcY;
        %                     toc
        %                     tic
        %                     [Q,R,e]=qr(obj.XX,'vector');
        %                     %keyboard
        %                     toc
        %                     tic
        %                      [Q,R,P]=qr(obj.XX);
        %                      toc
        %                     qy=Q'*obj.YYtot;
        %                     x=R\qy;
        %                     bb=P*x;
        %                     toc
        %                      all(bb(:)==obj.beta)
        %                     keyboard
    end
    %
    obj.requireRun=false;
end
end
