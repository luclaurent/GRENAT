%% function for building gradient and non-gradient based SVR
% SVR: SVR
% SVR: gradient-based SVR
% L. LAURENT -- 24/05/2016 -- luc.laurent@lecnam.net

function [ret]=SVRBuild(samplingIn,respIn,gradIn,metaData,missData)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display Building information
textd='++ Type: ';
textf='';
fprintf('\n%s\n',[textd '(G)SVR ' textf]);
%
fprintf('>>> Building : ');
if ~isempty(gradIn);fprintf('GSVR \n');else fprintf('SVR \n');end
fprintf('>>> Kernel function: %s\n',metaData.kern);
%
fprintf('>>> CV: ');if metaData.cv.on; fprintf('Yes\n');else fprintf('No\n');end
fprintf('>> Computation all CV criteria: ');if metaData.cv.full; fprintf('Yes\n');else fprintf('No\n');end
fprintf('>> Show CV: ');if metaData.cv.disp; fprintf('Yes\n');else fprintf('No\n');end
%
fprintf('>> Correction of matrix condition: ');if metaData.recond; fprintf('Yes\n');else fprintf('No\n');end
%
fprintf('>>> Estimation of the hyperparameters: ');if metaData.para.estim; fprintf('Yes\n');else fprintf('No\n');end
if metaData.para.estim
    fprintf('>> Algorithm for estimation: %s\n',metaData.para.method);
    fprintf('>> Bounds: [%d , %d]\n',metaData.para.l.min,metaData.para.l.max);
    switch metaData.kern
        case {'expg','expgg'}
            fprintf('>> Bounds for exponent: [%d , %d]\n',metaData.para.p.min,metaData.para.p.max);
        case 'matern'
            fprintf('>> Bounds for nu (Matern): [%d , %d]\n',metaData.para.nu.min,metaData.para.nu.max);
    end
    fprintf('>> Anisotropy: ');if metaData.para.aniso; fprintf('Yes\n');else fprintf('No\n');end
    fprintf('>> Show estimation steps in console: ');if metaData.para.dispIterCmd; fprintf('Yes\n');else fprintf('No\n');end
    fprintf('>> Plot estimation steps: ');if metaData.para.dispIterGraph; fprintf('Yes\n');else fprintf('No\n');end
else
    fprintf('>> Value hyperparameter: %d\n',metaData.para.l.val);
    switch metaData.kern
        case {'expg','expgg'}
            fprintf('>> Value of the exponent:')
            fprintf(' %d',metaData.para.p.val);
            fprintf('\n');
        case {'matern'}
            fprintf('>> Value of nu (Matern): %d \n',metaData.para.nu.val);
    end
end
%
fprintf('>>> Infill criteria: ');
if metaData.infill.on;
    fprintf('%s\n','Yes');
    fprintf('>> Balancing WEI: ')
    fprintf('%d ',metaData.infill.paraWEI);
    fprintf('\n')
    fprintf('>> Balancing GEI: ')
    fprintf('%d ',metaData.infill.paraGEI);
    fprintf('\n')
    fprintf('>> Balancing LCB: %d\n',metaData.infill.paraLCB);
else
    fprintf('%s\n','No');
end
fprintf('\n');
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
%

if availGrad
    tmp=gradIn';
    dYY=tmp(:);
    %remove missing gradient(s)
    if missGrad
        dYY=dYY(missData.grad.ixt_dispo_line);
    end
    YY=vertcat(YY,dYY);
end
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
            liste_tmpB=reshape(tmpList',[],1);
            iXdev(iteA)=tmpList(ite,jj);
            iXdevb=liste_tmpB;
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
%calcul distances inter-sites
distC=samplingIn(iXsampling(:,1),:)-samplingIn(iXsampling(:,2),:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Build regression matrix (for the trend model)
%choose polynomial function
funPoly=['mono_' num2str(metaData.polyOrder,'%02i') '_' num2str(np,'%03i')];

%depending on the availability of the gradients
if ~availGrad
    valFunPoly=feval(funPoly,samplingIn);
    if missResp
        %remove missing response(s)
        valFunPoly=valFunPoly(metaData.miss.resp.ixAvail,:);
    end
else
    %GKRG
    [Reg,nbMonomialTerms,DReg,~]=feval(funPoly,samplingIn);
    if missResp||missGrad
        sizeResp=ns-missData.resp.nb;
        sizeGrad=ns*np-missData.grad.nb;
        sizeTotal=sizeResp+sizeGrad;
    else
        sizeResp=ns;
        sizeGrad=ns*np;
        sizeTotal=sizeResp+sizeGrad;
    end
    %initialize regression matrix
    valFunPoly=zeros(sizeTotal,nbMonomialTerms);
    if missResp
        %remove missing response(s)
        Reg=Reg(metaData.miss.resp.ixAvail,:);
    end
    %load monomial terms of the polynomial regression
    valFunPoly(1:sizeResp,:)=Reg;
    %load derivatives of the monomial terms
    if iscell(DReg)
        tmp=horzcat(DReg{:})';
        tmp=reshape(tmp,nbMonomialTerms,[])';
    else
        tmp=DReg';
        tmp=tmp(:);
    end
    
    if missGrad
        %remove missing gradient(s)
        tmp=tmp(missData.grad.ixt_dispo_line,:);
    end
    %add derivatives to the regression matrix
    valFunPoly(sizeResp+1:end,:)=tmp;
end

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
ret.ix.matrix=iXmatrix;
ret.ix.sampling=iXsampling;
if availGrad
    ret.ix.matrixA=iXmatrixA;
    ret.ix.matrixAb=iXmatrixAb;
    ret.ix.matrixI=iXmatrixI;
    ret.ix.dev=iXdev;
    ret.ix.devb=iXdevb;
end
ret.build.fct=valFunPoly;
ret.build.fc=valFunPoly';
ret.build.sizeFc=size(valFunPoly,2);
ret.build.y=YY;
ret.build.funPoly=funPoly;
ret.build.kern=metaData.kern;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compute log-likelihood for estimating parameters
if metaData.para.estim&&metaData.para.dispEstim
    valPara=linspace(metaData.para.l.min,metaData.para.l.max,100);
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
        %initialize matrix for storing log-likelihood
        valLik=zeros(size(valX));
        for itli=1:numel(valX)
            %compute log-likelihood and storage
            valLik(itli)=KRGBloc(ret,metaData,[valX(itli) valY(itli)]);
            %show progress and time
            cpb.setValue(itli/numel(valX)*100);
        end
        fprintf('\n');
        cpb.stop();
        %plot log-vraisemblance
        figure;
        [C,h]=contourf(valX,valY,valLik);
        text_handle = clabel(C,h);
        set(text_handle,'BackgroundColor',[1 1 .6],...
            'Edgecolor',[.7 .7 .7])
        set(h,'LineWidth',2)
        %store figure in TeX/Tikz file
        if metaData.para.save
            matlab2tikz([aff.doss '/KRGlogli.tex'])
        end
        
    elseif ~metaData.para.aniso||np==1
        %initialize matrix for storing log-likelihood
        valLik=zeros(1,length(valPara));
        for itli=1:length(valPara)
            %compute log-likelihood and storage
            valLik(itli)=KRGBloc(ret,metaData,valPara(itli));
            cpb.setValue(itli/numel(valPara)*100);
        end
        fprintf('\n');
        cpb.stop();
        
        %store in .dat file
        if metaData.para.save
            ss=[valPara' valLik'];
            save([aff.directory '/KRGlogli.dat'],'ss','-ascii');
        end
        
        %plot log-vraisemblance
        figure;
        plot(valPara,valLik);
        title('Evolution of the log-likelihood');
    end
    
    %store graphs (if active)
    if dispData.save&&(ns<=2)
        fileStore=saveDisp('fig_likelihood',dispData.directory);
        if dispData.tex
            fid=fopen([dispData.directory '/fig.tex'],'a+');
            fprintf(fid,'\\figcen{%2.1f}{../%s}{%s}{%s}\n',0.7,fileStore,'Log-Likelihood',fileStore);
            %fprintf(fid,'\\verb{%s}\n',fich);
            fclose(fid);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Building of the various elements with and without estimation of the
% hyperparameters
if metaData.para.estim
    paraEstim=EstimPara(ret,metaData,'KRGBloc');
    ret.build.paraEstim=paraEstim;
    metaData.para.l.val=paraEstim.l.val;
    metaData.para.val=paraEstim.val;
    if isfield(paraEstim,'p')
        metaData.para.p.val=paraEstim.p.val;
    end
    if isfield(paraEstim,'nu')
        metaData.para.nu.val=paraEstim.nu.val;
    end
else
    %w/o estimation, the initial values of hyperparameters are chosen
    switch metaData.kern
        case {'expg','expgg'}
            metaData.para.val=[metaData.para.l.val metaData.para.p.val];
        case {'matern'}
            metaData.para.val=[metaData.para.l.val metaData.para.nu.val];
        otherwise
            metaData.para.val=metaData.para.l.val;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Building final elements of the RBF surrogate model (matrices, coefficients & log-likelihood)
% by taking into account the values of hyperparameters obtained previously
[lilog,blocKRG]=KRGBloc(ret,metaData);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%store informations
tmp=mergestruct(ret.build,blocKRG.build);
ret.build=tmp;
ret.build.lilog=lilog;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Cross-validation (compute various errors)
if metaData.cv.on
    [tMesu,tInit]=mesuTime;
    [ret.build.cv]=KRGCV(ret,metaData);
    fprintf(' > Computation CV\n');
    mesuTime(tMesu,tInit);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if availGrad;txt='GKRG';else txt='KRG';end
fprintf('\n >> END Building %s\n',txt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

