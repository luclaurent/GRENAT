%% Method of MissData class
% L. LAURENT -- 02/08/2017 -- luc.laurent@lecnam.net

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


%% Display information concerning missing data
% INPUTS:
% - none
% OUTPUTS:
% - none

function show(obj)
if obj.verbose
    if obj.nbMissResp==0&&obj.nbMissGrad==0
        Gfprintf('>>> No missing data\n');
    end
    %
    if obj.nbMissResp~=0
        Gfprintf('>>> %i Missing response(s) at point(s):\n',obj.nbMissResp);
        %
        for ii=1:obj.nbMissResp
            numPts=obj.ixMissResp(ii);
            Gfprintf(' n%s %i (%4.2f',char(176),numPts,obj.sampling(numPts,1));
            if obj.nP>1;fprintf(',%4.2f',obj.sampling(numPts,2:end));end
            fprintf(')\n');
        end
    end
    %
    if ~obj.emptyGrad
        if obj.nbMissGrad~=0
            Gfprintf('>>> %i Missing gradient(s) at point(s):\n',obj.nbMissGrad);
            %sort responses
            [~,iS]=sort(obj.ixMissGrad(:,1));
            %
            for ii=1:obj.nbMissGrad
                numPts=obj.ixMissGrad(iS(ii),1);
                component=obj.ixMissGrad(ii,2);
                Gfprintf(' n%s %i (%4.2f',char(176),numPts,obj.sampling(numPts,1));
                if obj.nP>1;fprintf(',%4.2f',obj.sampling(numPts,2:end));end
                fprintf(')');
                fprintf('  component: %i\n',component);
            end
            Gfprintf('----------------\n')
        end
    end
end
end
