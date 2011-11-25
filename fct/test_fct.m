close all

type='1d'; %2d
fct='corr_matern52';
switch type
    case '1d'
        x=linspace(-10,10,100);x=x';
        para=2;
        [Z,GZ,GGZ]=feval(fct,x,para);
        figure
        plot(x,Z)
        hold on
        plot(x,GZ,'r');
        
        plot(x,GGZ(:),'k');
        hold off
    
    case '2d'
        x=linspace(-3,3,30);
        y=linspace(-3,3,30);
        [X,Y]=meshgrid(x,y);
        
        [Z,GZ1,GZ2]=feval([ fct],X,Y);
        
        figure;surfc(X,Y,Z)
        xlabel('x_1')
        ylabel('x_2')
        
        %colormap('Spring')
        set(gca, 'ZScale', 'log')
        hlight=light;               % activ. eclairage
        lighting('phong')         % type de rendu
        lightangle(hlight,48,70)    % dir. eclairage
        %colorbar
        print(gcf, '-dpdf', '-r300', ['fig/fct_' fct 'log.pdf'])
        
        figure;surfc(X,Y,Z)
        xlabel('x_1')
        ylabel('x_2')
        %shading interp
        
        hlight=light;               % activ. eclairage
        lighting('phong')         % type de rendu
        lightangle(hlight,48,70)    % dir. eclairage
        %colorbar
        print(gcf, '-dpdf', '-r300', ['fig/fct_' fct '.pdf'])
        figure;surfc(X,Y,GZ1)
        xlabel('x_1')
        ylabel('x_2')
        %shading interp
        hlight=light;               % activ. eclairage
        lighting('phong')         % type de rendu
        lightangle(hlight,48,70)    % dir. eclairage
        %colorbar
        print(gcf, '-dpdf', '-r300', ['fig/dfct_' fct '1.pdf'])
        figure;surfc(X,Y,GZ2)
        xlabel('x_1')
        ylabel('x_2')
        %shading interp
        hlight=light;               % activ. eclairage
        lighting('phong')         % type de rendu
        lightangle(hlight,48,70)    % dir. eclairage
        %colorbar
        print(gcf, '-dpdf', '-r300', ['fig/dfct_' fct '2.pdf'])
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure;meshc(X,Y,Z)
        xlabel('x_1')
        ylabel('x_2')
        
        set(gca, 'ZScale', 'log')
        %colorbar
        print(gcf, '-dpdf', '-r300', ['fig/fct_' fct 'log_mesh.pdf'])
        
        figure;meshc(X,Y,Z)
        xlabel('x_1')
        ylabel('x_2')
        %colorbar
        print(gcf, '-dpdf', '-r300', ['fig/fct_' fct 'mesh.pdf'])
        figure;meshc(X,Y,GZ1)
        xlabel('x_1')
        ylabel('x_2')
        
        %colorbar
        print(gcf, '-dpdf', '-r300', ['fig/dfct_' fct '1_mesh.pdf'])
        figure;meshc(X,Y,GZ2)
        xlabel('x_1')
        ylabel('x_2')
        %colorbar
        print(gcf, '-dpdf', '-r300', ['fig/dfct_' fct '2_mesh.pdf'])
        
        end