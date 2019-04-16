%% Method of RBF class
% L. LAURENT -- 15/08/2017 -- luc.laurent@lecnam.net

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


%% Show information in the console
% INPUTS:
% - type: type of information to display (start,end,cv,update)
% OUTPUTS:
% - none

function showInfo(obj,type)
switch type
    case {'start','START','Start'}
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Display Building information
        textd='++ Type: ';
        textf='';
        Gfprintf('\n%s\n',[textd 'Radial Basis Function ((G)RBF)' textf]);
        %
        Gfprintf('>>> Building : ');
        dispTxtOnOff(obj.flagG,'GRBF','RBF',true);
        Gfprintf('>> Kernel function: %s\n',obj.kernelFun);
        %
        if dispTxtOnOff(obj.metaData.cv.on,'>> CV: ',[],true)
            dispTxtOnOff(obj.metaData.cv.full,'>> Computation all CV criteria: ',[],true);
            dispTxtOnOff(obj.metaData.cv.disp,'>> Show CV: ',[],true);
        end
        %
        dispTxtOnOff(obj.metaData.recond,'>> Correction of matrix condition number: ',[],true);
        if dispTxtOnOff(obj.metaData.estim.on,'>> Estimation of the hyperparameters: ',[],true)
            Gfprintf('>> Algorithm for estimation: %s\n',obj.metaData.estim.method);
            Gfprintf('>> Bounds: [%d , %d]\n',obj.metaData.para.l.Min,obj.metaData.para.l.Max);
            switch obj.kernelFun
                case {'expg','expgg'}
                    Gfprintf('>> Bounds for exponent: [%d , %d]\n',obj.metaData.para.p.Min,obj.metaData.para.p.Max);
                case 'matern'
                    Gfprintf('>> Bounds for nu (Matern): [%d , %d]\n',obj.metaData.para.nu.Min,obj.metaData.para.nu.Max);
            end
            dispTxtOnOff(obj.metaData.estim.aniso,'>> Anisotropy: ',[],true);
            dispTxtOnOff(obj.metaData.estim.dispIterCmd,'>> Show estimation steps in console: ',[],true);
            dispTxtOnOff(obj.metaData.estim.dispIterGraph,'>> Plot estimation steps: ',[],true);
        else
            Gfprintf('>> Value(s) hyperparameter(s):');
            fprintf('%d',obj.metaData.para.l.Val);
            fprintf('\n');
            switch obj.kernelFun
                case {'expg','expgg'}
                    Gfprintf('>> Value of the exponent:');
                    fprintf(' %d',obj.metaData.para.p.Val);
                    fprintf('\n');
                case {'matern'}
                    Gfprintf('>> Value of nu (Matern): %d \n',obj.metaData.para.nu.Val);
            end
        end
        %
        Gfprintf('\n');
    case {'update'}
        Gfprintf(' ++ Update RBF\n');
    case {'cv','CV'}
        Gfprintf(' ++ Run final Cross-Validation\n');
    case {'end','End','END'}
        Gfprintf(' ++ END building RBF\n');
end
end
