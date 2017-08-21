%% Michalewicz function
% L. LAURENT -- 16/09/2011 -- luc.laurent@lecnam.net
%
%global minimum: depend of the number of variables
%
%Design space: 0<xi<pi

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

function [p,dp,infos] = funMichalewicz(xx,dim)
% demo mode
dem=false;
if nargin==0
    pas=50;
    borne=pi;
    [x,y]=meshgrid(linspace(0,borne,pas));
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
        p=0;
        for iter=1:nbvar
            p=p+sin(xx(:,:,iter)).*sin(iter*xx(:,:,iter).^2/pi).^20;
        end
        p=-p;
        if nargout==2||dem
            dp=zeros(size(xx));
            for iter=1:nbvar
                dp(:,:,iter)=cos(xx(:,:,iter)).*sin(iter*xx(:,:,iter).^2/pi).^20+...
                    40*iter/pi*xx(:,:,iter).*sin(xx(:,:,iter)).*cos(iter*xx(:,:,iter).^2/pi).^19;
            end
        end
        dp=-dp;
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
    infos.min_loc.Z=NaN;
    infos.min_loc.X=pts;
end

% demo mode
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Michalewicz')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Michalewicz')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Michalewicz')
    p=[];
end
end
