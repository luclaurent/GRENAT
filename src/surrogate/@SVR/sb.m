%% Method of SVR class
% L. LAURENT -- 18/08/2017 -- luc.laurent@lecnam.net

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

%% Compute the the Span Bound of the LOO error for SVR/GSVR
%from Vapnik & Chapelle 2000 / Chapelle, Vapnik, Bousquet & S. Mukherjee 2002/Chang & Lin 2005
% INPUTS:
% - paraValIn: value of the hyperparameters
% - type: kind of computation (optional, defaut: final)
% OUTPUTS:
% - spanBound: value of the Span Bound

function spanBound=sb(obj,paraValIn,type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%various situations
modFinal=true;
if nargin==3
    switch type
        case 'final'    %final mode (compute variances)
            modFinal=true;
        otherwise
            modFinal=false;
    end
end
if modFinal;countTime=mesuTime;end
%%
if nargin==1;paraValIn=obj.paraVal;end
%compute matrices
obj.compute(paraValIn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%size of the kernel matrix
sizePsi=size(obj.K,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compute St
%diagonal of inverse of KUSV
DiKSV=diag(obj.iKUSV);
%compute St^2
St2b=zeros(sizePsi,1);
St2b(obj.iXsvUSV)=1./DiKSV(1:obj.nbUSV);
if obj.nbBSV>0
    PsiBSV=obj.K(obj.iXsvBSV(:),obj.iXsvBSV(:));
    Vb=[obj.K(obj.iXsvUSV,obj.iXsvBSV); ones(1,obj.nbBSV)];
    St2b(obj.iXsvBSV)=diag(PsiBSV)-diag(Vb'*obj.iKUSV*Vb);
end;

spanBound=1/sizePsi...
    *(St2b'*obj.FullAlphaLambdaPP...
    +sum(obj.xiTau))...
    +obj.metaData.e0;

if modFinal;countTime.stop;end
end