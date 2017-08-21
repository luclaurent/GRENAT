%% Biggs EXP 2's function
%L. LAURENT -- 31/10/2016 -- luc.laurent@lecnam.net
%
%one local minimum
%1 global minimum : x=(1,10) >> f(x)=0
%
%design space 0<xi<20

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

function [p,dp,infos]=funBiggsExp2(xx,dim)

%constants
a=5;
b=10;
nbt=10;
t=0.1.*(1:10);
y=exp(-t)-a*exp(-b*t);

%space
Xmin=[0 0];
Xmax=[20 20];

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
        error('The Biggs EXP 2 function is a 2 dimensional function');
    else
        xxx=xx(:,:,1);
        yyy=xx(:,:,2);
    end
        
    p=zeros(size(xxx));
    for it=1:nbt
        p=p+(exp(-t(it).*xxx)-a.*exp(-t(it).*yyy)-y(it)).^2;
    end
    if nargout==2||dem
        dp=zeros(size(xxx,1),size(xxx,2),2);
        for it=1:nbt
            dp(:,:,1)=dp(:,:,1)-2*t(it)*exp(-t(it)*xxx)*(exp(-t(it).*xxx)-a.*exp(-t(it).*yyy)-y(it));
            dp(:,:,2)=dp(:,:,2)+2*a*t(it)*exp(-t(it)*yyy)*(exp(-t(it).*xxx)-a.*exp(-t(it).*yyy)-y(it));
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
    infos.Xmin=Xmin;
    infos.Xmax=Xmax;
    infos.min_glob.Z=0;
    infos.min_glob.X=[1,10];
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

%demo display
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Biggs EXP 2')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Biggs EXP 2')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Biggs EXP 2')
end
end
