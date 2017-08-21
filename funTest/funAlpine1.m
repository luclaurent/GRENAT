%% Alpine's function 1
%L. LAURENT -- 31/10/2016 -- luc.laurent@lecnam.net
%
%numerous local minima
%1 global minimum : x=(0,0,...,0) >> f(x)=0
%
%design space -10<xi<10

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

function [p,dp,infos]=funAlpine1(xx,dim)

%constants
a=0.1;

%space
Xmin=-10;
Xmax=10;

% demo mode
dem=false;
if nargin==0
    stepM=50;
    [x,y]=meshgrid(linspace(Xmin,Xmax,stepM));
    xx=zeros(stepM,stepM,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    %number of design variables
    nbvar=size(xx,3);
    if nbvar==1
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error(['Wrong input variables ',mfilename]);
        end
        fx=xxx.*sin(xxx)+a*xxx;
        fy=yyy.*sin(yyy)+a*yyy;
        p=abs(fx)+abs(fy);
        if nargout==2||dem
            dp(:,:,1)=sign(xxx.*sin(xxx)+0.1*xxx).*abs(sin(xxx)+0.1+xxx.*cos(xxx));
            dp(:,:,2)=sign(yyy.*sin(yyy)+0.1*yyy).*abs(sin(yyy)+0.1+yyy.*cos(yyy));
        end
        
    else
        fx=xx.*sin(xx)+a*xx;
        p=sum(abs(fx),3);
        if nargout==2||dem
            dp=sign(fx).*abs(sin(xx)+0.1+xx.*cos(xx));
        end
    end
else
    if nargin==2
        nbvar=dim;
    end
    p=[];
    dp=[];
end
%output of information about the function
if nargout==3
    infos.Xmin=Xmin*ones(1,nbvar);
    infos.Xmax=Xmax*ones(1,nbvar);
    infos.min_glob.Z=0;
    infos.min_glob.X=zeros(1,nbvar);
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demo display
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Alpine 1')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Alpine 1')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Alpine 1')
end
end
