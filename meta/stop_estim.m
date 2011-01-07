%% Fonction assurant l'arret de la procedure d'optimisation
%% L. LAURENt -- 07/01/2011 -- laurent@lmt.ens-cachan.fr

function stop=stop_estim(x,optimValues,state)

%  x : point calcule par l'algorithme à l'iteration courante
%  optimValues: structure contenant les données de l'itération courante
%  state: différents statuts de l'algorithem
%  stop: etat d'arret de l'algorithme de minimisation

stop=false;
switch state
    case 'iter'
          if abs(optimValues.fval)==Inf
              stop=true;
          else
              plot(x,optimValues.fval,'o','MarkerSize',3);
              text(x+.15,optimValues.fval,num2str(optimValues.iteration));
              drawnow
          end
    case 'interrupt'
          stop=true;
    case 'init'
          figure;
          title('Iterations algorithme de minimisation')
          hold on
    case 'done'
          hold off

otherwise
end

