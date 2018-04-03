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

dim=1;
fct1='quadraticspline';
fct2='matern32';
pas=0.05;
para=[1 0.5];

if dim==1
    
    x=-10:pas/10:10;
    [ev,dev,ddev]=multiKernel(fct1,x',[1 2]);
    [evv,devv,ddevv]=multiKernel(fct2,x',para(1));
    
    figure
    hold on
    plot(x,ev,'b')
    plot(x,dev,'r')
    plot(x,ddev(:),'k')
    legend('E','G','H')
    axis([-2 2 -10 10]);
elseif dim ==2
    x=-5:pas:5;
    [X,Y]=meshgrid(x);
    XX=[X(:) Y(:)];
    [ev,dev,ddev]=multiKernel(fct1,XX,para);
    [evv,devv,ddevv]=multiKernel(fct2,XX,para);
    Z=reshape(ev,size(X,1),size(X,2));
    GZX=reshape(dev(:,1),size(X,1),size(X,2));
    GZY=reshape(dev(:,2),size(X,1),size(X,2));
    GGXX=reshape(ddev(1,1,:),size(X,1),size(X,2));
    GGYY=reshape(ddev(2,2,:),size(X,1),size(X,2));
    GGXY=reshape(ddev(1,2,:),size(X,1),size(X,2));
    GGYX=reshape(ddev(2,1,:),size(X,1),size(X,2));
    figure
    subplot(4,2,1)
    surf(X,Y,Z)
    title('Z')
    xlabel('X')
    ylabel('Y')
    %figure
    subplot(4,2,3)
    surf(X,Y,GZX)
    title('GZX')
    xlabel('X')
    ylabel('Y')
    %figure
    subplot(4,2,4)
    surf(X,Y,GZY)
    title('GZY')
    xlabel('X')
    ylabel('Y')
    %figure
    subplot(4,2,5)
    surf(X,Y,GGXX)
    title('GGXX')
    xlabel('X')
    ylabel('Y')
    %figure
    subplot(4,2,6)
    surf(X,Y,GGYY)
    title('GGYY')
    xlabel('X')
    ylabel('Y')
    %figure
    subplot(4,2,7)
    surf(X,Y,GGXY)
    title('GGXY')
    xlabel('X')
    ylabel('Y')
    %figure
    subplot(4,2,8)
    surf(X,Y,GGYX)
    title('GGYX')
    xlabel('X')
    ylabel('Y')
    
    
    
end
