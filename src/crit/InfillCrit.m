%% Calcul critere EI/WEI/LCB
%% L. LAURENt -- 04/05/2012 -- luc.laurent@cnam.fr

function [EI,WEI,GEI,LCB,exploit_EI,explor_EI]=crit_enrich(eval_min,Z,variance,enrich)

%fprintf('  >>> Calculs criteres enrichissement\n');

%en fonction du type de critere a calculer
calc_EI=false;
calc_WEI=false;
calc_GEI=false;
calc_LCB=false;
calc_exploit=false;
calc_explor=false;
%initialisation sortie
EI=[];
WEI=[];
GEI=[];
LCB=[];
exploit_EI=[];
explor_EI=[];

if isfield(enrich,'crit')
    if ~isempty(enrich.crit)
    if ismember('EI',enrich.crit);calc_EI=true;calc_exploit=true;calc_explor=true;end
    if ismember('WEI',enrich.crit);calc_WEI=true;calc_exploit=true;calc_explor=true;end
    if ismember('GEI',enrich.crit);calc_GEI=true;calc_exploit=true;calc_explor=true;end
    if ismember('LCB',enrich.crit);calc_LCB=true;end
    if ismember('exploit_EI',enrich.crit);calc_exploit=true;end
    if ismember('explor_EI',enrich.crit);calc_explor=true;end
    end
else
    calc_EI=true;
    calc_WEI=true;
    calc_GEI=true;
    calc_LCB=true;
    calc_exploit=true;
    calc_explor=true;
end

%dimensions
dim_Z=size(Z);

%tests variance
IX_inf=find(variance<0);
if ~isempty(IX_inf)
    fprintf('Probleme variance inferieure à zero en %i points \n',numel(IX_inf))
    disp(variance(IX_inf))
    fprintf('correction a zero\n')
    variance(IX_inf)=0;
end
IX_inf=find(variance<eps);
if ~isempty(IX_inf)
    fprintf('Probleme variance proche de zero en %i points \n',numel(IX_inf))
    fprintf('correction a zero\n')
    variance(IX_inf)=0;
end


%calcul  ecarte type
ecart_type=sqrt(variance);

%reponse mini
diff_ei=(eval_min-Z);
u=diff_ei./ecart_type;
%pour calcul Expected Improvement (Schonlau 1997/Jones 1999/Bompard
%2011/Sobester 2005...)
%exploration (densite probabilite)
densprob=1/sqrt(2*pi)*exp(-0.5*u.^2); %normpdf
if calc_explor || calc_EI || calc_WEI
    explor_EI=ecart_type.*densprob;
end


%exploitation (fonction repartition loi normale centree reduite)
fctrep=0.5*(1+erf(u/sqrt(2))); %cdf
if calc_exploit || calc_EI || calc_WEI
    exploit_EI=diff_ei.*fctrep;
end

%traitement cas particulier: variance nulle ou inferieure a zero (anormale)
if ~isempty(IX_inf)
    u(IX_inf)=0;
    if calc_explor || calc_EI || calc_WEI
        explor_EI(IX_inf)=0;
    end
    if calc_exploit || calc_EI || calc_WEI
        exploit_EI(IX_inf)=0;
    end
end

%critere Weigthed Expected Improvement (Sobester 2005)
if calc_WEI
    nb_para_wei=numel(enrich.para_wei);
    if nb_para_wei~=1
        para_wei=reshape(enrich.para_wei,1,1,nb_para_wei);
        para_wei=repmat(para_wei,[dim_Z(1),dim_Z(2),1]);
        WEI=para_wei.*repmat(exploit_EI,[1 1 nb_para_wei])...
            +(1-para_wei).*repmat(explor_EI,[1 1 nb_para_wei]);
    else
        WEI=enrich.para_wei.*exploit_EI+(1-enrich.para_wei)*explor_EI;
    end
end
%critere Expected Improvement (Schonlau 1997)
if calc_EI
    EI=exploit_EI+explor_EI;
end
%critere Lower Confidence Bound (Cox et John 1997)
if calc_LCB
    LCB=Z-enrich.para_lcb*ecart_type;
    %traitement cas particulier: variance nulle ou inferieure a zero (anormale)
    if ~isempty(IX_inf)
        LCB(IX_inf)=0;
    end
end
%critere Generalized Expected Improvement (Schonlau 1997)
% si le parametre vaut 1 on retrouve l'Expected Improvement
if calc_GEI
    g=max(enrich.para_gei);
    t=zeros(dim_Z(1),dim_Z(2),g);
    GEI=zeros(dim_Z(1),dim_Z(2),g+1);
    if ecart_type~=0
        if g>=0
            t(:,:,1)=fctrep;
        end
        if g>=1
            t(:,:,2)=-densprob;
        end
        if g>=2
            for kk=3:g+1
                t(:,:,kk)=u.^(kk-1).*t(1)+(kk-1).*t(kk-2);
            end
        end
        
        %calcul des differents termes du calcul de GEI
        for cg=0:g
            k_ite=reshape(0:cg,[1,1,cg+1]);
            %coefficent
            coef=(-1).^k_ite;
            %variance a la puissance
            varg=ecart_type.^cg;
            % n parmi k
            comb=factorial(cg)./(factorial(k_ite).*factorial(cg-k_ite)); %plus rapide que nchoosek (10 fois plus rapide)
            % elevation a la puissance de u
            pow=cg-k_ite;
            ueg=bsxfun(@power,u,pow);
            %calcul terme de la somme
            coef_f=coef.*comb;
            prod_a=bsxfun(@times,coef_f,ueg.*t(:,:,1:cg+1));
            sum_tmp=sum(prod_a,3);
            %calcul de la valeur du critere GEI
            GEI(:,:,cg+1)=varg.*sum_tmp;
        end
    end
end
