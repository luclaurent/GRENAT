%% Build space for plotting 2D function
% L. LAURENT -- 05/01/2011 -- luc.laurent@lecnam.net

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

function [XY,dispData]=buildDisp(doeData,dispData)

fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
fprintf('     >>> BUILD DISPLAY <<<\n');
[tMesu,tInit]=mesuTime;
%dimension of the sapce
spaDim=numel(doeData.Xmin);

% the grid is built depending on the number of designa variables

if spaDim==1
    XY=linspace(doeData.Xmin,doeData.Xmax,dispData.nbSteps)';
    
    % in 2D the grid is defined using meshgrid
elseif spaDim==2
    x=linspace(doeData.Xmin(1),doeData.Xmax(1),dispData.nbSteps);
    y=linspace(doeData.Xmin(2),doeData.Xmax(2),dispData.nbSteps);
    [gridX,gridY]=meshgrid(x,y);
    
    XY=zeros(size(gridX,1),size(gridX,2),2);
    XY(:,:,1)=gridX;
    XY(:,:,2)=gridY;
    
else
    % in nD the full factorial function is used
    grid=fullFactDOE(dispData.nbSteps,doeData.Xmin,doeData.Xmax);
    
    %reordering the grid
    XY=zeros(size(grid,1),1,spaDim);
    for ii=1:spaDim
        XY(:,:,ii)=grid(:,ii);
    end
    
    
end

%step of the grid 
dispData.step=abs(doeData.Xmax-doeData.Xmin)./dispData.nbSteps;

fprintf(' >> Number of points on the grid %i (%i',dispData.nbSteps^spaDim,dispData.nbSteps);
fprintf('x%i',dispData.nbSteps*ones(1,spaDim-1));fprintf(')\n');

mesuTime(tMesu,tInit);
fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
