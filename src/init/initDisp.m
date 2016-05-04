%% Initialization of display variables
%% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

function dispDef=initDisp()

    dispDef.scale=true;             %scale for displaying gradients
    dispDef.tikz=false;             %save on tikz's format
    dispDef.on=false;               %enable/disable display
    dispDef.d3=false;               %3D display
    dispDef.d2=false;               %2D display
    dispDef.contour=false;          %display contour
    dispDef.save=true;              %save display
    dispDef.approxGrad=false;      %display gradients of the surrogate model 
    dispDef.realGrad=false;        %display actual gradients
    dispDef.ci.on=false;            %display confidence intervals (if available)
    dispDef.ci.type='0';            %choose CI to dispaly
    dispDef.newfig=true;            %display in new figure
    dispDef.opt=[];                 %plot options
    dispDef.uni=false;              %use uniform color
    dispDef.color=[];               %choose display color   
    dispDef.xlabel='x_1';           %X-axis label
    dispDef.ylabel='x_2';           %Y-axis label
    dispDef.zlabel='';              %Z-axis label
    dispDef.title='';               %title of the figure
    dispDef.render=false;           %enable/disable 3D rendering
    dispDef.pts=false;              %display sample points
    dispDef.num=0;                  %number of the display numérotation affichage
    dispDef.tex=true;               %save data in TeX file
    dispDef.bar=false;              %display using bar
    dispDef.trans=false;            %display using transparency
    dispDef.nv=Inf;                 %number of sample points on the reference grid
    dispDef.steps=0;                %number of steps on the reference grid 
if nargout==0
    global aff
    aff=dispDef;
end
