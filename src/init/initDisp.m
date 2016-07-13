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

classdef initDisp < handle
    properties
        scale=true;             %scale for displaying gradients
        tikz=false;             %save on tikz's format
        on=true;                %enable/disable display
        d3=false;               %3D display
        d2=false;               %2D display
        contour=false;          %display contour
        save=false;             %save display
        directory='save';       %directory for saving figures
        gridGrad=false;         %display gradients at the points of the grid
        sampleGrad=false;       %display gradients at sample points
        ciOn=false;             %display confidence intervals (if available)
        ciType='0';             %choose CI to display
        newFig=false;           %display in new figure
        opt=[];                 %plot options
        uni=false;              %use uniform color
        color=[];               %choose display color
        xlabel='x_1';           %X-axis label
        ylabel='x_2';           %Y-axis label
        zlabel='';              %Z-axis label
        title='';               %title of the figure
        render=false;           %enable/disable 3D rendering
        samplePts=true;         %display sample points
        num=0;                  %number of the display
        tex=true;               %save data in TeX file
        bar=false;              %display using bar
        trans=false;            %display using transparency
        nv=Inf;                 %number of sample points on the reference grid
        nbSteps=0;              %number of steps on the reference grid
        step=[];                %size of the step of the grid
    end
    properties (Access = private,Constant)
        infoProp=affectTxtProp;
    end
    methods
        %constructor
        function obj=initDisp(varargin)            
            %if they are input variables
            if nargin>0;conf(obj,varargin{:});end
            %display message
            fprintf('=========================================\n')
            fprintf(' >>> Initialization of the display configuration\n');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%setters
        function set.scale(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.scale,boolIn)
                    fprintf(' >>> Scaling of gradients: ');
                    SwitchOnOff(boolIn);
                end
                obj.scale=boolIn;
            end
        end
        %
        function set.on(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.on,boolIn)
                    fprintf(' >>> Display: ');
                    SwitchOnOff(boolIn);
                end
                obj.on=boolIn;
            end
        end
        %
        function set.d3(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.d3,boolIn)
                    fprintf(' >>> 3D display: ');
                    SwitchOnOff(boolIn);
                end
                obj.d3=boolIn;
            end
        end
        %
        function set.d2(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.d2,boolIn)
                    fprintf(' >>> 2D display: ');
                    SwitchOnOff(boolIn);
                end
                obj.d2=boolIn;
            end
        end
        %
        function set.contour(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.contour,boolIn)
                    fprintf(' >>> Display contour: ');
                    SwitchOnOff(boolIn);
                end
                obj.contour=boolIn;
            end
        end
        %
        function set.tikz(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.tikz,boolIn)
                    fprintf(' >>> Save display using tikz (matlab2tikz): ');
                    SwitchOnOff(boolIn);
                end
                obj.tikz=boolIn;
            end
        end
        %
        function set.save(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.save,boolIn)
                    fprintf(' >>> Save display using fig: ');
                    SwitchOnOff(boolIn);
                end
                obj.save=boolIn;
            end
        end
        %
        function set.directory(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.directory,charIn)
                    fprintf(' >>> Saving directory : %s (previous %s)',charIn,obj.directory);
                end
                obj.directory=charIn;
            end
        end
        %
        function set.gridGrad(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.gridGrad,boolIn)
                    fprintf(' >>> Show gradients on the grid: ');
                    SwitchOnOff(boolIn);
                end
                obj.gridGrad=boolIn;
            end
        end
        %
        function set.sampleGrad(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.sampleGrad,boolIn)
                    fprintf(' >>> Show gradients at the sample points: ');
                    SwitchOnOff(boolIn);
                end
                obj.sampleGrad=boolIn;
            end
        end
        %
        function set.ciOn(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.ciOn,boolIn)
                    fprintf(' >>> Show confidence intervals (if available): ');
                    SwitchOnOff(boolIn);
                end
                obj.ciOn=boolIn;
            end
        end
        %
        function set.ciType(obj,charIn)
            if isG(charIn,'char')
                if xor(obj.ciType,charIn)
                    fprintf(' >>> Type of confidence interval : %s (previous %s)',charIn,obj.ciType);
                end
                obj.ciType=charIn;
            end
        end
        %
        function set.newFig(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.newFig,boolIn)
                    fprintf(' >>> Show in new figure: ');
                    SwitchOnOff(boolIn);
                end
                obj.newFig=boolIn;
            end
        end
        %
        function set.opt(obj,charIn)
            if isG(charIn,'char')
                if xor(obj.opt,charIn)
                    fprintf(' >>> Plot options : %s (previous %s)',charIn,obj.opt);
                end
                obj.opt=charIn;
            end
        end
        %
        function set.xlabel(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.xlabel,charIn)
                    fprintf(' >>> X label : %s (previous %s)',charIn,obj.xlabel);
                end
                obj.xlabel=charIn;
            end
        end
        %
        function set.ylabel(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.ylabel,charIn)
                    fprintf(' >>> Y label : %s (previous %s)',charIn,obj.ylabel);
                end
                obj.ylabel=charIn;
            end
        end
        %
        function set.zlabel(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.zlabel,charIn)
                    fprintf(' >>> Z label : %s (previous %s)',charIn,obj.zlabel);
                end
                obj.zlabel=charIn;
            end
        end
        %
        function set.title(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.title,charIn)
                    fprintf(' >>> Z label : %s (previous %s)',charIn,obj.title);
                end
                obj.title=charIn;
            end
        end
        %
        function set.color(obj,charIn)
            if isG(charIn,'char')
                if strcmp(obj.color,charIn)
                    fprintf(' >>> Color for uniform display : %s (previous %s)',charIn,obj.color);
                end
                obj.color=charIn;
            end
        end
        %
        function set.uni(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.uni,boolIn)
                    fprintf(' >>> Uniform color: ');
                    SwitchOnOff(boolIn);
                end
                obj.uni=boolIn;
            end
        end
        %
        function set.render(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.render,boolIn)
                    fprintf(' >>> 3D rendering: ');
                    SwitchOnOff(boolIn);
                end
                obj.render=boolIn;
            end
        end
        %
        function set.samplePts(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.samplePts,boolIn)
                    fprintf(' >>> Show sample points: ');
                    SwitchOnOff(boolIn);
                end
                obj.samplePts=boolIn;
            end
        end
        %
        function set.num(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.num~=doubleIn)
                    fprintf(' >>> Number of the plot: %d (previous %d)',doubleIn,obj.num);
                end
                obj.num=doubleIn;
            end
        end
        %
        function set.nbSteps(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.nbSteps~=doubleIn)
                    fprintf(' >>> Number of steps of the reference grid: %d (previous %d)',doubleIn,obj.nbSteps);
                end
                obj.nbSteps=doubleIn;
            end
        end
        %
        function set.step(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.step~=doubleIn)
                    fprintf(' >>> Size of steps of the reference grid: %d (previous %d)',doubleIn,obj.step);
                end
                obj.step=doubleIn;
            end
        end
        %
        function set.nv(obj,doubleIn)
            if isG(doubleIn,'double')
                if all(obj.nv~=doubleIn)
                    fprintf(' >>> Number of sample points of the reference grid: %d (previous %d)',doubleIn,obj.nv);
                end
                obj.nv=doubleIn;
            end
        end
        %
        function set.tex(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.tex,boolIn)
                    fprintf(' >>> Save data in TeX file: ');
                    SwitchOnOff(boolIn);
                end
                obj.tex=boolIn;
            end
        end
        %
        function set.bar(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.bar,boolIn)
                    fprintf(' >>> Use bar on plot: ');
                    SwitchOnOff(boolIn);
                end
                obj.bar=boolIn;
            end
        end
        %
        function set.trans(obj,boolIn)
            if isG(boolIn,'logical')
                if xor(obj.trans,boolIn)
                    fprintf(' >>> Transparency: ');
                    SwitchOnOff(boolIn);
                end
                obj.trans=boolIn;
            end
        end  
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %define properties
        function conf(obj,varargin)
            %list properties
            listProp=properties(obj);
            okConf=false;
            %if a input variable is specifiec
            if nargin>2
                %if the number of input argument is even
                if  mod(nargin-1,2)==0
                    %along the argument
                    for itV=1:2:nargin-1
                        %extract keyword and associated value
                        keyW=varargin{itV};
                        keyV=varargin{itV+1};
                        %if the first argument is a string
                        if isa(varargin{1},'char')
                            %check if the keyword is acceptable
                            if ismember(keyW,listProp)
                                okConf=true;
                                obj.(keyW)=keyV;
                            else
                                fprintf('>> Wrong keyword %s\n',keyW);
                            end
                        end
                    end
                end
                if ~okConf
                    fprintf('\nWrong syntax used for conf method\n')
                    fprintf('use: conf(''key1'',val1,''key2'',val2...)\n')
                    fprintf('\nList of the avilable keywords:\n');
                    dispTableTwoColumnsStruct(listProp,obj.infoProp);
                end
            else
                fprintf('Current configuration\n');
                disp(obj);
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function for declaring the purpose of each properties
function info=affectTxtProp()
info.scale='scale for displaying gradients';
info.tikz='save on tikz''s format';
info.on='enable/disable display';
info.d3='3D display';
info.d2='2D display';
info.contour='display contour';
info.save='save display';
info.directory='directory for saving figures';
info.gridGrad='display gradients at the points of the grid';
info.sampleGrad='display gradients at sample points';
info.ciOn='display confidence intervals (if available)';
info.ciType='choose CI to display';
info.newFig='display in new figure';
info.opt='plot options';
info.uni='use uniform color';
info.color='choose display color';
info.xlabel='X-axis label';
info.ylabel='Y-axis label';
info.zlabel='Z-axis label';
info.title='title of the figure';
info.render='enable/disable 3D rendering';
info.samplePts='display sample points';
info.num='number of the display numérotation affichage';
info.tex='save data in TeX file';
info.bar='display using bar';
info.trans='display using transparency';
info.nv='number of sample points on the reference grid';
info.nbSteps='number of steps on the reference grid';
info.step='size of the step of the grid';
end

%function display table with two columns of text
function dispTableTwoColumnsStruct(tableFiedIn,structIn)
%size of every components in tableA
sizeA=cellfun(@numel,tableFiedIn);
maxA=max(sizeA);
%space after each component
spaceA=maxA-sizeA+3;
spaceTxt=' ';
%display table
for itT=1:numel(tableFiedIn)
    fprintf('%s%s%s\n',tableFiedIn{itT},spaceTxt(ones(1,spaceA(itT))),structIn.(tableFiedIn{itT}));
end
end

%function for checking type a variable and display erro message
function okG=isG(varIn,typeIn)
okG=isa(varIn,typeIn);
if ~okG;fprintf(' Wrong input variable. Required: %s (current: %s)\n',typeIn,class(varIn));end
end

%display change of state
function SwitchOnOff(boolIn)
if boolIn;
    fprintf(' On (previous Off)\n');
else
    fprintf(' Off (previous On)\n');
end
end



