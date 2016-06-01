%% Peaks function
%L. LAURENT -- 12/05/2010 -- luc.laurent@lecnam.net

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

function [p,dp,infos]=funPeaks(xx,dim)
% demo mode
dem=false;
if nargin==0
    pas=50;
    borne=5;
    [x,y]=meshgrid(linspace(-borne,borne,pas));
    xx=zeros(pas,pas,2);
    xx(:,:,1)=x;xx(:,:,2)=y;
    dem=true;
end
if ~isempty(xx)
    
    if size(xx,3)>2
        error('The Peaks function is a 2 dimensional function');
    elseif size(xx,3)==1
        if size(xx,2)==2
            xxx=xx(:,1);yyy=xx(:,2);
        elseif size(xx,1)==2
            xxx=xx(:,2);yyy=xx(:,1);
        else
            error(['Wrong input variables ',mfilename,']);
        end
        
    else
        xxx=xx(:,:,1);yyy=xx(:,:,2);
    end
    
    p =  3*(1-xxx).^2.*exp(-(xxx.^2) - (yyy+1).^2) ...
        - 10*(xxx/5 - xxx.^3 - yyy.^5).*exp(-xxx.^2-yyy.^2) ...
        - 1/3*exp(-(xxx+1).^2 - yyy.^2);
    
    if nargout==2||dem
        dp(:,:,1)=-6*(1-xxx).*exp(-(xxx.^2) - (yyy+1).^2)...
            -6*xxx.*(1-xxx).^2.*exp(-xxx.^2-(yyy+1).^2) ...
            -10*(1/5-3*xxx.^2).*exp(-xxx.^2-yyy.^2)...
            +20*(xxx/5-xxx.^3-yyy.^5).*xxx.*exp(-xxx.^2-yyy.^2)...
            +2/3*(xxx+1).*exp(-(xxx+1).^2-yyy.^2);
        dp(:,:,2)=-6*(1-xxx).^2.*(yyy+1).*exp(-xxx.^2-(yyy+1).^2)...
            +50*yyy.^4.*exp(-xxx.^2-yyy.^2)...
            +20*yyy.*(xxx/5-xxx.^3-yyy.^5).*exp(-xxx.^2 -yyy.^2)...
            +2/3*yyy.*exp(-(xxx+1).^2-yyy.^2);
    end
else
    nbvar=dim;
    p=[];
    dp=[];
end
% output: information about the function
if nargout==3
    pts=NaN;
    infos.min_glob.X=NaN;
    infos.min_glob.Z=NaN;
    infos.min_loc.Z=NaN;
    infos.min_loc.X=NaN;
end

% demo mode
if nargin==0
    figure
    subplot(1,3,1)
    surf(x,y,p);
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Peaks')
    subplot(1,3,2)
    surf(x,y,dp(:,:,1));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. X Peaks')
    subplot(1,3,3)
    surf(x,y,dp(:,:,2));
    axis('tight','square')
    xlabel('x'), ylabel('y'), title('Grad. Y Peaks')
    p=[];
end

end