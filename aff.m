figure;
surf(X,Y,Z,'EdgeColor','none')

hlight=light;              % activ. éclairage
lighting('gouraud')        % type de rendu
lightangle(hlight,48,70)


 figure;
        surf(X,Y,ZK,'EdgeColor','none')
        hlight=light;              % activ. éclairage
lighting('gouraud')        % type de rendu
lightangle(hlight,48,70)
grid off