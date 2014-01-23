%%création liste execution

dim_min=2;
dim_max=10;

base_nom='MOY_qual_meta_';
fin_nom='Dl';
nom_fct={'Rosenbrock','Rastrigin','Schwefel'};

nb_exec=50;

nom_liste='liste_';


for ii=1:numel(nom_fct);
    fich=fopen([nom_liste nom_fct{ii}],'w');
    ite=1;
    for ll=dim_max:-1:dim_min
        
        for jj=1:nb_exec
            ligne=[char(35) char(35) char(35) char(35) char(35) num2str(ite,'%03i')...
                ' ' base_nom nom_fct{ii} '_' num2str(ll) fin_nom ...
                ' ' nom_fct{ii} '_' num2str(ll) fin_nom];
            fprintf(fich,ligne);
            fprintf(fich,'\n');
            ite=ite+1;
        end
    end
    fclose(fich);
end
