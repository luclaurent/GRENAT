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

%% Overload isfield (to be adapted to properties
% INPUTS:
% - type: type of data to be normalized
% - dataIn: array of data which will be normalized (optional)
% OUTPUTS:
% - dataOut: normalized data (if normalization is not active then
% dataOut=dataIn)

%Normalization of the input data
function dataOut=normInputData(obj,type,dataIn)
if obj.confMeta.normOn
    %for various situations
    switch type
        case 'initSamplePts'
            [obj.samplingN,infoDataS]=NormRenorm(obj.sampling,'norm');
            obj.normMeanS=infoDataS.mean;
            obj.normStdS=infoDataS.std;
            obj.normSamplePtsIn=true;
        case 'initResp'
            [obj.respN,infoDataR]=NormRenorm(obj.resp,'norm');
            obj.normMeanR=infoDataR.mean;
            obj.normStdR=infoDataR.std;
            obj.normRespIn=true;
        case 'SamplePts'
            dataOut=NormRenorm(dataIn,'norm',infoDataS);
        case 'Resp'
            dataOut=NormRenorm(dataIn,'norm',infoDataR);
        case 'Grad'
            if ~isempty(dataIn)
                dataOut=NormRenormG(dataIn,'norm',infoDataS,infoDataR);
            else
                dataOut=[];
            end
    end
else
    if nargin>2
        dataOut=dataIn;
    end
end
end