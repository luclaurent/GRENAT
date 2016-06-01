%% Six-Hump camel back function
%L. LAURENT -- 13/12/2010 -- luc.laurent@lecnam.net
%modif on the 16/09/2011 -- change to n variables
%
%6 local minima and  2 global:
%f(x1,x2)=-1.0316 for (x1,x2)={(-0.0898,0.7126),(0.0898,0.7126)}
%
%Design space: -3<x1<3 -2<x2<2
%(recommanded: -2<x1<2 -1<x2<1)

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


function [p,dp,infos]=funSixHump(xx,dim)

% demo mode
dem=false;
if nargin==0
    pas=50;
    borne=500;
    XX=linspace(-3,3,pas);
    YY=linspace(-2,2,pas);
    [x,y]=meshgrid(XX,YY);
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    if size(xx,3)>2
        error('The SixHump function is a 2 dimensional function');
    elseif size(xx,3)==1
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error(['Wrong input variables ',mfilename]);
        end
        
    else
        xxx=xx(:,:,1);yyy=xx(:,:,2);
    end
    
    p=(4-2.1*xxx.^2+xxx.^4/3).*xxx.^2+xxx.*yyy+4*(-1+yyy.^2).*yyy.^2;
    
    
    if nargout==2||dem
        dp(:,:,1)=2*xxx.*(4-2.1*xxx.^2+xxx.^4/3)+xxx.^2.*(-4.2*xxx+4*xxx.^3/3)+yyy;
        dp(:,:,2)=xxx+8*yyy.*(-1+yyy.^2)+8*yyy.^3;
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
    xlabel('x'), ylabel('y'), title('Six-Hump Camel Back')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Six-Hump Camel Back')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Six-Hump Camel Back')
    p=[];
end

end
