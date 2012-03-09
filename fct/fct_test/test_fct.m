close all
clear all
save_pdf=false;
nb_pts=80;
x=linspace(-10,10,nb_pts);
y=linspace(-10,10,nb_pts);
[X,Y]=meshgrid(x,y);
fct='sumsquare';
XX(:,:,1)=X;
XX(:,:,2)=Y;
[Z,GZ]=feval(['fct_' fct],XX);
GZ1=GZ(:,:,1);
GZ2=GZ(:,:,2);
figure;surfc(X,Y,Z)
xlabel('x_1')
ylabel('x_2')

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
%shading interp

 hlight=light;               % activ. eclairage
 lighting('phong')         % type de rendu
 lightangle(hlight,48,70)    % dir. eclairage
%colorbar
 if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/fct_' fct '.pdf']);end
figure;surfc(X,Y,GZ1)
xlabel('x_1')
ylabel('x_2')
%shading interp
hlight=light;               % activ. eclairage
lighting('phong')         % type de rendu
lightangle(hlight,48,70)    % dir. eclairage
%colorbar
 if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/dfct_' fct '1.pdf']);end
figure;surfc(X,Y,GZ2)
xlabel('x_1')
ylabel('x_2')
%shading interp
hlight=light;               % activ. eclairage
lighting('phong')         % type de rendu
lightangle(hlight,48,70)    % dir. eclairage
%colorbar
if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/dfct_' fct '2.pdf']);end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;meshc(X,Y,Z)
xlabel('x_1')
ylabel('x_2')

set(gca, 'ZScale', 'log')
%colorbar
 if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/fct_' fct 'log_mesh.pdf']);end

figure;meshc(X,Y,Z)
xlabel('x_1')
ylabel('x_2')
%colorbar
 if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/fct_' fct 'mesh.pdf']);end
figure;meshc(X,Y,GZ1)
xlabel('x_1')
ylabel('x_2')

%colorbar
 if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/dfct_' fct '1_mesh.pdf']);end
figure;meshc(X,Y,GZ2)
xlabel('x_1')
ylabel('x_2')
%colorbar
if save_pdf;print(gcf, '-dpdf', '-r300', ['fig/dfct_' fct '2_mesh.pdf']);end