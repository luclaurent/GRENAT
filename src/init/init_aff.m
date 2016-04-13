%% Initialization of display variables
%% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

function aff_def=init_aff()

    aff_def.scale=true;             %scale for displaying gradients
    aff_def.tikz=false;             %save on tikz's format
    aff_def.on=false;               %enable/disable display
    aff_def.d3=false;               %3D display
    aff_def.d2=false;               %2D display
    aff_def.contour=false;          %display contour
    aff_def.save=true;              %save display
    aff_def.grad_approx=false;       %display gradients of the surrogate model 
    aff_def.grad_real=false;        %display actual gradients
    aff_def.ic.on=false;            %display confidence intervals (if available)
    aff_def.ic.type='0';            %choose CI to dispaly
    aff_def.newfig=true;            %display in new figure
    aff_def.opt=[];                 %plot options
    aff_def.uni=false;              %use uniform color
    aff_def.color=[];               %choose display color   
    aff_def.xlabel='x_1';           %X-axis label
    aff_def.ylabel='x_2';           %Y-axis label
    aff_def.zlabel='';              %Z-axis label
    aff_def.title='';               %title of the figure
    aff_def.render=false;           %enable/disable 3D rendering
    aff_def.pts=false;              %display sample points
    aff_def.num=0;                  %number of the display numérotation affichage
    aff_def.tex=true;               %save data in TeX file
    aff_def.bar=false;              %display using bar
    aff_def.trans=false;            %display using transparency
    aff_def.nv=Inf;                 %number of sample points on the reference grid
    aff_def.steps=0;                 %number of steps on the reference grid 
if nargout==0
    global aff
    aff=aff_def;
end
