%% Building of the RBF/GRBF matrix and computation of the CV criteria
% L. LAURENT -- 24/01/2012 -- luc.laurent@lecnam.net

function [crit_min,ret]=RBFBloc(dataIn,metaData,paraVal,type)

% display warning(s) or not
dispWarning=false;
statusWarning=modWarning([],[]);
% function to be minimised for finding hyperparameters
fctMin='eloot'; %eloot/eloor/eloog
%coefficient of reconditionning
coef=eps;
% chosen factorization for RBF matrix
fact_KK='LU' ; %LU %QR %LL %None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load useful variables
ns=dataIn.in.ns;
np=dataIn.in.np;
samplingIn=dataIn.in.sampling;
fctKern=metaData.kern;
ret=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if the hyperparameter is defined 
if nargin>=3
    valPara=paraVal;
    %in this case, the single required criterion is computed (estimation)
    typeCV='estim';
else
    valPara=metaData.para.val;
    typeCV='final';
end
metaData.para.l.val=valPara;

if nargin==4
    if strcmp(type,'etud');typeCV=type;end
    if strcmp(type,'estim');typeCV=type;end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Build of the RBF/GRBF matrix
if dataIn.in.pres_grad
    [KK,KKa,KKi]=KernMatrix(fctKern,dataIn,valPara);
    KK=[KK KKa;-KKa' KKi];
else
    [KK]=KernMatrix(fctKern,dataIn.in.dist,valPara);
end
%in the case of missing data
%responses
if dataIn.miss.resp.on
    KK(dataIn.miss.eval.ix_miss,:)=[];
    KK(:,dataIn.miss.eval.ix_miss)=[];
end
%gradients
if dataIn.in.pres_grad
    if dataIn.miss.grad.on
        rep_ev=ns-dataIn.miss.eval.nb;
        KK(rep_ev+dataIn.miss.grad.ixt_miss_line,:)=[];
        KK(:,rep_ev+dataIn.miss.grad.ixt_miss_line)=[];
    end
end


else
    if metaData.worker_parallel>=2
        %%%%%% PARALLEL %%%%%%
        %matrice de RBF classique par bloc
        KK=zeros(ns,ns);
        parfor ii=1:ns
            %distance 1 tirages aux autres (construction par colonne)
            one_tir=samplingIn(ii,:);
            dist=samplingIn-one_tir(ones(1,ns),:);
            % evaluation de la fonction de correlation
            [ev]=feval(fctKern,dist,valPara);
            %morceau de la matrice issue du modele RBF classique
            KK(:,ii)=ev;
        end
    else        
        %matrice de RBF classique par matrice triangulaire inferieure
        %sans diagonale
        KK=zeros(ns,ns);
        % evaluation de la fonction de correlation
        [ev]=feval(metaData.rbf,dataIn.in.dist,valPara);
        KK(dataIn.ind.matrix)=ev;
        %Construction matrice complete
        KK=KK+KK'+eye(ns);        
    end
    %si donnees manquantes
    if dataIn.manq.eval.on
        KK(dataIn.manq.eval.ix_manq,:)=[];
        KK(:,dataIn.manq.eval.ix_manq)=[];
    end
end


%passage en sparse
%KK=sparse(KK);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%amelioration du conditionnement de la matrice de correlation
if metaData.recond
    %cond_orig=condest(KK);
    KK=KK+coef*speye(size(KK));
    %cond_new=condest(KK);
%          fprintf('>>> Amelioration conditionnement: \n%g >> %g  <<<\n',...
%              cond_orig,cond_new);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%conditionnement de la matrice de correlation
if nargin==2&&~exist('cond_new','var')   %en phase de construction
    cond_new=condest(KK);
elseif nargin==2&&exist('cond_new','var')
    fprintf('Conditionnement R: %4.2e\n',cond_new)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%approche factorisee
%attention cette factorisation n'est possible que sous condition
%QR
switch fact_KK
    case 'QR'
        [QKK,RKK,PKK]=qr(KK);
        iKK=PKK*(RKK\QKK');
        yQ=QKK'*dataIn.build.y;
        w=PKK*(RKK\yQ);
    case 'LU'
        [LKK,UKK,PKK]=lu(KK);
        iKK=UKK\(LKK\PKK);
        yL=LKK\PKK*dataIn.build.y;
        w=UKK\yL;
    case 'LL'
        %%% A coder
        LKK=chol(KK,'lower');
        iKK=LKK'\inv(LKK);
        yL=LKK\dataIn.build.y;
        w=LKK'\yL;
    otherwise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul du coefficient beta
        %%approche classique
        if ~dispWarning; warning off all;end
        iKK=inv(KK);
        if ~dispWarning; warning on all;end
        w=iKK*dataIn.build.y;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%stockage des grandeurs
if exist('cond_orig','var');build_data.cond_orig=cond_orig;end
if exist('cond_new','var');build_data.cond_new=cond_new;end
if exist('QKK','var');build_data.QKK=QKK;end
if exist('RKK','var');build_data.RKK=RKK;end
if exist('LKK','var');build_data.LKK=LKK;end
if exist('UKK','var');build_data.UKK=UKK;end
if exist('iKK','var');build_data.iKK=iKK;end
if exist('yQ','var');build_data.yQ=yQ;end
build_data.w=w;
build_data.KK=KK;
build_data.fct=metaData.rbf;
build_data.para=metaData.para;
ret.build=build_data;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Validation croisee (obligatoire pour affinage parametre)
%%%%%Calcul des differentes erreurs
if metaData.cv||metaData.para.estim
    %tps_stop=toc;
    [cv]=cross_validate_rbf(ret,dataIn,metaData,typeCV);
    %tps_cv=toc;
    %fprintf('Execution validation croisee RBF/HBRBF: %6.4d s\n\n',tps_cv-tps_stop);
    if isfield(cv,fctMin)
        crit_min=cv.(fctMin);
    else
        crit_min=cv.eloot;
    end
else
    cv=[];
    crit_min=[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ret.cv=cv;
modWarning([],statusWarning)
end
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function for stopping the display of the warning and restoring initial
% state
function retStatus=modWarning(requireStatus,oldStatus)
if nargin==1
if ~requireStatus
    warning off all
end    
else
    if isempty(oldStatus)
        retStatus=warning;
    else
        warning(oldStatus)
    end
end
end

