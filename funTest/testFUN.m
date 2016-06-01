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

close all
clear all
save_pdf=false;
nb_pts=80;
borne=2.048;
x=linspace(-borne,borne,nb_pts);
y=linspace(-borne,borne,nb_pts);
[X,Y]=meshgrid(x,y);
fct='ackley';
XX(:,:,1)=X;
XX(:,:,2)=Y;
[Z,GZ]=feval(['fct_' fct],XX);
GZ1=GZ(:,:,1);
GZ2=GZ(:,:,2);
figure;surfc(X,Y,Z)
xlabel('x_1')
ylabel('x_2')
zlabel('Z (log)')
%colormap('Spring')
set(gca, 'ZScale', 'log')
hlight=light;               % switch light
 lighting('phong')         % rendering
 lightangle(hlight,48,70)    % light direction
 %colorbar
 if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/fct_' fct 'log.pdf']);end

figure;surfc(X,Y,Z)
xlabel('x_1')
ylabel('x_2')
zlabel('Z')
%shading interp

 hlight=light;               % switch light
 lighting('phong')         % rendering
 lightangle(hlight,48,70)    % light direction
%colorbar
 if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/fct_' fct '.pdf']);end
figure;surfc(X,Y,GZ1)
xlabel('x_1')
ylabel('x_2')
zlabel('GZ1')
%shading interp
hlight=light;               % switch light
lighting('phong')         % rendering
lightangle(hlight,48,70)    % light direction
%colorbar
 if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/dfct_' fct '1.pdf']);end
figure;surfc(X,Y,GZ2)
xlabel('x_1')
ylabel('x_2')
zlabel('GZ2')
%shading interp
hlight=light;               % switch light
lighting('phong')         % rendering
lightangle(hlight,48,70)    % light direction
%colorbar
if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/dfct_' fct '2.pdf']);end
pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;meshc(X,Y,Z)
xlabel('x_1')
ylabel('x_2')
zlabel('Z')
set(gca, 'ZScale', 'log')
%colorbar
 if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/fct_' fct 'log_mesh.pdf']);end

figure;meshc(X,Y,Z)
xlabel('x_1')
ylabel('x_2')
zlabel('Z')
%colorbar
 if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/fct_' fct 'mesh.pdf']);end
figure;meshc(X,Y,GZ1)
xlabel('x_1')
ylabel('x_2')
zlabel('GZ1')

%colorbar
 if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/dfct_' fct '1_mesh.pdf']);end
figure;meshc(X,Y,GZ2)
xlabel('x_1')
ylabel('x_2')
zlabel('GZ2')
%colorbar
if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/dfct_' fct '2_mesh.pdf']);end
