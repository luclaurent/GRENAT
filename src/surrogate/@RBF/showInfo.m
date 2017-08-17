

%% Show information in the console
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
        dispTxtOnOff(obj.metaData.recond,'>> Correction of matrix condition number:',[],true);
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