%% Ackley's function 1
%L. LAURENT -- 31/10/2016 -- luc.laurent@lecnam.net
%
%numerous local minima
%1 global minimum : x=(0,0,...,0) >> f(x)=0
%
%design space -35<xi<35 (small range -2<xi<2)

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

function [p,dp,infos]=funAckley1(xx,dim)

%constants
a=20;
b=0.02;
c=2*pi;
d=exp(1);

%space
Xmin=-35;
Xmax=35;

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
        normP=sqrt(xxx.^2+yyy.^2);
        ex1=exp(-b*normP/sqrt(2));
        ex2=exp(1/2*(cos(c*xxx)+cos(c*yyy)));
        p=-a*ex1-ex2+a+d;
        if nargout==2||dem
            dp(:,:,1)=a*b/sqrt(2)*xxx/normP*ex1+1/2*c*sin(c*xxx)*ex2;
            dp(:,:,2)=a*b/sqrt(2)*yyy/normP*ex1+1/2*c*sin(c*yyy)*ex2;
        end
        
    else
        normP=sqrt(sum(xx.^2,3));
        ex1=exp(-b*normP/sqrt(nbvar));
        sco=sum(cos(c*xx),3);
        ex2=exp(1/nbvar*sco);
        p=-a*ex1-ex2+a+d;
        if nargout==2||dem
            dp=zeros(size(xx));
            for ii=1:nbvar
                dp(:,:,ii)=a*b*1/sqrt(nbvar)*xx(:,:,ii)./normP.*ex1+c/nbvar*sin(c*xx(:,:,ii)).*ex2;
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
    xlabel('x'), ylabel('y'), title('Ackley 1')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Ackley 1')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Ackley 1')
end
end
