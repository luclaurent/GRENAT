%% Ackley's function 3
%L. LAURENT -- 31/10/2016 -- luc.laurent@lecnam.net
%
%one local minimum
%1 global minimum : x=(0,-0.4) >> f(x)=?219.1418
%
%design space -32<xi<32

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

function [p,dp,infos]=funAckley3(xx,dim)

%constants
a=200;
b=0.02;
c=5;

%space
Xmin=-32;
Xmax=32;

%default dimension
if nargin==1;dim=2;end

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
    elseif nbvar>2
        error('The Ackley 2 function is a 2 dimensional function');
    else
        xxx=xx(:,:,1);
        yyy=xx(:,:,2);
    end
        
    normP=sqrt(xxx.^2+yyy.^2);
    ex1=exp(-b*normP);
    ex2=exp(cos(3*xxx)+sin(3*yyy));
    p=-a*ex1+c*ex2;
    if nargout==2||dem
        dp(:,:,1)=a*b.*xxx./normP.*ex1-3*c.*sin(3*xxx).*ex2;
        dp(:,:,2)=a*b.*yyy./normP.*ex1+3*c.*cos(3*yyy).*ex2;
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
    infos.min_glob.Z=-219.1418;
    infos.min_glob.X=[0 0.4];
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demo display
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Ackley 3')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Ackley 3')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Ackley 3')
end
end
