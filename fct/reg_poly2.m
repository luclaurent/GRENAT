%fonction assurant l'évaluation d'une fonction polynomiale de degré 2
%L.LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function [ret,dret]=reg_poly2(val)

ret=[1 val(1) val(2) val(1)^2 val(2)^2 val(1)*val(2)];
if nargout==2
    dret=zeros(2,6);
    dret(1,:)=[0 1 0 2*val(1) 0 val(2)];
    dret(2,:)=[0 0 1 0 2*val(2) val(1)];
end
end
