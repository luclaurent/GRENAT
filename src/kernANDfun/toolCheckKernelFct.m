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

dim=2;
fct1='matern';
fct2='matern';
pas=0.1;

if dim==1

x=-10:pas:10;
[ev,dev,ddev]=multiKern(fct1,x',2);
[evv,devv,ddevv]=multiKern(fct2,x',2);

figure
hold on
plot(x,ev,'b')
plot(x,dev,'r')
plot(x,ddev(:),'k')
%axis([-10 10 -500 500]);
elseif dim ==2
    x=-10:pas:10;
    [X,Y]=meshgrid(x);
    XX=[X(:) Y(:)];
    [ev,dev]=feval(fct1,1,XX);
    [evv,devv,ddevv]=feval(fct2,XX,1);
    Z=reshape(ev,size(X,1),size(X,2));
    GZX=reshape(dev(:,1),size(X,1),size(X,2));
    GZY=reshape(dev(:,2),size(X,1),size(X,2));
    GGXX=reshape(ddev(1,1,:),size(X,1),size(X,2));
    GGYY=reshape(ddev(2,2,:),size(X,1),size(X,2));
    GGXY=reshape(ddev(1,2,:),size(X,1),size(X,2));
    GGYX=reshape(ddev(2,1,:),size(X,1),size(X,2));
    figure
    %subplot(4,2,1)
    surf(X,Y,Z)
    title('Z')
    xlabel('X')
    ylabel('Y')
    figure
    %subplot(4,2,3)
    surf(X,Y,GZX)
    title('GZX')
    xlabel('X')
    ylabel('Y')
    figure
    %subplot(4,2,4)
    surf(X,Y,GZY)
    title('GZY')
    xlabel('X')
    ylabel('Y')
    figure
    %subplot(4,2,5)
    surf(X,Y,GGXX)
    title('GGXX')
    xlabel('X')
    ylabel('Y')
    figure
    %subplot(4,2,6)
    surf(X,Y,GGYY)
     title('GGYY')
     xlabel('X')
    ylabel('Y')
     figure
    % subplot(4,2,7)
    surf(X,Y,GGXY)
     title('GGXY')
     xlabel('X')
    ylabel('Y')
     figure
    % subplot(4,2,8)
    surf(X,Y,GGYX)
     title('GGYX')
     xlabel('X')
    ylabel('Y')
     
    
    
end
