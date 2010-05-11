%fonction assurant l'évaluation d'une fonction polynomiale de degré 2
%L.LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function ret=reg_poly2(val)

ret=[1 val(1) val(2) val(1)^2 val(2)^2 val(1)*val(2)];;
end
