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
hlight=light;               % activ. eclairage
 lighting('phong')         % type de rendu
 lightangle(hlight,48,70)    % dir. eclairage
 %colorbar
 if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/fct_' fct 'log.pdf']);end

figure;surfc(X,Y,Z)
xlabel('x_1')
ylabel('x_2')
zlabel('Z')
%shading interp

 hlight=light;               % activ. eclairage
 lighting('phong')         % type de rendu
 lightangle(hlight,48,70)    % dir. eclairage
%colorbar
 if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/fct_' fct '.pdf']);end
figure;surfc(X,Y,GZ1)
xlabel('x_1')
ylabel('x_2')
zlabel('GZ1')
%shading interp
hlight=light;               % activ. eclairage
lighting('phong')         % type de rendu
lightangle(hlight,48,70)    % dir. eclairage
%colorbar
 if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/dfct_' fct '1.pdf']);end
figure;surfc(X,Y,GZ2)
xlabel('x_1')
ylabel('x_2')
zlabel('GZ2')
%shading interp
hlight=light;               % activ. eclairage
lighting('phong')         % type de rendu
lightangle(hlight,48,70)    % dir. eclairage
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

