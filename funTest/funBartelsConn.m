%% Bartels Conn's function
%L. LAURENT -- 31/10/2016 -- luc.laurent@lecnam.net
%
%one local minimum
%1 global minimum : x=(0,0) >> f(x)=1
%
%design space -500<xi<500

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

function [p,dp,infos]=funBartelsConn(xx,dim)

%space
Xmin=[-500 -500];
Xmax=[500 500];

%default dimension
if nargin==1;dim=2;end

% demo mode
dem=false;
if nargin==0
    stepM=50;
    xl=linspace(Xmin(1),Xmax(1),stepM);
    yl=linspace(Xmin(2),Xmax(2),stepM);
    [x,y]=meshgrid(xl,yl);
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
    elseif nbvar>2
        error('The Bartels Conn''s function is a 2 dimensional function');
    else
        xxx=xx(:,:,1);
        yyy=xx(:,:,2);
    end
        
    fa=xxx.^2+yyy.^2+xxx.*yyy;
    fb=sin(xxx);
    fc=cos(yyy);
    p=abs(fa)+abs(fb)+abs(fc);
    if nargout==2||dem
        dp(:,:,1)=sign(fa).*abs(2*xxx+yyy)+sign(fb)*abs(cos(xxx));
        dp(:,:,2)=sign(fa).*abs(2*yyy+xxx)+sign(fc)*abs(-sin(yyy));
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
    infos.Xmin=Xmin;
    infos.Xmax=Xmax;
    infos.min_glob.Z=1;
    infos.min_glob.X=[0,0];
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demo display
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Bartels Conn')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Bartels Conn')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Bartels Conn')
end
end
