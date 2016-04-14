%fonction assurant l'evaluation d'une fonction polynomiale de degre 1
%L.LAURENT -- 11/05/2010 -- luc.laurent@lecnam.net

%% IN:
%   -val: points d'évaluation (ligne: coordonnées d'un point, colonne: les
%   différents points)
%   -ret: monome
%   -dret: derivees

function [ret,dret]=reg_poly1(val)

d=size(val);

%fonction polynomiale
ret=[ones(d(1),1) val];
%derivee
if nargout==2
    if d(1)==1
        dret=[zeros(d(2),1) eye(d(2))];
    else
        dret=cell(d(1),1);
        for ii=1:d(1)
            dret{ii}=[zeros(d(2),1) eye(d(2))];
        end
        dret=vertcat(dret{:});
    end
end
end
