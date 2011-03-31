%% Fonction assurant l'arret de la procedure d'optimisation
%% L. LAURENT -- 07/01/2011 -- laurent@lmt.ens-cachan.fr

function stop=stop_estim(x,optimValues,state)

%  x : point calcule par l'algorithme a  l'iteration courante
%  optimValues: structure contenant les donnees de l'iteration courante
%  state: differents statuts de l'algorithem
%  stop: etat d'arret de l'algorithme de minimisation

stop=false;
switch state
    case 'iter'
        if size(x,2)==1
            plot(x,optimValues.fval,'o','MarkerSize',3);
            text(x+.05,optimValues.fval,num2str(optimValues.iteration));
            drawnow
        elseif size(x,2)==2
            plot3(x(1),x(2),optimValues.fval,'o','MarkerSize',3);
            text(x(1),x(2)+.05,optimValues.fval,num2str(optimValues.iteration));
            drawnow
        end
    case 'interrupt'
        %stop=true;
    case 'init'
        figure;
        title('Iterations algorithme de minimisation')
        hold on
    case 'done'
        hold off
        
    otherwise
end

