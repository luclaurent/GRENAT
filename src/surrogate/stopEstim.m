%% Fonction assurant l'arret de la procedure d'optimisation
% L. LAURENT -- 07/01/2011 -- luc.laurent@lecnam.net

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

function stop=stopEstim(x,optimValues,state)

%  x : point calculated at the current iteration 
%  optimValues: structure containing data at the current iteration
%  state: various state of the algorithm
%  stop: stopping status of the minimization algorithm

stop=false;
switch state
    case 'iter'
        if size(x,2)==1
            plot(x,optimValues.fval,'o','MarkerSize',3);
            text(x+.05,optimValues.fval,num2str(optimValues.iteration));
            drawnow
        elseif size(x,2)==2
            plot3(x(1),x(2),optimValues.fval,'o','MarkerSize',3);
            text(x(1),x(2)+.05,optimValues.fval,num2str(optimValues.iteration));
            drawnow
        end
    case 'interrupt'
        %stop=true;
    case 'init'
        if size(x,2)<3
            figure;
            title('Iteration of the minimisation algorithm')
            hold on
        end
    case 'done'
        if size(x,2)<3
            hold off
        end
        
    otherwise
end


