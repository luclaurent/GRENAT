%% save figure figure
%% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

function fich=saveDisp(num,dossier)

if isempty(num)
    global aff
    
    aff.num=aff.num+1;
    num=aff.num;
else
    if ischar(num)
        nameFile=num;
    else
        nameFile=['fig_' num2str(num,'%04.0f')];
    end
end


set(gcf,'Renderer','painters')      %for saving figure in nodisplay mode
nameFig=[dossier '/' nameFile '.eps'];
namefigM=[dossier '/' nameFile '.fig'];
fprintf('>>Save figure: \n fichier %s\n',nameFig)
saveas(gcf, nameFig,'psc2');
saveas(gcf, namefigM,'fig');
fich=nameFig;
end


