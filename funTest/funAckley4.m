%% Ackley's function 4 (Modified Ackley Function)
%L. LAURENT -- 31/10/2016 -- luc.laurent@lecnam.net
%
%numerous local minima
%xx global minimum : UNDEFINED
% in dimension 2: x{(?1.479252, ?0.739807), (1.479252, ?0.739807)} >> f(x)=?3.917275
%
%design space -35<xi<35 (small range -2<xi<2)

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

function [p,dp,infos]=funAckley4(xx,dim)

%constants
a=0.2;
b=3;
c=2;

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
        ex1=exp(-a);
        sc=b*(cos(c*xxx)+sin(c*yyy));
        p=ex1*normP+sc;
        if nargout==2||dem
            dp(:,:,1)=ex1*xxx./normP-c*b*sin(c*xxx);
            dp(:,:,2)=ex1*xxx./normP+c*b*cos(c*xxx);
        end
        
    else
        ex1=exp(-a);
        normP=zeros(size(xx,1),size(xx,2),nbvar-1);
        for itV=1:nbvar-1
            normP(:,:,itV)=sqrt(xx(:,:,itV).^2+xx(:,:,itV+1).^2);
        end
        cx=cos(c*xx(:,:,1:end-1));
        sx=sin(c*xx(:,:,2:end));
        p=sum(ex1.*normP+b*(cx+sx),3);
        if nargout==2||dem
            dp=zeros(size(xx));
            for ii=1:nbvar
                if ii==1
                    dp(:,:,ii)=ex1*xx(:,:,1)./normP(:,:,1)-c*b*sin(c*xx(:,:,1));
                elseif ii==nbvar
                    dp(:,:,ii)=ex1*xx(:,:,nbvar)./normP(:,:,end)+c*b*cos(c*xx(:,:,nbvar));
                else
                    dp(:,:,ii)=ex1*xx(:,:,ii)./normP(:,:,ii)-c*b*sin(c*xx(:,:,ii))...
                        +ex1*xx(:,:,ii+1)./normP(:,:,ii+1)+c*b*cos(c*xx(:,:,ii+1));
                end
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
    infos.min_glob.Z=NaN;
    infos.min_glob.X=NaN;
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demo display
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Ackley 4')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Ackley 4')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Ackley 4')
end
end
