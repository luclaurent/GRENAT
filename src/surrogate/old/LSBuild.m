%% function for least-squares surrogate model
% LS: Least-Squares
% GLS: gradient-base Least Squares
% L. LAURENT -- 27/01/2017 -- luc.laurent@lecnam.net

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

function [ret]=LSBuild(samplingIn,respIn,gradIn,metaData,missData)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Building indexes system for building KRG/GKRG matrices
if availGrad
    
    sizeMatRc=(ns^2+ns)/2;
    sizeMatRa=np*(ns^2+ns)/2;
    sizeMatRi=np^2*(ns^2+ns)/2;
    iXmatrix=zeros(sizeMatRc,1);
    iXmatrixA=zeros(sizeMatRa,1);
    iXmatrixAb=zeros(sizeMatRa,1);
    iXmatrixI=zeros(sizeMatRi,1);
    iXdev=zeros(sizeMatRa,1);
    iXsampling=zeros(sizeMatRc,2);
    
    tmpList=zeros(sizeMatRc,np);
    tmpList(:)=1:sizeMatRc*np;
    
    ite=0;
    iteA=0;
    iteAb=0;
    pres=0;
    %table of indexes for inter-lengths (1), responses (1) and 1st
    %derivatives (2)
    for ii=1:ns
        
        ite=ite(end)+(1:(ns-ii+1));
        iXmatrix(ite)=(ns+1)*ii-ns:ii*ns;
        iXsampling(ite,:)=[ii(ones(ns-ii+1,1)) (ii:ns)'];
        iteAb=iteAb(end)+(1:((ns-ii+1)*np));
        
        debb=(ii-1)*np*ns+ii;
        finb=ns^2*np-(ns-ii);
        lib=debb:ns:finb;
        
        iXmatrixAb(iteAb)=lib;
        
        for jj=1:np
            iteA=iteA(end)+(1:(ns-ii+1));
            decal=(ii-1);
            deb=pres+decal;
            li=deb + (1:(ns-ii+1));
            iXmatrixA(iteA)=li;
            pres=li(end);
            iXdev(iteA)=tmpList(ite,jj);
        end
    end
    %table of indexes for second derivatives
    a=zeros(ns*np,np);
    decal=0;
    precI=0;
    iteI=0;
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
else
    %table of indexes for inter-lenghts  (1), responses (1)
    bmax=ns-1;
    iXmatrix=zeros(ns*(ns-1)/2,1);
    iXsampling=zeros(ns*(ns-1)/2,2);
    ite=0;
    for ii=1:bmax
        ite=ite(end)+(1:(ns-ii));
        iXmatrix(ite)=(ns+1)*ii-ns+1:ii*ns;
        iXsampling(ite,:)=[ii(ones(ns-ii,1)) (ii+1:ns)'];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%store variables
ret.used.sampling=samplingIn;
ret.used.resp=respIn;
ret.used.availGrad=availGrad;
ret.used.grad=gradIn;
ret.used.np=np;
ret.used.ns=ns;
ret.ix.matrix=iXmatrix;
ret.ix.sampling=iXsampling;
ret.build.fct=valFunPoly;
ret.build.fc=valFunPoly';
ret.build.beta=beta;
ret.build.sizeFc=size(valFunPoly,2);
ret.build.y=YY;
ret.build.polyOrder=metaData.polyOrder;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Cross-validation (compute various errors)
if metaData.cv.on
    %countTime=mesuTime;
    Gfprintf(' > Computation CV\n');
%    [ret.build.cv]=LSCV(ret,metaData);
    %countTime.stop;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if availGrad;txt='GLS';else, txt='LS';end
Gfprintf('\n >> END Building %s\n',txt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


%% function for display information
function boolOut=dispTxtOnOff(boolIn,txtInTrue,txtInFalse,returnLine)
boolOut=boolIn;
if nargin==2
    txtInFalse=[];
    returnLine=false;
elseif nargin==3
    returnLine=false;
end
if isempty(txtInFalse)
    Gfprintf('%s',txtInTrue);if boolIn; fprintf('Yes');else, fprintf('No');end
else
    if boolIn; fprintf('%s',txtInTrue);else, fprintf('%s',txtInFalse);end
end
if returnLine
    fprintf('\n');
end
end

