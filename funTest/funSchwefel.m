%% Schwefel function
%L. LAURENT -- 26/01/2011 -- luc.laurent@lecnam.net
%modif on the 16/09/2011 -- change to n variables
%
%numerous local minima
%1 global minimum : x=(1,1,...,1) >> f(x)=0
%
%Design space: -500<xi<500

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

function [p,dp,infos]=funSchwefel(xx,dim)

coef=418.9829;
% demo mode
dem=false;
if nargin==0
    pas=50;
    borne=500;
    [x,y]=meshgrid(linspace(-borne,borne,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    % number of design variables
    nbvar=size(xx,3);
    
    if nbvar==1
        if nargout==2
            
            if size(xx,2)==2
                xxx=xx(:,1);yyy=xx(:,2);
            elseif size(xx,1)==2
                xxx=xx(:,2);yyy=xx(:,1);
            else
                error(['Wrong input variables ',mfilename]);
            end
            cal=xxx.*sin(sqrt(abs(xxx)))+yyy.*sin(sqrt(abs(yyy)));
            p=coef*nbvar-cal;
            if nargout==2||dem
                dpX=-sin(sqrt(abs(xxx)))-xxx.*sign(xxx).*cos(sqrt(abs(xxx)))./(2*sqrt(abs(xxx)));
                iXZ=find(abs(xxx)<eps);dpX(iXZ)=0;
                dpY=-sin(sqrt(abs(yyy)))-xxx.*sign(yyy).*cos(sqrt(abs(yyy)))./(2*sqrt(abs(yyy)));
                iXZ=find(abs(yyy)<eps);dpY(iXZ)=0;
                dp(:,:,1)=dpX;
                dp(:,:,2)=dpY;
            end
        end
        
    else
        cal=xx.*sin(sqrt(abs(xx)));
        p=coef*nbvar-sum(cal,3);
        
        if nargout==2||dem
            dp=-sin(sqrt(abs(xx)))-xx.*sign(xx).*cos(sqrt(abs(xx)))./(2*sqrt(abs(xx)));
            iXZ=find(abs(xx)<eps);dp(iXZ)=0;
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
    cal=pts(:,1).*sin(sqrt(abs(pts(:,1))))+pts(:,2).*sin(sqrt(abs(pts(:,2))));
    infos.min_glob.Z=coef*nbvar-cal;
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

% demo mode
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Schwefel')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Schwefel')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Schwefel')
    p=[];
end

end
