%% De Jong function
%L. LAURENT -- 21/02/2012 -- luc.laurent@lecnam.net
%
%1 global minimum : x=(0,0,...,0) >> f(x)=0
%
%design space -5.12<xi<5.12

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

function [p,dp,infos]=funDejong(xx,dim)

coef=10;


% demo mode
dem=false;
if nargin==0
    pas=50;
    borne=5.12;
    [x,y]=meshgrid(linspace(-borne,borne,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    % number of design variables
    nbvar=size(xx,3);
    
    if nbvar==1
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error(['Wrong input variables ',mfilename]);
        end
        p=xxx.^2+yyy.^2;
        if nargout==2||dem
            dp(:,:,1)=2*xxx;
            dp(:,:,2)=2*yyy;
        end
    else
        cal=xx.^2;
        p=sum(cal,3);
        if nargout==2||dem
            dp=2*xx;
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
    pts=zeros(1,nbvar);
    infos.min_glob.X=pts;
    infos.min_glob.Z=zeros(1,nbvar);
    infos.min_loc.Z=pts;
    infos.min_loc.X=zeros(1,nbvar);
end

% demo mode
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('De Jong')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X De Jong')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y De Jong')
end
end

