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

%% Ordering data (for manipulating nd-arrays)
% responses and gradients
% INPUTS:
% - dataIn: input data
% - type: kind of reodering (sampleIn,sampleOut,respOut,gradOut)
% OUTPUTS:
% - dataOut: reordered data

function dataOut=orderData(obj,dataIn,type)
switch type
    case 'sampleIn'
        %size of the input data
        obj.sizeNonSample=[size(dataIn,1),size(dataIn,2),size(dataIn,3)];
        %in the case of nd-array
        if obj.sizeNonSample(3)>1
            dataOut=reshape(dataIn,[ obj.sizeNonSample(1)*obj.sizeNonSample(2),obj.sizeNonSample(3),1]);
        else
            dataOut=dataIn;
        end
    case 'sampleOut'
        if obj.sizeNonSample(3)>1
            dataOut=reshape(dataIn,[ obj.sizeNonSample(1),obj.sizeNonSample(2),obj.sizeNonSample(3)]);
        else
            dataOut=dataIn;
        end
    case 'respOut'
        if obj.sizeNonSample(3)>1
            dataOut=reshape(dataIn,[ obj.sizeNonSample(1),obj.sizeNonSample(2)]);
        else
            dataOut=dataIn;
        end
    case 'gradOut'
        if obj.sizeNonSample(3)>1
            dataOut=reshape(dataIn,[ obj.sizeNonSample(1),obj.sizeNonSample(2),obj.sizeNonSample(3)]);
        else
            dataOut=dataIn;
        end
end
end