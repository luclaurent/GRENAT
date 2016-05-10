%% Function for building Radial Basis Function surrogate model
% RBF: w/o gradient
% GRBF: avec gradients
% L. LAURENT -- 15/03/2010 -- luc.laurent@lecnam.net
% change on 12/04/2010 and on 15/01/2012

function ret=RBFBuild(samplingIn,respIn,gradIn,metaData)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display Building information
textd='++ Type: ';
textf='';
fprintf('\n%s\n',[textd 'Radial Basis Function ((G)RBF)' textf]);
%
fprintf('>>> Building : ');
if ~isempty(gradIn);fprintf('GRBF \n');else fprintf('RBF \n');end
fprintf('>>> Kernel function: %s\n',metaData.kern);
%
fprintf('>>> CV: ');if metaData.cv.on; fprintf('Yes\n');else fprintf('No\n');end
fprintf('>> Computation all CV criteria: ');if metaData.cv.full; fprintf('Yes\n');else fprintf('No\n');end
fprintf('>> Show CV: ');if metaData.cv.disp; fprintf('Yes\n');else fprintf('No\n');end
%
fprintf('>> Correction of matrix condition:');if metaData.recond; fprintf('Yes\n');else fprintf('No\n');end
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

if metaData.para.estim&&metaData.para.dispEstim
    valPara=linspace(metaData.para.l.min,metaData.para.l.max,gene_nbele(np));
    % load progress bar
    cpb = ConsoleProgressBar();
    minVal = 0;
    maxVal = 100;
    cpb.setMinimum(minVal);
    cpb.setMaximum(maxVal);
    cpb.setLength(20);
    cpb.setRemainedTimeVisible(1);
    cpb.setRemainedTimePosition('left');
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
            cpb.setValue(itli/numel(valX));
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
        if metaData.save
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
if metaData.para.estim
    paraEstim=EstimPara(ret,metaData,'RBFBloc');
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
    valL=RBFComputePara(samplingIn,metaData);
    if numel(valL)==1;
        metaData.para.l.val=valL*ones(1,np);
    else
        metaData.para.l.val=valL;
    end
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
% Building final elements of the RBF surrogate model (matrices, coefficients & CV)
% by taking into account the values of hyperparameters obtained previously
[~,blocRBF]=RBFBloc(ret,metaData);
%save information
tmp=mergestruct(ret.build,blocRBF.build);
ret.build=tmp;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if availGrad;txt='GRBF';else txt='RBF';end
fprintf('\n >> END Building %s\n',txt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


