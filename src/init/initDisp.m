%% Initialization of display variables
% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

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

function dispDef=initDisp()

    dispDef.scale=true;             %scale for displaying gradients
    dispDef.tikz=false;             %save on tikz's format
    dispDef.on=false;               %enable/disable display
    dispDef.d3=false;               %3D display
    dispDef.d2=false;               %2D display
    dispDef.contour=false;          %display contour
    dispDef.save=false;              %save display
    dispDef.directory='save';       %directory for saving figures
    dispDef.gridGrad=false;         %display gradients at the points of the grid
    dispDef.sampleGrad=false;       %display gradients at sample points
    dispDef.ci.on=false;            %display confidence intervals (if available)
    dispDef.ci.type='0';            %choose CI to dispaly
    dispDef.newFig=true;            %display in new figure
    dispDef.opt=[];                 %plot options
    dispDef.uni=false;              %use uniform color
    dispDef.color=[];               %choose display color   
    dispDef.xlabel='x_1';           %X-axis label
    dispDef.ylabel='x_2';           %Y-axis label
    dispDef.zlabel='';              %Z-axis label
    dispDef.title='';               %title of the figure
    dispDef.render=false;           %enable/disable 3D rendering
    dispDef.samplePts=true;         %display sample points
    dispDef.num=0;                  %number of the display numérotation affichage
    dispDef.tex=true;               %save data in TeX file
    dispDef.bar=false;              %display using bar
    dispDef.trans=false;            %display using transparency
    dispDef.nv=Inf;                 %number of sample points on the reference grid
    dispDef.nbSteps=0;              %number of steps on the reference grid 
    dispDef.step=[];                %size of the step of the grid 
    %declare as a global variable
    global dispData
    dispData=dispDef;
end
