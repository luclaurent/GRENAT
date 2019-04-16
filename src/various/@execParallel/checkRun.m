%% Static method of execParallel class
% L. LAURENT -- 01/10/2012 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016-2017-2017  Luc LAURENT <luc.laurent@lecnam.net>
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

%% check if the parallel toolbox is available, if java is loaded and
% if the function is executed in matlab
% INPUTS:
% - none
% OUTPUTS:
% - runOk: evertything is ok to run a pool

function runOk=checkRun()
javaOk=usejava('jvm');
matlabOk=~isOctave;
parallelOk=license('test','Distrib_Computing_Toolbox');
runOk=javaOk&matlabOk&parallelOk;
if ~javaOk;Gfprintf('>> Matlab started without java support (remove -nojvm flag)\n');end
if ~matlabOk;Gfprintf('>> Code run with Octave (no parallelism)\n');end
if ~parallelOk;Gfprintf('>> The Distibuted Computing Toolbox is unavailable\n');end
end