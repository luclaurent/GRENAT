%% Sphere function
% L. LAURENT -- 16/09/2011 -- luc.laurent@lecnam.net
%
%global minimum : f(xi)=0 pour (x1,x2,x3,x4)=(0,...,0)
%Design space: -10<xi<10

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

function [p,dp,infos] = funSphere(xx,dim)
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
    
    if nbvar==1
        error(['Wrong input variables ',mfilename]);
    else
        cal=xx.^2;
        p=sum(cal,3);
        
        if nargout==2||dem
            dp=2*xx;
        end
        
    end
else
    nbvar=dim;
    p=[];
    dp=[];
end
% output: information about the function
if nargout==3
    pts=[-0.0898,0.7126;0.0898,0.7126];
    infos.min_glob.X=pts;
    infos.min_glob.Z=[-1.0316;-1.0316];
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

% demo mode
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Sphere')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Sphere')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Sphere')
    p=[];
end

end