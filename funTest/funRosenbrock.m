% Rosenbrock function
% L. LAURENT -- 12/05/2010 -- luc.laurent@lecnam.net
%modif on 16/09/2011 -- change to n variables

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

function [p,dp,infos] = funRosenbrock(xx,dim)

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
    
    if nbvar==1
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error(['Wrong input variables ',mfilename]);
        end
        p=100.*(yyy-xxx.^2).^2 + (1 - xxx).^2;
        if nargout==2||dem
            dp(:,:,1)=-400.*xxx.*(yyy-xxx.^2)-2*(1-xxx);
            dp(:,:,2)=200*(yyy-xxx.^2);
        end
        
    else
        p=0;
        for iter=1:nbvar-1
            p=p+100*(xx(:,:,iter).^2-xx(:,:,iter+1)).^2+(xx(:,:,iter)-1).^2;
        end
        
        if nargout==2||dem
            for iter=1:nbvar
                if iter==1
                    dp(:,:,iter)=400*xx(:,:,iter).*(xx(:,:,iter).^2-xx(:,:,iter+1))+2*(xx(:,:,iter)-1);
                elseif iter==nbvar
                    dp(:,:,iter)=200*(xx(:,:,iter)- xx(:,:,iter-1).^2);
                else
                    dp(:,:,iter)=200*(xx(:,:,iter)-xx(:,:,iter-1).^2)+...
                        400*xx(:,:,iter).*(xx(:,:,iter).^2-xx(:,:,iter+1))+2*(xx(:,:,iter)-1);
                    
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
    xlabel('x'), ylabel('y'), title('Rosenbrock')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Rosenbrock')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Rosenbrock')
    p=[];
end

end