% Affichage de la date et/ou de l'heure
% L. LAURENT -- 17/12/2010 -- laurent@lmt.ens-cachan.fr

day=clock;
fprintf('Date: %d/%d/%d   Time: %02.0f:%02.0f:%02.0f\n',...
    day(3), day(2), day(1), day(4), day(5), day(6))