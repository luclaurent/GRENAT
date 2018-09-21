%% definition of the hyperparameters bounds (for estimation) or values (w/o estimation)
% L. LAURENT -- 18/09/2018 -- luc.laurent@lecnam.net

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

function [lb,ub,val,nbPara,nbPdetails,funCondPara]=definePara(nPIn,kernFun,dataPara,anisoFlag,type)

lb=[];
ub=[];
val=[];

% Number of hyperparameters to estimate
%anisotropy
if anisoFlag
    nbP=nPIn;
    nbPdetails=nbP;
else
    nbP=1;
    nbPdetails=nbP;
end

%dependig of the computation case (estimation or compute
switch type
    case 'estim'        
        % deal with specific cases (depending on the kernel function)
        switch kernFun
            case 'matern'
                lb=[dataPara.l.Min*ones(1,nbP) dataPara.nu.Min];
                ub=[dataPara.l.Max*ones(1,nbP) dataPara.nu.Max];
                nbPdetails=[nbPdetails 1];
            case 'expg'
                lb=[dataPara.l.Min*ones(1,nbP) dataPara.p.Min];
                ub=[dataPara.l.Max*ones(1,nbP) dataPara.p.Max];
                nbPdetails=[nbPdetails 1];
            case 'expgg'
                lb=[dataPara.l.Min*ones(1,nbP) dataPara.p.Min*ones(1,nbP)];
                ub=[dataPara.l.Max*ones(1,nbP) dataPara.p.Max*ones(1,nbP)];
                nbPdetails=[nbPdetails nbPdetails];
            case {'logk','powerk'}
                lb=dataPara.p.Min*ones(1,nbP);
                ub=dataPara.p.Max*ones(1,nbP);
            otherwise
                lb=dataPara.l.Min*ones(1,nbP);
                ub=dataPara.l.Max*ones(1,nbP);
        end
        
    case 'compute'
        %adapt the size of array that contains hyperparameters
        if numel(dataPara.l.Val)==1
            lVal=dataPara.l.Val*ones(1,nbP);
        elseif numel(dataPara.l.Val)==nbP
            lVal=dataPara.l.Val;
        else
            Gfprintf('Error: wrong definition of the l''s hyperparameters\n');
        end
        if numel(dataPara.p.Val)==1
            pVal=dataPara.p.Val*ones(1,nbP);
        elseif numel(dataPara.p.Val)==nbP
            pVal=dataPara.p.Val;
        else
            Gfprintf('Error: wrong definition of the p''s hyperparameters\n');
        end
        % deal with specific cases (depending on the kernel function)
        switch kernFun
            case 'matern'
                val=[lVal dataPara.nu.Val];
                nbPdetails=[nbPdetails 1];
            case 'expg'
                val=[lVal dataPara.p.Val];
                nbPdetails=[nbPdetails 1];
            case 'expgg'
                val=[lVal pVal];
                nbPdetails=[nbPdetails nbPdetails];
            case {'logk','powerk'}
                val=pVal;
            otherwise
                val=lVal;
        end
end
%total number of hyperparameters
nbPara=sum(nbPdetails);

%handle function for conditionning parameters (w/- or w/o anisotropy)
if anisoFlag
    funCondPara=@(x) x;
else
    switch kernFun
        case {'matern','expg','expgg'}
            funCondPara=@(x) [x(:,ones(1,nPIn)) x(2:end)];            
        otherwise
            funCondPara=@(x) x(:,ones(1,nPIn));
    end
end
end