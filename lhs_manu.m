%%%Fonction permettant de reutiliser des tirages LHS existants
%% L. Laurent -- 25/01/2011  -- laurent@lmt.ens-cachan.fr

function  tir=lhs_manu(doe,fct)

%on verifie si le dossier de stockage existe (si non on le cree)
if exist('LHS_MANU','dir')~=7
    unix('mkdir LHS_MANU');
end


%on prend en compte les tirages differents suivant les variables de
%conceptions
if length(doe.nb_samples)==2
    nb_s1=doe.nb_samples(1);
    nb_s2=doe.nb_samples(2);
else
    nb_s1=doe.nb_samples;
    nb_s2=0;
end

%on verifie si le tirages existe deja (si oui on le charge/si non on le
%genere et le sauvegarde)
fi=['LHS_MANU/lhs_man_' fct '_' num2str(nb_s1,'%d') '_' num2str(nb_s2,'%d')];
fich=[fi '.mat'];
if exist(fich,'file')==2
    st=load(fich,'tir_save');
    tir=st.tir_save;
else
    xmin=doe.bornes(1,1);
    xmax=doe.bornes(1,2);
    ymin=doe.bornes(2,1);
    ymax=doe.bornes(2,2);
    Xmin=[xmin,ymin];
    Xmax=[xmax,ymax];
    if nb_s2==0
        tir=lhsu(Xmin,Xmax,nb_s1);
    else
        tir=lhsu(Xmin,Xmax,nb_s1*nb_s2);
    end
    
    tir_save=tir;
    save(fi,'tir_save');
end