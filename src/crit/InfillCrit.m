%% Compute infill criteria EI/WEI/LCB
% L. LAURENT -- 04/05/2012 -- luc.laurent@lecnam.net

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

function [EI,WEI,GEI,LCB,exploitEI,explorEI]=InfillCrit(respMin,Z,varZ,infillData)

%fprintf('  >>> Compute infill criteria\n');

%depending on the kind of infill criteria to be computed
calcEI=false;
calcWEI=false;
calcGEI=false;
calcLCB=false;
calcExploit=false;
calcExplor=false;

%initialize outuput variables
EI=[];
WEI=[];
GEI=[];
LCB=[];
exploitEI=[];
explorEI=[];

if isfield(infillData,'crit')
    if ~isempty(infillData.crit)
        if ismember('EI',infillData.crit);calcEI=true;calcExploit=true;calcExplor=true;end
        if ismember('WEI',infillData.crit);calcWEI=true;calcExploit=true;calcExplor=true;end
        if ismember('GEI',infillData.crit);calcGEI=true;calcExploit=true;calcExplor=true;end
        if ismember('LCB',infillData.crit);calcLCB=true;end
        if ismember('exploitEI',infillData.crit);calcExploit=true;end
        if ismember('explorEI',infillData.crit);calcExplor=true;end
    end
else
    calcEI=true;
    calcWEI=true;
    calcGEI=true;
    calcLCB=true;
    calcExploit=true;
    calcExplor=true;
end

%dimensions
nbv=size(Z);

%check variance
ixInf=find(varZ<0);
if ~isempty(ixInf)
    fprintf('Issue: variance lower than zero at %i points \n',numel(ixInf))
    disp(varZ(ixInf))
    fprintf('> Correction to zero\n')
    varZ(ixInf)=0;
end
ixInf=find(varZ<eps);
if ~isempty(ixInf)
    fprintf('Issue: variance close to zero at %i points \n',numel(ixInf))
    fprintf('> Correction to zero\n')
    varZ(ixInf)=0;
end


%compute standard deviation
respStd=sqrt(varZ);

%minimal response
diffEI=(respMin-Z);
u=diffEI./respStd;

%for computation of the Expected Improvement (Schonlau 1997/Jones 1999/Bompard
%2011/Sobester 2005...)
%exploration (using probabilty density)
densProb=1/sqrt(2*pi)*exp(-0.5*u.^2); %normpdf
if calcExplor || calcEI || calcWEI
    explorEI=respStd.*densProb;
end

%exploitation (cumulative distribution function)
cumDist=0.5*(1+erf(u/sqrt(2))); %cdf
if calcExploit || calcEI || calcWEI
    exploitEI=diffEI.*cumDist;
end

%deal with specific case: variance lower than 0 or close to 0
if ~isempty(ixInf)
    u(ixInf)=0;
    if calcExplor || calcEI || calcWEI
        explorEI(ixInf)=0;
    end
    if calcExploit || calcEI || calcWEI
        exploitEI(ixInf)=0;
    end
end

%Weigthed Expected Improvement (Sobester 2005)
if calcWEI
    nbParaWEI=numel(infillData.paraWEI);
    if nbParaWEI~=1
        paraWEI=reshape(infillData.para_wei,1,1,nbParaWEI);
        paraWEI=repmat(paraWEI,[nbv(1),nbv(2),1]);
        WEI=paraWEI.*repmat(exploitEI,[1 1 nbParaWEI])...
            +(1-paraWEI).*repmat(explorEI,[1 1 nbParaWEI]);
    else
        WEI=infillData.paraWEI.*exploitEI+(1-infillData.para_wei)*explorEI;
    end
end

%Expected Improvement (Schonlau 1997)
if calcEI
    EI=exploitEI+explorEI;
end

%Lower Confidence Bound (Cox et John 1997)
if calcLCB
    LCB=Z-infillData.para_lcb*respStd;
    %deal with specific case: variance lower than 0 or close to 0
    if ~isempty(ixInf)
        LCB(ixInf)=0;
    end
end

% Generalized Expected Improvement (Schonlau 1997)
% if the parameter is equal to 1 >> Expectied Improvement
if calcGEI
    g=max(infillData.paraGEI);
    t=zeros(nbv(1),nbv(2),g);
    GEI=zeros(nbv(1),nbv(2),g+1);
    if respStd~=0
        if g>=0
            t(:,:,1)=cumDist;
        end
        if g>=1
            t(:,:,2)=-densProb;
        end
        if g>=2
            for kk=3:g+1
                t(:,:,kk)=u.^(kk-1).*t(1)+(kk-1).*t(kk-2);
            end
        end
        
        %compute various terms for calculating GEI
        for cg=0:g
            kIte=reshape(0:cg,[1,1,cg+1]);
            %coefficent
            coefGEI=(-1).^kIte;
            %variance to the power
            varG=respStd.^cg;
            % binomail coefficeent
            binomialC=factorial(cg)./(factorial(kIte).*factorial(cg-kIte)); %faster than nchoosek (10 times faster)
            % u to the power
            pow=cg-kIte;
            uEG=bsxfun(@power,u,pow);
            %compute terms of the sum
            coefF=coefGEI.*binomialC;
            prodA=bsxfun(@times,coefF,uEG.*t(:,:,1:cg+1));
            s=sum(prodA,3);
            %computer GEI criteria
            GEI(:,:,cg+1)=varG.*sum_tmp;
        end
    end
end
