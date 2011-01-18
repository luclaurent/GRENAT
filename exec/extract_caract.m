%% Fichier d'extraction de données pour comparaison qualite KRG/CKRG
%% L. LAURENT -- 14/01/2011 -- laurent@lmt.ens-cachan.fr

%extraction au format LaTeX

function  extract_caract(meta,donnees,aff,fct)


%contenu lignes
ligne=cell(1,15);
ligne{1}='Nombre de tirages';
ligne{2}='Temps de construction (s)';
ligne{3}='Nombre iterations minimisation';
ligne{4}='MSE';
ligne{5}=[char(36) 'R^{2}' char(36)];
ligne{6}='RAAE';
ligne{7}='RMAE';
ligne{8}='Q1';
ligne{9}='Q2';
ligne{10}='Q3';
ligne{11}='Biais moyen (CV)';
ligne{12}='MSE (CV)';
ligne{13}='Critere adequation (CV)';
ligne{14}='PRESS (CV)';
ligne{15}=[char(36) '\theta' char(36)];



%ouverture fichier
fichier=[aff.doss '/extract_tab_' meta.type '_' meta.corr '_' fct '.tex'];
fich=fopen(fichier,'w');
fprintf(fich,'%sbegin{tabular}{|%s',char(92),repmat('c|',1,size(donnees,2)+1));
fprintf(fich,'}');
fprintf(fich,'\n%shline\n',char(92));

for i=1:length(ligne)
    fprintf(fich,'%s\t',ligne{i});
    for j=1:size(donnees,2)
        fprintf(fich,'%s %d\t',char(38),donnees(i,j));
    end
    fprintf(fich,'%s%s\n%shline\n',char(92),char(92),char(92));
end
fprintf(fich,'%send{tabular}',char(92));
fclose(fich);

        
fichier=[aff.doss '/extract_plot_' meta.type '_' meta.corr '_' fct '.txt'];
fich=fopen(fichier,'w');
for ii=2:length(ligne)
    fprintf(fich,'\n\n\n %s %s\n',char(37),ligne{ii});
    for jj=1:size(donnees,2)
        fprintf(fich,'(%d,%d)\n',donnees(1,jj),donnees(ii,jj));
    end
        
end
fclose(fich);