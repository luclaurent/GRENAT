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
% kernel matrices for new sample points

function iX=computeNewIX(obj)
oldNs=obj.nS;
newNs=obj.NnS;
np=obj.nP;
% Building indices system
if obj.computeD
    %
    sizeMatRc=(newNs^2+newNs)/2;
    sizeMatRa=np*sizeMatRc;
    sizeMatRi=np^2*sizeMatRc;
    iXmatrixAb=zeros(sizeMatRa,1);
    iXmatrixI=zeros(sizeMatRi,1);
    %
    iteAb=0;
    %table of indices for inter-lengths (1), responses (1) and 1st
    %derivatives (2)
    if newNs>1
        for ii=1:newNs
            %
            iteAb=iteAb(end)+(1:((newNs-ii+1)*np));
            %
            debb=(ii-1)*newNs*np+ii;
            finb=newNs*(newNs*np-1)+ii;
            lib=debb:newNs:finb;
            iXmatrixAb(iteAb)=lib;
        end
        %table of indices for second derivatives
        a=zeros(newNs*np,np);
        decal=0;
        precI=0;
        for ii=1:newNs
            li=1:newNs*np^2;
            a(:)=decal+li;
            decal=a(end);
            b=a';
            %
            iteI=precI+(1:(np^2*(newNs-(ii-1))));
            %
            debb=(ii-1)*np^2+1;
            finb=np^2*newNs;
            iteb=debb:finb;
            iXmatrixI(iteI)=b(iteb);
            precI=iteI(end);
        end
    end
    %store variables
    iX.matrixAb=iXmatrixAb;
    iX.matrixI=iXmatrixI;
end
%table of indices for inter-lenghts  (1), responses (1)
iXsamplingNO=allcomb(1:newNs,1:oldNs);      %old and new
tmpIX=allcomb(1:newNs,1:newNs);
iXsamplingN=tmpIX(tmpIX(:,1)<=tmpIX(:,2),:); %new only
%linear indices
iXmatrixNO=(iXsamplingNO(:,1)-1)*oldNs+iXsamplingNO(:,2);
iXmatrixN=(iXsamplingN(:,1)-1)*newNs+iXsamplingN(:,2);
%keyboard
%
iX.iXsamplingNO=iXsamplingNO;
iX.iXsamplingN=iXsamplingN;
iX.matrixNO=iXmatrixNO;
iX.matrixN=iXmatrixN;
%
obj.NiX=iX;
end