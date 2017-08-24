%% Method of GRENAT class
% L. LAURENT -- 26/06/2016 -- luc.laurent@lecnam.net

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

%% Update sample points (normalized if necessary)
% INPUTS:
% - newSample: array of new sample points
% OUTPUTS:
% - sampleOk: sample points ready to be stored

function sampleOk=updateSampling(obj,newSample)
%add sample points to the MissingData's object
obj.miss.addSampling(newSample);
%
if ~isempty(newSample)
    if isempty(obj.sampling)
        %first add new sampling
        sampleOk=newSample;
        %add sample points to the NormRenorm's object if normalization is required
        if obj.confMeta.normOn
            obj.samplingN=obj.norm.addSampling(obj.sampling);
        else
            obj.samplingN=obj.sampling;
        end
    else
        % concatenate sample points
        sampleOk=[obj.sampling;newSample];
        % normalize the new sample points using the existing database
        if obj.confMeta.normOn
            obj.samplingN=[obj.samplingN;obj.norm.Norm(newSample,'s')];
        else
            obj.samplingN=[obj.samplingN;newSample];
        end
    end
    %
    initRunTrain(obj,true);
else
    Gfprintf('ERROR: Empty array of sample points\n');
end