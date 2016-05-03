%% Fonction assurant l'arret de la procedure d'optimisation
%% L. LAURENT -- 07/01/2011 -- laurent@lmt.ens-cachan.fr

function stop=stopEstim(x,optimValues,state)

%  x : point calculated at the current iteration 
%  optimValues: structure containing data at the current iteration
%  state: various state of the algorithm
%  stop: stopping status of the minimization algorithm

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
        if size(x,2)<3
            figure;
            title('Iteration of the minimisation algorithm')
            hold on
        end
    case 'done'
        if size(x,2)<3
            hold off
        end
        
    otherwise
end


