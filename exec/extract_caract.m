%% Fichier d'extraction de donn�es pour comparaison qualite KRG/CKRG
%% L. LAURENT -- 14/01/2011 -- laurent@lmt.ens-cachan.fr

%extraction au format LaTeX

function  extract_caract(meta,donnees,fct,const)

dossp='results/cmp_meta';
unix(['mkdir ' dossp]);


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
ligne{15}=[char(36) 'l' char(36)];

name_li=ligne; name_li{5}='R2'; name_li{15}='long';
name_li{11}='bmcv';name_li{12}='msecv';name_li{13}='cradcv';name_li{14}='presscv';name_li{2}='tpscons';name_li{3}='nbitermin';


%boucle sur les metamodeles construits
for itconst=1:length(const)
    
    %ouverture fichier
    fichier=[dossp,'/extract_tab_',const{itconst},'_',meta.corr,'_',fct,'.tex'];
    fich=fopen(fichier,'w');
    fprintf(fich,'%sbegin{tabular}{|%s',char(92),repmat('c|',1,size(donnees{itconst},2)+1));
    fprintf(fich,'}');
    fprintf(fich,'\n%shline\n',char(92));
    
    for i=1:length(ligne)
        fprintf(fich,'%s\t',ligne{i});
        for j=1:size(donnees{itconst},2)
            %comparaison avec autre metamodele etudie pour ceratins crit�re
            if ~isempty(find(i==[2:12 14]))
                if abs(donnees{itconst}(i,j))<abs(donnees{mod(itconst,length(const))+1}(i,j))
                    fprintf(fich,'%s %scellcolor{lightgray} %stextbf{%snum{%d}}\t',char(38),char(92),char(92),char(92),donnees{itconst}(i,j));
                else
                    fprintf(fich,'%s %snum{%d}\t',char(38),char(92),donnees{itconst}(i,j));
                end
            elseif i==13
                if abs(donnees{itconst}(i,j)-1)<abs(donnees{mod(itconst,length(const))+1}(i,j)-1)
                    if abs(donnees{itconst}(i,j))==Inf
                        fprintf(fich,'%s %scellcolor{lightgray} %stextbf{%d}\t',char(38),char(92),char(92),donnees{itconst}(i,j));
                    else
                        fprintf(fich,'%s %scellcolor{lightgray} %stextbf{%snum{%d}}\t',char(38),char(92),char(92),char(92),donnees{itconst}(i,j));
                    end
                else
                    if abs(donnees{itconst}(i,j))==Inf
                        fprintf(fich,'%s %d\t',char(38),donnees{itconst}(i,j));
                    else
                        fprintf(fich,'%s %snum{%d}\t',char(38),char(92),donnees{itconst}(i,j));
                    end
                end
            else
                fprintf(fich,'%s %snum{%d}\t',char(38),char(92),donnees{itconst}(i,j));
            end
        end
        fprintf(fich,'%s%s\n%shline\n',char(92),char(92),char(92));
    end
    fprintf(fich,'%send{tabular}',char(92));
    fclose(fich);
    
    
    %ecriture liste de points pour courbes
    fichier=[dossp,'/extract_plot_',const{itconst},'_',meta.corr,'_',fct,'.txt'];
    fich=fopen(fichier,'w');
    for ii=2:length(ligne)
        fichierr=[dossp,'/extract_plot_',const{itconst},'_',meta.corr,'_',fct,'_',name_li{ii},'.dat'];
        data=[donnees{itconst}(1,:)',donnees{itconst}(ii,:)'];
        save(fichierr,'data','-ascii');
        
        fprintf(fich,'%s %s\n',char(37),ligne{ii});        
        for jj=1:size(donnees{itconst},2)
            fprintf(fich,'(%d,%d)\n',donnees{itconst}(1,jj),donnees{itconst}(ii,jj));
            
        end
        
        
    end
    fclose(fich);
end