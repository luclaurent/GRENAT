%% Sauvegarde figure
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function num=save_aff(num,dossier)

global aff

aff.num=aff.num+1;
set(gcf,'Renderer','painters')      %pour sauvegarde image en -nodisplay
nomfig=[dossier '/fig_' num2str(aff.num,'%04.0f') '.eps'];
nomfigm=[dossier '/fig_' num2str(aff.num,'%04.0f') '.fig'];
fprintf('>>Sauvegarde figure: \n fichier %s\n',nomfig)
saveas(gcf, nomfig,'psc2');
saveas(gcf, nomfigm,'fig');