%% Fichier d'éciture de données dans un fichier TeX
%% L. LAURENT -- 05/04/2011 -- laurent@lmt.ens-cachan.fr

function sauv_tex(meta,doe,aff,err,krg)

if aff.tex
    %création du fichier de sauvegarde des informations
    unix(['touch ' aff.doss '/results.tex']);
    fid=fopen([aff.doss '/results.tex'],'a','n','UTF-8');
    
   fprintf(fid,'\\chapter{%s %02.0f %02.0f %02.0f %02.0f:%02.0f:%02.0f}\n',meta.type,aff.date.day,aff.date.month,...
        aff.date.year,aff.date.hour,aff.date.minute,aff.date.second);
    
   
    fprintf(fid,'\\section{Caractéristiques du tirage}\n');
    
    fprintf(fid,'\\begin{itemize}\n');
    fprintf(fid,'\\item Type de tirage: %s\n',doe.type);
    fprintf(fid,'\\item Echantillons: [%g %g] [%g %g]\n',doe.bornes(1,1),...
        doe.bornes(1,2),doe.bornes(2,1),doe.bornes(2,2));
    
    
    fprintf(fid,'\\section{Caractéristiques du métamodèle}\n');
    fprintf(fid,'\\item Type de métamodèle: %s\n',meta.type);
    fprintf(fid,'\\item Fonction de corrélation: \\verb!%s!\n',meta.corr);
    fprintf(fid,'\\item Degré régression: %d\n',meta.deg);
    if meta.norm
        fprintf(fid,'\\item Données normalisées\n');
    end
    if meta.recond
        fprintf(fid,'\\item Amélioration du conditionnement\n');
    end
    if meta.cv
        fprintf(fid,'\\item Calcul critères par validation croisée\n');
    end
    if meta.para.estim
        fprintf(fid,'\n \\item Estimation des paramètres\n');
        fprintf(fid,'\\item Méthode: %s\n',meta.para.method);
        if meta.para.aniso
            fprintf(fid,'\\item Paramétres différents selon chaque coordonnée\n');
        end
        fprintf(fid,'\\item Espace de recherche: [%g %g]\n',meta.para.min,meta.para.max);
        fprintf(fid,'\\item Longueur de corrélation:');
        fprintf(fid,' %s%g%s ',char(36),krg.estim_para.val,char(36));
        fprintf(fid,'\n');
    else
        fprintf(fid,'\\item Longueur de corrélation: %g\n',meta.para.val);
    end
    fprintf(fid,'\\end{itemize}\n');
    fprintf(fid,'\\section{Critères d''erreur}\n');
    fprintf(fid,'\\begin{itemize}\n');
    if isfield(err,'emse')
        fprintf(fid,'\\item MSE: %s %g %s\n',char(36),err.emse,char(36));
        fprintf(fid,'\\item %sR^2%s: %s %g %s\n',char(36),char(36),char(36),err.r2,char(36));
        fprintf(fid,'\\item RAAE: %s %g %s\n',char(36),err.eraae,char(36));
        fprintf(fid,'\\item RMAE: %s %g %s\n',char(36),err.ermae,char(36));
        fprintf(fid,'\\item %sQ_1=%g%s %sQ_2=%g%s %sQ_3=%g%s\n',char(36),err.eq1,char(36),char(36),err.eq2,...
            char(36),char(36),err.eq3,char(36));
    end
    
    
    if isfield(err,'cv')
        fprintf(fid,'\\item Validation croisee:\n');
        fprintf(fid,'\\begin{itemize}\n');
        fprintf(fid,'\\item Biais moyen=%s%g%s\n',char(36),err.cv.bm,char(36));
        fprintf(fid,'\\item MSE=%s%g%s\n',char(36),err.cv.msep,char(36));
        fprintf(fid,'\\item Critere adequation=%s%g%s\n',char(36),err.cv.adequ,char(36));
        fprintf(fid,'\\item PRESS=%s%g%s\n',char(36),err.cv.press,char(36));
        fprintf(fid,'\\end{itemize}\n');
    end
    
    if isfield(err,'li')&isfield(err,'logli')
        fprintf(fid,'\\item Vraisemblance: ');
        fprintf(fid,'Likelihood= %s%6.4d%s, Log-Likelihood= %s%6.4d%s \n',char(36),cv.li,char(36),...
            char(36),cv.logli,char(36));
    end
    
    fprintf(fid,'\\end{itemize}\n');
    fprintf(fid,'\\input{../%s/fig.tex}\n',aff.doss);
    fclose(fid);
    
    
    
    
    %%Ecriture dans le fichier principal de compilatition LaTeX
    fid=fopen('results/results_tmp.tex','a','n','UTF-8');
    fprintf(fid,'\\input{%s}\n',['../' aff.doss '/results.tex']);
    
    
    fclose(fid);
    unix('rm -f results/results.tex');
    unix('cat results/results_tmp.tex results/end.tex >> results/results.tex');
    
end
