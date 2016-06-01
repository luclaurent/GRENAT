%% Bohachevsky3
%L. LAURENT -- 16/09/2011 -- luc.laurent@lecnam.net
%
%global minimum: f(x1,x2)=0 pour (x1,x2)=(0,0)
%
%Design space: -100<x1<100, -100<x2<100

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

function [p,dp,infos]=funBohachevsky3(xx,dim)

% demo mode
dem=false;
if nargin==0
    pas=50;
    borne=2;
    [x,y]=meshgrid(linspace(-borne,borne,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    if size(xx,3)>2
        error('The Bohachevsky3 function is a 2 dimensional function');
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
    
    p = xxx.^2+2*yyy.^2-0.3*cos(3*pi*xxx+4*pi*yyy)+0.3;
    
    
    if nargout==2||dem
        dp(:,:,1)=2*xxx+0.9*pi*sin(3*pi*xxx+4*pi*yyy);
        dp(:,:,2)=4*yyy+1.2*pi*sin(3*pi*xxx+4*pi*yyy);
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
    infos.min_glob.Z=0;
    infos.min_glob.X=zeros(1,nbvar);
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

% demo mode
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Bohachevsky 3')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Bohachevsky 3')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Bohachevsky 3')
end
end