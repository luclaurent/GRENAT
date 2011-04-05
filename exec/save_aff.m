%% Sauvegarde figure
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function fich=save_aff(num,dossier)

if isempty(num)
    global aff
    
    aff.num=aff.num+1;
    num=aff.num;
end

set(gcf,'Renderer','painters')      %pour sauvegarde image en -nodisplay
nomfig=[dossier '/fig_' num2str(num,'%04.0f') '.eps'];
nomfigm=[dossier '/fig_' num2str(num,'%04.0f') '.fig'];
fprintf('>>Sauvegarde figure: \n fichier %s\n',nomfig)
saveas(gcf, nomfig,'psc2');
saveas(gcf, nomfigm,'fig');

fich=nomfig;