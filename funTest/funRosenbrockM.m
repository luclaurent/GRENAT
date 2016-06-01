%% Modified Rosenbrock function (Sobester 2005)
% L. LAURENT -- 16/05/2012 -- luc.laurent@lecnam.net

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


function [p,dp,infos] = funRosenbrockM(xx,dim)

% demo mode
dem=false;
if nargin==0
    pas=50;
    borne=2.048;
    [x,y]=meshgrid(linspace(-borne,borne,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    % number of design variables
    nbvar=size(xx,3);
    
    %coefficients
    a=100;
    c=75;
    d=5;
    
    if nbvar==1
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error(['Wrong input variables ',mfilename,']);
        end
        p=a.*(yyy-xxx.^2).^2 + (1 - xxx).^2 + c * (sin(d*(1-xxx)) + sin(d*(1-yyy)));
        if nargout==2||dem
            dp(:,:,1)=-4*a.*xxx.*(yyy-xxx.^2)-2*(1-xxx)-c*d*cos(d(1-xxx));
            dp(:,:,2)=2*a*(yyy-xxx.^2)-c*d*cos(d(1-yyy));
        end
        
    else
        p=0;
        for iter=1:nbvar-1
            p=p+a*(xx(:,:,iter).^2-xx(:,:,iter+1)).^2+(xx(:,:,iter)-1).^2+c*sin(d*(1-xx(:,:,iter)));
        end
        
        if nargout==2||dem
            for iter=1:nbvar
                if iter==1
                    dp(:,:,iter)=4*a*xx(:,:,iter).*(xx(:,:,iter).^2-xx(:,:,iter+1))+2*(xx(:,:,iter)-1)+...
                        c*d*cos(d*(1-xx(:,:,iter)));
                elseif iter==nbvar
                    dp(:,:,iter)=2*a*(xx(:,:,iter)-xx(:,:,iter-1).^2)+2*(xx(:,:,iter)-1)+...
                        c*d*cos(d*(1-xx(:,:,iter)));
                else
                    dp(:,:,iter)=2*a*(xx(:,:,iter)-xx(:,:,iter-1).^2)+...
                        4*a*xx(:,:,iter).*(xx(:,:,iter).^2-xx(:,:,iter+1))+2*(xx(:,:,iter)-1)+c*d*cos(d*(1-xx(:,:,iter)));
                    
                end
            end
        end
        
    end
else
    nbvar=dim;
    p=[];
    dp=[];
end
% output: information about the function
if nargout==3
    pts=ones(1,nbvar);
    infos.min_glob.X=pts;
    infos.min_glob.Z=0;
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

% demo mode
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('RosenbrockM')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X RosenbrockM')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y RosenbrockM')
    p=[];
end

end