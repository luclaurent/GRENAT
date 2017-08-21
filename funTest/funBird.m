%% Bird's function
%L. LAURENT -- 31/10/2016 -- luc.laurent@lecnam.net
%
%one local minimum
%1 global minimum : x={(4.70104,3.15294),(?1.58214, ?3.13024)} >> f(x)=?106.764537
%
%design space -2pi<xi<2pi

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

function [p,dp,infos]=funBird(xx,dim)

%space
Xmin=[-2*pi -2*pi];
Xmax=[2*pi 2*pi];

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
        error('The Bird''s function is a 2 dimensional function');
    else
        xxx=xx(:,:,1);
        yyy=xx(:,:,2);
    end
        
    sx=sin(xxx);
    cy=cos(yyy);
    ex1=exp((1-cy).^2);
    ex2=exp((1-sx).^2);
    fxy=(xxx-yyy).^2;
    p=sx.*ex1+cy.*ex2+fxy;
    if nargout==2||dem
        cx=cos(xxx);
        sy=sin(yyy);
        dp(:,:,1)=cx.*ex1-2*cy.*cx.*(1-sx).*ex2+2*(xxx-yyy);
        dp(:,:,2)=2*sx.*sy.*(1-cy).*ex1-sy.*ex2-2*(xxx-yyy);
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
    infos.min_glob.Z=-106.764537;
    infos.min_glob.X=[4.70104,3.15294;-1.58214, -3.13024];
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demo display
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Bird')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Bird')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Bird')
end
end
