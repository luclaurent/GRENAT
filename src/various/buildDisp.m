%% Build space for plotting 2D function
%% L. LAURENT -- 05/01/2011 -- luc.laurent@lecnam.net

function [XY,dispData]=buildDisp(doeData,dispData)

fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')
fprintf('     >>> BUILD DISPLAY <<<\n');
[tMesu,tInit]=mesu_time;
%dimension of the sapce
spaDim=numel(doeData.Xmin);

% the grid is built depending on the number of designa variables

if spaDim==1
    XY=linspace(doeData.Xmin,doeData.Xmax,dispData.nbv)';
    
    % in 2D the grid is defined using meshgrid
elseif spaDim==2
    x=linspace(doeData.Xmin(1),doeData.Xmax(1),dispData.nbv);
    y=linspace(doeData.Xmin(2),doeData.Xmax(2),dispData.nbv);
    [gridX,gridY]=meshgrid(x,y);
    
    XY=zeros(size(gridX,1),size(gridX,2),2);
    XY(:,:,1)=gridX;
    XY(:,:,2)=gridY;
    
else
    % in nD the full factorial function is used
    grid=doeFactorial(dispData.nbv,doeData.Xmin,doeData.Xmax);
    
    %reordering the grid
    XY=zeros(size(grid,1),1,spaDim);
    for ii=1:spaDim
        XY(:,:,ii)=grid(:,ii);
    end
    
    
end

%step of the grid 
dispData.step=abs(doeData.Xmax-doeData.Xmin)./dispData.nbv;

fprintf(' >> Number of points on the grid %i (%i',dispData.nbv^spaDim,dispData.nbv);
fprintf('x%i',dispData.nbv*ones(1,spaDim-1));fprintf(')\n');

mesu_time(tMesu,tInit);
fprintf('=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=\n')