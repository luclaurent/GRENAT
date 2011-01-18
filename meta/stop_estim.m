%% Fonction assurant l'arret de la procedure d'optimisation
%% L. LAURENt -- 07/01/2011 -- laurent@lmt.ens-cachan.fr

function stop=stop_estim(x,optimValues,state)

%  x : point calcule par l'algorithme a  l'iteration courante
%  optimValues: structure contenant les donnees de l'iteration courante
%  state: differents statuts de l'algorithem
%  stop: etat d'arret de l'algorithme de minimisation

stop=false;
switch state
    case 'iter'
              plot(x,optimValues.fval,'o','MarkerSize',3);
              text(x+.05,optimValues.fval,num2str(optimValues.iteration));
              drawnow
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

