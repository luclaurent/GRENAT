%% Biggs EXP 4's function
%L. LAURENT -- 31/10/2016 -- luc.laurent@lecnam.net
%
%one local minimum
%1 global minimum : x=(1, 10, 1, 5) >> f(x)=0
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

function [p,dp,infos]=funBiggsExp4(xx,dim)

%constants
a=5;
b=10;
nbt=10;
t=0.1.*(1:10);
y=exp(-t)-a*exp(-b*t);

%space
Xmin=[0 0 0 0];
Xmax=[20 20 20 20];

%default dimension
if nargin==1;dim=4;end

% demo mode
dem=false;
if nargin==0
fprintf('4-dimensional function (no demo mode\n')
xx=[];
end
if ~isempty(xx)
    %number of design variables
    nbvar=size(xx,3);
    if nbvar==1
        if size(xx,2)==4
            xxx=xx(:,1);yyy=xx(:,2);zzz=xx(:,3);lll=xx(:,4);
        elseif size(xx,1)==4
            xxx=xx(1,:);yyy=xx(2,:);zzz=xx(3,:);lll=xx(4,:);
        else
            error(['Wrong input variables ',mfilename]);
        end
    elseif nbvar==2||nbvar==3||nbvar>4
        error('The Biggs EXP 4 function is a 4 dimensional function');
    else
        xxx=xx(:,:,1);
        yyy=xx(:,:,2);
        zzz=xx(:,:,3);
        lll=xx(:,:,4);
    end
        
    p=zeros(size(xxx));
    for it=1:nbt
        p=p+(zzz.*exp(-t(it).*xxx)-lll.*exp(-t(it).*yyy)-y(it)).^2;
    end
    if nargout==2||dem
        dp=zeros(size(xxx,1),size(xxx,2),4);
        for it=1:nbt
            mult=zzz.*exp(-t(it).*xxx)-lll.*exp(-t(it).*yyy)-y(it);
            dp(:,:,1)=dp(:,:,1)-2.*zzz.*t(it)*exp(-t(it)*xxx)*mult;
            dp(:,:,2)=dp(:,:,2)+2*lll.*t(it)*exp(-t(it)*yyy)*mult;
            dp(:,:,3)=dp(:,:,3)+2.*exp(-t(it)*xxx)*mult;
            dp(:,:,4)=dp(:,:,4)-2.*exp(-t(it)*yyy)*mult;
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
    infos.min_glob.X=[1, 10, 1, 5];
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

end
