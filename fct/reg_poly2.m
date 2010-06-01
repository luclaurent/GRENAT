%fonction assurant l'évaluation d'une fonction polynomiale de degré 2
%L.LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function [ret,dret]=reg_poly2(val)


d=size(val,2);
p=(d+1)*(d+2)*1/2;

t=val;
tt=zeros(1,p-d-1);

for  ii=1:d
    tt(d*(ii-1)+1:d*ii)=val(ii).*val;
end

%évaluation de la fonction polynômiale
ret=[1 t tt];

%évaluation de la dérivée
if nargout==2
    dd=zeros(d,p-d-1);
    for ii=1:d
        dd(ii,:)
    end
    
    dret=[zeros(d,1) eye(d) dd];
end
end
