% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function for checking interpolation
% L. LAURENT -- 02/08/2016 -- luc.laurent@lecnam.net

%     GRENAT - GRadient ENhanced Approximation Toolbox
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016  Luc LAURENT <luc.laurent@lecnam.net>
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

function statusI=checkInterpRG(ZRef,ZApp,type,critR,critG)
%default configuration
if nargin<5;critG=[];end
if nargin<4;critR=[];end
statusI=true;

%check parameters
if isempty(critG);limitGrad=1e-4;else limitGrad=critG;end
if isempty(critR);limitResp=1e-4;else limitResp=critR;end

switch type
    case 'resp'
        diffZ=abs(ZApp-ZRef);
        IXZcheck=find(diffZ>limitResp);
        if ~isempty(IXZcheck)
            Gfprintf('Interpolation issue (responses)\n')
            Gfprintf('Num\t||DiffZ \t||Eval \t\t||Zcheck\n');
            conc=vertcat(IXZcheck',diffZ(IXZcheck)',ZRef(IXZcheck)',ZApp(IXZcheck)');
            Gfprintf('%d\t||%4.2e\t||%4.2e\t||%4.2e\n',conc(:));
            statusI=false;
        end
    case 'grad'
        diffGZ=abs(ZApp-ZRef);
        IXGZcheck=find(diffGZ>limitGrad);
        if ~isempty(IXGZcheck)
            [IXi,~]=ind2sub(size(diffGZ),IXGZcheck);
            IXi=unique(IXi);
            Gfprintf('Interpolation issue (gradient)\n')
            nb_var=size(ZApp,2);
            tt=repmat('\t',1,nb_var);
            Gfprintf(['Num\t||DiffGZ' tt '||Grad\t' tt '||GZcheck\n']);
            conc=[IXi,diffGZ(IXi,:),ZRef(IXi,:),ZApp(IXi,:)]';
            tt=repmat('%4.2e\t',1,nb_var);
            tt=['%d\t||' tt '||' tt '||' tt '\n'];
            Gfprintf(tt,conc(:))
            statusI=false;
        end
        diffNG=abs(sqrt(sum(ZRef.^2,2))-sqrt(sum(ZApp.^2,2)));
        IXNGZverif=find(diffNG>limitGrad);
        if ~isempty(IXNGZverif)
            Gfprintf('Interpolation issue (gradient)\n')
            Gfprintf('DiffNG\n')
            Gfprintf('%4.2e\n',diffNG(IXNGZverif))
        end
end
end