%% Alpine's function 2
%L. LAURENT -- 31/10/2016 -- luc.laurent@lecnam.net
%
%numerous local minima
%1 global minimum : x=(7.917,7.917,...,7.917) >> f(x)=2.808^p
%
%design space 0<xi<10

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

function [p,dp,infos]=funAlpine2(xx,dim)


%space
Xmin=0;
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
        fx=sqrt(xxx).*sin(xxx);
        fy=sqrt(yyy).*sin(yyy);
        p=abs(fx)+abs(fy);
        if nargout==2||dem
            dp(:,:,1)=fy.*(0.5./sqrt(xxx).*sin(xxx)+sqrt(xxx).*cos(xxx));
            dp(:,:,2)=fx.*(0.5./sqrt(yyy).*sin(yyy)+sqrt(yyy).*cos(yyy));
        end
        
    else
        fx=sqrt(xx).*sin(xx);
        p=prod(fx,3);
        if nargout==2||dem
            dp=zeros(size(xx));
            for itV=1:nbvar
                itF=[1:(itV-1) (itV+1):nbvar];
                dp(:,:,itV)=prod(fx(:,:,itF),3).*...
                    (0.5./sqrt(xx(:,:,itV)).*sin(xx(:,:,itV))+sqrt(xx(:,:,itV)).*cos(xx(:,:,itV)));
            end
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
    infos.min_glob.Z=2.808^nbvar;
    infos.min_glob.X=7.917*ones(1,nbvar);
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demo display
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Alpine 2')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Alpine 2')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Alpine 2')
end
end
