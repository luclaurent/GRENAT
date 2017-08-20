%% Method of KernMatrix class
% L. LAURENT -- 18/07/2017 -- luc.laurent@lecnam.net

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


%% Compute new inter-distances between sample points (after adding new sample points)
% INPUTS:
% - None
% OUTPUTS:
% - iX: structure that stores all the indices required for building the
% kernel matrices

function iX=computeIX(obj)
%
if obj.requireIndices
    ns=obj.nS;
    np=obj.nP;
    % Building indices system
    %table of indices for inter-lenghts  (1), responses (1)
    tmpIX=allcomb(1:ns,1:ns);
    iXsampling=tmpIX(tmpIX(:,1)<=tmpIX(:,2),:);
    iXmatrix=(iXsampling(:,1)-1)*ns+iXsampling(:,2);
    %
    iX.iXsampling=iXsampling;
    iX.matrix=iXmatrix;
    %for gradients
    if obj.computeD
        %
        sizeMatRc=(ns^2+ns)/2;
        sizeMatRa=np*sizeMatRc;
        sizeMatRi=np^2*sizeMatRc;
        iXmatrixAb=zeros(sizeMatRa,1);
        iXmatrixI=zeros(sizeMatRi,1);
        %
        ite=0;
        iteAb=0;
        %table of indices for 1st derivatives (2)
        for ii=1:ns
            %
            ite=ite(end)+(1:(ns-ii+1));
            iteAb=iteAb(end)+(1:((ns-ii+1)*np));
            %
            debb=(ii-1)*np*ns+ii;
            finb=ns^2*np-(ns-ii);
            lib=debb:ns:finb;
            %
            iXmatrixAb(iteAb)=lib;
        end
        %table of indices for second derivatives
        a=zeros(ns*np,np);
        decal=0;
        precI=0;
        for ii=1:ns
            li=1:ns*np^2;
            a(:)=decal+li;
            decal=a(end);
            b=a';
            iteI=precI+(1:(np^2*(ns-(ii-1))));
            debb=(ii-1)*np^2+1;
            finb=np^2*ns;
            iteb=debb:finb;
            iXmatrixI(iteI)=b(iteb);
            precI=iteI(end);
        end
        %store indices
        iX.matrixAb=iXmatrixAb;
        iX.matrixI=iXmatrixI;
    end
    %
    obj.iX=iX;
    %
    obj.requireIndices=false;
else
    iX=obj.iX;
end

end