%% Colville function
%L. LAURENT -- 16/09/2011 -- luc.laurent@lecnam.net
%
%global minimum : f(x1,x2,x3,x4)=0 pour (x1,x2,x3,x4)=(1,1,1,1)
%
%Design space: -10<xi<10

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

function [p,dp,infos]=funColville(xx,dim)

if ~isempty(xx)
    if size(xx,3)~=4
        error('The Coleville function is a 4 dimensional function');
    elseif size(xx,3)==1
        if size(xx,2)==4
            xxx=xx(:,1);yyy=xx(:,2);zzz=xx(:,3);vvv=xx(:,4);
        elseif size(xx,1)==4
            xxx=xx(1,:);yyy=xx(2,:);zzz=xx(3,:);vvv=xx(4,:);
        else
            error('Wrong input variable fct Coleville');
        end
        
    else
        xxx=xx(:,:,1);yyy=xx(:,:,2);zzz=xx(:,:,3);vvv=xx(:,:,4);
    end
    
    p =100*(xxx.^2-yyy).^2+(xxx-1).^2+(zzz-1).^2+50*(zzz.^2-vvv).^2+...
        10.1*((zzz-1).^2+(vvv-1).^2)+19.8*(yyy-1)*(vvv-1);
    
    
    if nargout==2||dem
        dp(:,:,1)=400*x1.*(xxx.^2-yyy)+2*(xxx-1);
        dp(:,:,2)=-200*(xxx.^2-yyy)+19.8*(vvv-1);
        dp(:,:,3)=2*(zzz-1)+200*zzz.*(zzz.^2-vvv)+20.2*(zzz-1);
        dp(:,:,4)=-100*(zzz.^2-vvv)+20.2*(vvv-1)+19.8*(yyy-1);
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
    pts=[1,1,1,1];
    infos.min_glob.X=pts;
    xxx=pts(1);yyy=pts(2);zzz=pts(3);vvv=pts(4);
    infos.min_glob.Z=100*(xxx.^2-yyy).^2+(xxx-1).^2+(zzz-1).^2+50*(zzz.^2-vvv).^2+...
        10.1*((zzz-1).^2+(vvv-1).^2)+19.8*(yyy-1)*(vvv-1);
    infos.min_loc.Z=infos.min_glob.Z;
    infos.min_loc.X=pts;
end
end
