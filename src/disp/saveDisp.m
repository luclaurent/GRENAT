%% save figure in file
% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox 
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017  Luc LAURENT <luc.laurent@lecnam.net>
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

function fileFig=saveDisp(num,foldS)

if isempty(num)
    global dispData
    
    dispData.num=dispData.num+1;
    num=dispData.num;
end
%generate filename
if ischar(num)
    nameFile=num;
else
    nameFile=['fig_' num2str(num,'%04.0f')];
end

%if the folder does not exist, creation
if ~exist(foldS,'dir')
    mkdir(foldS)
end


set(gcf,'Renderer','painters');      %for saving figure in nodisplay mode
nameFig=[foldS '/' nameFile '.eps'];
namefigM=[foldS '/' nameFile '.fig'];
Gfprintf('>>Save figure: \n fichier %s\n',nameFig);
saveas(gcf, nameFig,'psc2');
saveas(gcf, namefigM,'fig');
fileFig=nameFig;
end


