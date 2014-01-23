%% Sauvegarde figure
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function fich=save_aff(num,dossier)

if isempty(num)
    global aff
    
    aff.num=aff.num+1;
    num=aff.num;
else
    if ischar(num)
        nomfich=num;
    else
        nomfich=['fig_' num2str(num,'%04.0f')];
    end
end


set(gcf,'Renderer','painters')      %pour sauvegarde image en -nodisplay
nomfig=[dossier '/' nomfich '.eps'];
nomfigm=[dossier '/' nomfich '.fig'];
fprintf('>>Sauvegarde figure: \n fichier %s\n',nomfig)
saveas(gcf, nomfig,'psc2');
saveas(gcf, nomfigm,'fig');


fich=nomfig;
end


