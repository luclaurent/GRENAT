%% Static method of GRENAT class
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

%% Function for declaring the purpose of each properties
%gradient-enhanced or indirect gradient-enhanced surrogate model
% INPUTS:
% - none
% OUTPUTS:
% - info: details for each properties

%%% NEED TO BE UPDATED

function info=affectTxtProp()
info.type='Type of the surrogate model';
info.sampling='Coordinates of the sample points';
info.resp='Value(s) of the responses at the sample points';
info.grad='Value(s) of the gradients at the sample points';
info.samplingN='Normalized coordinates of the sample points';
info.respN='Value(s) of the normalized responses at the sample points';
info.gradN='Value(s) of the normalized gradients at the sample points';
info.nonSamplePts='Coordinates of the non-sample points';
info.nonSampleResp='Value(s) of the approximated responses calculated at the non-sample points';
info.nonSampleGrad='Value(s) of the approximated gradients calculated at the non-sample points';
info.nonSamplePtsN='Normalized coordinates of the  non-sample points';
info.nonSampleRespN='Value(s) of the normalized approximated responses calculated at the non-sample points';
info.nonSampleGradN='Value(s) of the normalized approximated gradients calculated at the non-sample points';
info.nonSampleVar='Value(s) of the variance calculated at the non-sample points';
info.nonSampleCI='Structure containing the bounds of the confidence intervals (68%, 95%, 99%)';
info.nonSampleEI='Value(s) of the expected improvment calculated at the non-sample points';
info.norm='Structure containing the normalization data';
info.normMeanS='Mean value of the sample points (vector)';
info.normStdS='Standard deviation of the sample points (vector)';
info.normMeanR='Mean value of the responses';
info.normStdR='Standard deviation of the responses';
info.err='Structure containing the values of the error criteria';
info.sampleRef='Array of the sample points used for the reference response surface';
info.respRef='Array of the responses of the reference response surface';
info.gradRef='Array of the gradients of the reference response surface';
info.confMeta='Class object (initMeta) containing information about the configuration (metamodel) (conf method for modifying it)';
info.dataTrain='Structures containing data about the training of the surrogate model';
info.confDisp='Class object (initDisp) containing information about the display (conf method for modifying it)';
info.miss='Structure Containing information about the missing data';
end
