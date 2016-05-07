%% save figure in file
%% L. LAURENT -- 17/12/2010 -- luc.laurent@lecnam.net

function fileFig=saveDisp(num,foldS)

if isempty(num)
    global dispData
    
    dispData.num=dispData.num+1;
    num=dispData.num;
end
%generate filename
if ischar(num)
    nameFile=num;
else
    nameFile=['fig_' num2str(num,'%04.0f')];
end

%if the folder does not exist, creation
if ~exist(foldS,'dir')
    mkdir(foldS)
end


set(gcf,'Renderer','painters');      %for saving figure in nodisplay mode
nameFig=[foldS '/' nameFile '.eps'];
namefigM=[foldS '/' nameFile '.fig'];
fprintf('>>Save figure: \n fichier %s\n',nameFig)
saveas(gcf, nameFig,'psc2');
saveas(gcf, namefigM,'fig');
fileFig=nameFig;
end


