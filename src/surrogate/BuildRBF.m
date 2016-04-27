%% Function for build Radial Basis Function surrogate medel
%% RBF: w/o gradient
%% GRBF: avec gradients
%% L. LAURENT -- 15/03/2010 -- luc.laurent@lecnam.net
%% change on 12/04/2010 and on 15/01/2012

function ret=BuildRBF(samplingIn,respIn,gradIn,metaData,missData)

[tMesu,tInit]=mesuTime;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display Building information
textd='++ Type: ';
textf='';
fprintf('\n%s\n',[textd 'Radial Basis Function (RBF)' textf]);
%
fprintf('>>> Building : ');
if ~isempty(gradIn);fprintf('GRBF \n');else fprintf('RBF \n');end
fprintf('>>> Kernel function: %s\n',metaData.kern);
%
fprintf('>>> CV: ');if metaData.cv.on; fprintf('Yes\n');else fprintf('No\n');end
fprintf('>> Computation all CV criteria: ');if metaData.cv.full; fprintf('Yes\n');else fprintf('No\n');end
fprintf('>> Show CV: ');if metaData.cv.aff; fprintf('Yes\n');else fprintf('No\n');end
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
    fprintf('>> Show estimation steps in console: ');if metaData.para.aff_iter_cmd; fprintf('Yes\n');else fprintf('No\n');end
    fprintf('>> Plot estimation steps: ');if metaData.para.aff_iter_graph; fprintf('Yes\n');else fprintf('No\n');end
else
    fprintf('>> Value hyperparameter: %d\n',metaData.para.l.val);
    switch metaData.rbf
        case {'rf_expg','rf_expgg'}
            fprintf('>> Value of the exponent: [%d , %d]\n',metaData.para.p.val);
        case {'matern'}
            fprintf('>> Value of nu (Matern): [%d , %d]\n',metaData.para.nu.val);
    end
end
fprintf('>>> Infill criteria:');
if metaData.enrich.on;
    fprintf('%s\n','Yes');
    fprintf('>> Balancing WEI: ')
    fprintf('%d ',metaData.enrich.para_wei);
    fprintf('\n')
    fprintf('>> Balancing GEI: ')
    fprintf('%d ',metaData.enrich.para_gei);
    fprintf('\n')
    fprintf('>> Balancing LCB: %d\n',metaData.enrich.para_lcb);
else
    fprintf('%s\n','No');
end
fprintf('\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load global variables
global aff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialisation of the variables
%number of sample points
ns=size(respIn,1);
%number of design variables
np=size(samplingIn,2);

%check availability of the gradients
gradAvail=~isempty(gradIn);
%check missing data
if nargin==5
    missResp=missData.eval.on;
    missGrad=missData.grad.on;
    gradAvail=(~missData.grad.all&&missData.grad.on)||(gradAvail&&~missData.grad.on);
else
    missData.eval.on=false;
    missData.grad.on=false;
    missResp=missData.eval.on;
    missGrad=missData.grad.on;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Responses and gradients at sample points
y=evaln;
%remove missing response(s)
if missResp
    y=y(missData.eval.ix_dispo);
end
if gradAvail
    tmp=gradn';
    der=tmp(:);
    %remove missing gradient(s)
    if missGrad
        der=der(missData.grad.ixt_dispo_line);
    end
    y=vertcat(y,der);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Building indexes system for building RBF/GRBF matrices
if gradAvail    
    size_matRc=(ns^2+ns)/2;
    size_matRa=np*(ns^2+ns)/2;
    size_matRi=np^2*(ns^2+ns)/2;
    iXmat=zeros(size_matRc,1);
    iXmatA=zeros(size_matRa,1);
    iXmatAb=zeros(size_matRa,1);
    iXmatI=zeros(size_matRi,1);
    iXdev=zeros(size_matRa,1);
    iXsampling=zeros(size_matRc,2);
    
    tmpList=zeros(size_matRc,np);
    tmpList(:)=1:size_matRc*np;
    
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
dist=samplingIn(iXsampling(:,1),:)-samplingIn(iXsampling(:,2),:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%store varibales des grandeurs
ret.in.sampling=samplingIn;
ret.in.dist=dist;
ret.in.eval=respIn;
ret.in.pres_grad=gradAvail;
ret.in.grad=gradIn;
ret.in.np=np;
ret.in.ns=ns;
ret.ix.matrix=iXmat;
ret.ix.sampling=iXsampling;
if gradAvail
    ret.ix.matrixA=iXmatA;
    ret.ix.matrixAb=iXmatAb;
    ret.ix.matrixI=iXmatI;
    ret.ix.dev=iXdev;
    ret.ix.devb=iXdevb;
end
ret.build.y=y;
ret.norm=rbf.norm;
ret.manq=missData;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calcul de MSE par Cross-Validation
%arret affichage CV si c'est le cas et activation CV si ca n'est pas le cas
cv_old=metaData.cv;
aff_cv_old=metaData.cv_aff;
metaData.cv_aff=false;

if metaData.para.estim&&metaData.para.aff_estim
    val_para=linspace(metaData.para.l_min,metaData.para.l_max,gene_nbele(np));
    %dans le cas ou on considere de l'anisotropie (et si on a 2
    %variable de conception)
    if metaData.para.aniso&&np==2
        %on genere la grille d'etude
        [val_X,val_Y]=meshgrid(val_para,val_para);
        %initialisation matrice de stockage des valeurs de la
        %log-vraisemblance
        val_msep=zeros(size(val_X));
        %si affichage dispo
        if usejava('desktop');h = waitbar(0,'Evaluation critere .... ');end
        for itli=1:numel(val_X)
            
            %calcul de la log-vraisemblance et stockage
            val_msep(itli)=bloc_rbf(ret,metaData,[val_X(itli) val_Y(itli)]);
            %affichage barre attente
            if usejava('desktop')&&exist('h','var')
                avance=(itli-1)/numel(val_X);
                aff_av=avance*100;
                mess=['Eval. en cours ' num2str(aff_av,3) '% ' num2str(itli) '/' num2str(numel(val_X)) ];
                waitbar(avance,h,mess);
            end
        end
        close(h)
        %trace log-vraisemblance
        figure;
        [C,h]=contourf(val_X,val_Y,val_msep);
        text_handle = clabel(C,h);
        set(text_handle,'BackgroundColor',[1 1 .6],...
            'Edgecolor',[.7 .7 .7])
        set(h,'LineWidth',2)
        %stockage de la figure au format LaTeX/TikZ
        if metaData.save
            matlab2tikz([aff.doss '/logli.tex'])
        end
        
    elseif ~metaData.para.aniso||np==1
        %initialisation matrice de stockage des valeurs de la
        %log-vraisemblance
        val_msep=zeros(1,length(val_para));
        rippa_bomp=val_msep;
        cv_moi=val_msep;
        %si affichage dispo
        if usejava('desktop');h = waitbar(0,'Evaluation critere .... ');end
        for itli=1:length(val_para)
            val_para(itli)
            %calcul de la log-vraisemblance et stockage
            [~,build_rbf]=bloc_rbf(ret,metaData,val_para(itli),'etud');
            rippa_bomp(itli)=build_rbf.cv.and.eloot;
            cv_moi(itli)=build_rbf.cv.then.eloot;
            %affichage barre attente
            if usejava('desktop')&&exist('h','var')
                avance=(itli-1)/length(val_para);
                aff_av=avance*100;
                mess=['Eval. en cours ' num2str(aff_av,3) '% ' num2str(itli) '/' num2str(numel(val_para)) ];
                waitbar(avance,h,mess);
            end
        end
        close(h)
        
        %stockage mse dans un fichier .dat
        if metaData.save
            ss=[val_para' val_msep'];
            save([aff.doss '/logli.dat'],'ss','-ascii');
        end
        
        %trace log-vraisemblance
        figure;
        semilogy(val_para,rippa_bomp,'r');
        hold on
        semilogy(val_para,cv_moi,'k');
        legend('Rippa (Bompard)','Moi');
        title('CV');
        
        %         semilogy(val_para,val_msep);
        %         title('Evolution de MSE (CV)');
        
    end
    
    %stocke les courbes (si actif)
    if aff.save&&(ns<=2)
        fich=save_aff('fig_mse_cv',aff.doss);
        if aff.tex
            fid=fopen([aff.doss '/fig.tex'],'a+');
            fprintf(fid,'\\figcen{%2.1f}{../%s}{%s}{%s}\n',0.7,fich,'Vraisemblance',fich);
            %fprintf(fid,'\\verb{%s}\n',fich);
            fclose(fid);
        end
    end
end
%rechargement config initiale si c'etait le cas avant la phase d'estimation
metaData.cv_aff=aff_cv_old;
metaData.cv=cv_old;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Construction des differents elements avec ou sans estimation des
%%parametres siNo on propose une/des valeur(s) des parametres a partir des
%%proposition de Hardy/Franke
if metaData.para.estim
    para_estim=estim_para_rbf(ret,metaData);
    ret.build.para_estim=para_estim;
    metaData.para.l_val=para_estim.l_val;
    metaData.para.val=para_estim.l_val;
    if isfield(para_estim,'p_val')
        metaData.para.p_val=para_estim.p_val;
        metaData.para.val=[metaData.para.val metaData.para.p_val];
    end
else
    metaData.para.l_val=calc_para_rbf(tiragesn,metaData);
    switch metaData.rbf
        case {'rf_expg','rf_expgg'}
            metaData.para.val=[metaData.para.l_val metaData.para.p_val];
        otherwise
            metaData.para.val=metaData.para.l_val;
    end
    fprintf('Definition parametre (%s), val=',metaData.para.type);
    fprintf(' %d',metaData.para.val);
    fprintf('\n');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% construction elements finaux RBF (matrice, coefficients et CV) en tenant
% compte des parametres obtenus par minimisation
[~,block]=bloc_rbf(ret,metaData);
%sauvegarde informations
tmp=mergestruct(ret.build,block.build);
ret.build=tmp;
ret.cv=block.cv;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if gradAvail;txt='GRBF';else txt='RBF';end
fprintf('\nExecution construction %s\n',txt);
mesuTime(tMesu,tInit);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


