%% Function for building Radial Basis Function surrogate model
% RBF: w/o gradient
% GRBF: avec gradients
% L. LAURENT -- 15/03/2010 -- luc.laurent@lecnam.net
% change on 12/04/2010 and on 15/01/2012

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

function ret=RBFBuild(samplingIn,respIn,gradIn,metaData)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display Building information
textd='++ Type: ';
textf='';
Gfprintf('\n%s\n',[textd 'Radial Basis Function ((G)RBF)' textf]);
%
Gfprintf('>>> Building : ');
dispTxtOnOff(~isempty(gradIn),'GRBF','RBF',true);
Gfprintf('>> Kernel function: %s\n',metaData.kern);
%
if dispTxtOnOff(metaData.cv.on,'>> CV: ',[],true)
    dispTxtOnOff(metaData.cv.full,'>> Computation all CV criteria: ',[],true);
    dispTxtOnOff(metaData.cv.disp,'>> Show CV: ',[],true);
end
%
dispTxtOnOff(metaData.recond,'>> Correction of matrix condition:',[],true);
%
if dispTxtOnOff(metaData.estim.on,'>> Estimation of the hyperparameters: ',[],true)
    Gfprintf('>> Algorithm for estimation: %s\n',metaData.estim.method);
    Gfprintf('>> Bounds: [%d , %d]\n',metaData.para.l.Min,metaData.para.l.Max);
    switch metaData.kern
        case {'expg','expgg'}
            Gfprintf('>> Bounds for exponent: [%d , %d]\n',metaData.para.p.Min,metaData.para.p.Max);
        case 'matern'
            Gfprintf('>> Bounds for nu (Matern): [%d , %d]\n',metaData.para.nu.Min,metaData.para.nu.Max);
    end
    dispTxtOnOff(metaData.estim.aniso,'>> Anisotropy: ',[],true);
    dispTxtOnOff(metaData.estim.dispIterCmd,'>> Show estimation steps in console: ',[],true);
    dispTxtOnOff(metaData.estim.dispIterGraph,'>> Plot estimation steps: ',[],true);
else
    Gfprintf('>> Value hyperparameter: %d\n',metaData.para.l.Val);
    switch metaData.kern
        case {'expg','expgg'}
            Gfprintf('>> Value of the exponent:');
            fprintf(' %d',metaData.para.p.Val);
            fprintf('\n');
        case {'matern'}
            Gfprintf('>> Value of nu (Matern): %d \n',metaData.para.nu.Val);
    end
end
%
Gfprintf('\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load global variables
global dispData
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialisation of the variables
%number of sample points
ns=size(respIn,1);
%number of design variables
np=size(samplingIn,2);

%check availability of the gradients
availGrad=~isempty(gradIn);
%check missing data
if isfield(metaData,'miss')
    missResp=metaData.miss.resp.on;
    missGrad=metaData.miss.grad.on;
    availGrad=(~metaData.miss.grad.all&&metaData.miss.grad.on)||(availGrad&&~metaData.miss.grad.on);
else
    metaData.miss.resp.on=false;
    metaData.miss.grad.on=false;
    missResp=missData.resp.on;
    missGrad=metaData.miss.grad.on;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Responses and gradients at sample points
YY=respIn;
%remove missing response(s)
if missResp
    YY=YY(metaData.miss.resp.ixAvail);
end
if availGrad
    tmp=gradIn';
    der=tmp(:);
    %remove missing gradient(s)
    if missGrad
        der=der(metaData.miss.grad.ixtAvailLine);
    end
    YY=vertcat(YY,der);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Building indexes system for building RBF/GRBF matrices
if availGrad
    sizeMatRc=(ns^2+ns)/2;
    sizeMatRa=np*(ns^2+ns)/2;
    sizeMatRi=np^2*(ns^2+ns)/2;
    iXmat=zeros(sizeMatRc,1);
    iXmatA=zeros(sizeMatRa,1);
    iXmatAb=zeros(sizeMatRa,1);
    iXmatI=zeros(sizeMatRi,1);
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
        iXmat(ite)=(ns+1)*ii-ns:ii*ns;
        iXsampling(ite,:)=[ii(ones(ns-ii+1,1)) (ii:ns)'];
        iteAb=iteAb(end)+(1:((ns-ii+1)*np));
        
        debb=(ii-1)*np*ns+ii;
        finb=ns^2*np-(ns-ii);
        lib=debb:ns:finb;
        
        iXmatAb(iteAb)=lib;
        
        for jj=1:np
            iteA=iteA(end)+(1:(ns-ii+1));
            shiftA=(ii-1);
            deb=pres+shiftA;
            li=deb + (1:(ns-ii+1));
            iXmatA(iteA)=li;
            pres=li(end);
            liste_tmpB=reshape(tmpList',[],1);
            iXdev(iteA)=tmpList(ite,jj);
            iXdevb=liste_tmpB;
        end
    end
    %table of indexes for second derivatives
    a=zeros(ns*np,np);
    shiftA=0;
    precI=0;
    iteI=0;
    for ii=1:ns
        li=1:ns*np^2;
        a(:)=shiftA+li;
        shiftA=a(end);
        b=a';
        
        iteI=precI+(1:(np^2*(ns-(ii-1))));
        
        debb=(ii-1)*np^2+1;
        finb=np^2*ns;
        iteb=debb:finb;
        iXmatI(iteI)=b(iteb);
        precI=iteI(end);
    end
else
    %table of indexes for inter-lenghts  (1), responses (1)
    bmax=ns-1;
    iXmat=zeros(ns*(ns-1)/2,1);
    iXsampling=zeros(ns*(ns-1)/2,2);
    ite=0;
    for ii=1:bmax
        ite=ite(end)+(1:(ns-ii));
        iXmat(ite)=(ns+1)*ii-ns+1:ii*ns;
        iXsampling(ite,:)=[ii(ones(ns-ii,1)) (ii+1:ns)'];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%computation of the inter-distances
distC=samplingIn(iXsampling(:,1),:)-samplingIn(iXsampling(:,2),:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%store variables
ret.used.sampling=samplingIn;
ret.used.dist=distC;
ret.used.resp=respIn;
ret.used.availGrad=availGrad;
ret.used.grad=gradIn;
ret.used.np=np;
ret.used.ns=ns;
ret.ix.matrix=iXmat;
ret.ix.sampling=iXsampling;
if availGrad
    ret.ix.matrixA=iXmatA;
    ret.ix.matrixAb=iXmatAb;
    ret.ix.matrixI=iXmatI;
    ret.ix.dev=iXdev;
    ret.ix.devb=iXdevb;
end
ret.build.y=YY;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Computation of the MSE of the  Cross-Validation
%display CV is required
CvOld=metaData.cv;
dispCvOld=metaData.cv.disp;
metaData.cv.disp=false;

if metaData.estim.on&&metaData.estim.disp
    valPara=linspace(metaData.para.l.min,metaData.para.l.max,50);
    % load progress bar
    cpb = ConsoleProgressBar();
    minVal = 0;
    maxVal = 100;
    cpb.setMinimum(minVal);
    cpb.setMaximum(maxVal);
    cpb.setLength(20);
    cpb.setRemainedTimeVisible(1);
    cpb.setRemainedTimePosition('left');
    cpb.start();
    %for anisotropy (with 2 design variables)
    if metaData.para.aniso&&np==2
        %building of the studied grid
        [valX,valY]=meshgrid(valPara,valPara);
        %initialize matrix for storing MSE
        valMSEp=zeros(size(valX));
        for itli=1:numel(valX)
            %computation of the MSE and storage
            valMSEp(itli)=RBFBloc(ret,metaData,[valX(itli) valY(itli)]);
            %show progress and time
            cpb.setValue(itli/numel(valX)*100);
        end
        cpb.stop();
        %plot MSE
        figure;
        [C,h]=contourf(valX,valY,valMSEp);
        text_handle = clabel(C,h);
        set(text_handle,'BackgroundColor',[1 1 .6],...
            'Edgecolor',[.7 .7 .7])
        set(h,'LineWidth',2)
        %store figure in TeX/Tikz file
        if dispData.save
            matlab2tikz([dispData.doss '/RBFmse.tex'])
        end
        
    elseif ~metaData.para.aniso||np==1
        %initialize matrix for storing MSE
        valMSEp=zeros(1,length(valPara));
        cvRippa=valMSEp;
        cvCustom=valMSEp;
        for itli=1:length(valPara)
            %computation of the MSE and storage
            [~,buildRBF]=RBFbloc(ret,metaData,valPara(itli),'etud');
            cvRippa(itli)=buildRBF.cv.and.eloot;
            cvCustom(itli)=buildRBF.cv.then.eloot;
            %show progress and time
            cpb.setValue(itli/numel(valPara));
        end
        cpb.stop();
        
        %store in .dat file
        if metaData.save
            ss=[valPara' valMSEp'];
            save([dispData.directory '/RBFmse.dat'],'ss','-ascii');
        end
        
        %plot MSE
        figure;
        semilogy(valPara,cvRippa,'r');
        hold on
        semilogy(valPara,cvCustom,'k');
        legend('Rippa (Bompard)','Custom');
        title('CV');
    end
    
    %store graphs (if active)
    if dispData.save&&(ns<=2)
        fileStore=saveDisp('fig_mse_cv',dispData.directory);
        if dispData.tex
            fid=fopen([dispData.directory '/fig.tex'],'a+');
            fprintf(fid,'\\figcen{%2.1f}{../%s}{%s}{%s}\n',0.7,fileStore,'MSE',fileStore);
            %fprintf(fid,'\\verb{%s}\n',fich);
            fclose(fid);
        end
    end
end
%reload initial configurations
metaData.cv.disp=dispCvOld;
metaData.cv=CvOld;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Building of the various elements with and without estimation of the
%%hyperparameters if no estimation the values of the hyperparameters are
%%chosen using empirical choice of  Hardy/Franke
if metaData.estim.on
    paraEstim=EstimPara(ret,metaData,'RBFBloc');
    ret.build.paraEstim=paraEstim;
    metaData.para.l.Val=paraEstim.l.Val;
    metaData.para.Val=paraEstim.Val;
    if isfield(paraEstim,'p')
        metaData.para.p.Val=paraEstim.p.Val;
    end
    if isfield(paraEstim,'nu')
        metaData.para.nu.Val=paraEstim.nu.Val;
    end
else
    valL=RBFComputePara(samplingIn,metaData);
    if numel(valL)==1
        metaData.para.l.Val=valL*ones(1,np);
    else
        metaData.para.l.Val=valL;
    end
    switch metaData.kern
        case {'expg','expgg'}
            metaData.para.Val=[metaData.para.l.Val metaData.para.p.Val];
        case {'matern'}
            metaData.para.Val=[metaData.para.l.Val metaData.para.nu.Val];
        otherwise
            metaData.para.Val=metaData.para.l.Val;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Building final elements of the RBF surrogate model (matrices, coefficients & CV)
% by taking into account the values of hyperparameters obtained previously
[~,blocRBF]=RBFBloc(ret,metaData);
%save information
tmp=mergestruct(ret.build,blocRBF.build);
ret.build=tmp;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if availGrad;txt='GRBF';else txt='RBF';end
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
    Gfprintf('%s',txtInTrue);if boolIn; fprintf('Yes');else fprintf('No');end
else
    if boolIn;fprintf('%s',txtInTrue);else fprintf('%s',txtInFalse);end
end
if returnLine
    fprintf('\n');
end
end


