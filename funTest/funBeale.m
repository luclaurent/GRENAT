%% Beale function
%L. LAURENT -- 16/09/2011 -- luc.laurent@lecnam.net
%
%global minimum : f(x1,x2)=0 pour (x1,x2)=(3,0.5)
%
%Design space: -4.5<x1<4.5, -4.5<x<4.5

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

function [p,dp,infos]=funBeale(xx,dim)

%space
Xmin=-4.5;
Xmax=4.5;

% demo mode
dem=false;
if nargin==0
    stepM=50;
    xl=linspace(Xmin,Xmax,stepM);
    yl=linspace(Xmin,Xmax,stepM);
    [x,y]=meshgrid(xl,yl);
    xx=zeros(stepM,stepM,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end

if ~isempty(xx)
    if size(xx,3)>2
        error('The Beale''s function is a 2 dimensional function');
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
    
    p = (1.5 - xxx + xxx.*yyy).^2 + (2.25 - xxx + xxx.*yyy.^2).^2 + (2.625 - xxx + xxx.*yyy.^3).^2;
    
    
    if nargout==2||dem
        dp(:,:,1)=2*(yyy-1).*(1.5-xxx+xxx.*yyy)+...
            2*(yyy.^2-1).*(2.25 - xxx + xxx.*yyy.^2) +...
            2*(yyy.^3-1).*(2.625 - xxx + xxx.*yyy.^3);
        dp(:,:,2)=2*xxx.*(1.5-xxx+xxx.*yyy)+...
            4*xxx.*yyy.*(2.25 - xxx + xxx.*yyy.^2) +...
            6*xxx.*yyy.^2.*(2.625 - xxx + xxx.*yyy.^3);
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
    infos.Xmin=Xmin*ones(1,nbvar);
    infos.Xmax=Xmax*ones(1,nbvar);
    infos.min_glob.Z=0;
    infos.min_glob.X=[3 0.5];
    infos.min_loc.Z=0;
    infos.min_loc.X=[3 0.5];
end

% demo mode
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Beale')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Beale')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Beale')
end
end

