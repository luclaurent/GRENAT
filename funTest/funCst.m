%% Constant function
% L. LAURENT -- 20/10/2011 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016  Luc LAURENT <luc.laurent@lecnam.net>
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

function [p,dp,infos]=funCst(xx,dim)

% demo mode
dem=false;
if nargin==0
    pas=50;
    borne=10;
    [x,y]=meshgrid(linspace(-borne,borne,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    % number of design variables
    nbvar=size(xx,3);
    
    %valeur constant
    val=10;
    
    if nbvar==1
        if size(xx,2)==2
            xxx=xx(:,1);
        elseif size(xx,1)==2
            xxx=xx(:,2);
        else
            error(['Wrong input variables ',mfilename]);
        end
        p=val*ones(size(xxx));
        if nargout==2
            dp=zeros(size(xx));
        end
        
    else
        p=val*ones(size(xx(:,:,1)));
        if nargout==2
            dp=zeros(size(xx));
        end
    end
else
    if nargin==2
        nbvar=dim;
    end
    p=[];
    dp=[];
end
% output: information about the function
if nargout==3
    pts=NaN;
    infos.min_glob.X=pts;
    infos.min_glob.Z=NaN;
    infos.min_loc.Z=infos.min_glob.Z;
    infos.min_loc.X=pts;
end
end