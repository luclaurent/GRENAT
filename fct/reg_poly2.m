%fonction assurant l'evaluation d'une fonction polynomiale de degre 2
%L.LAURENT -- 11/05/2010 -- luc.laurent@ens-cachan.fr

function [ret,dret]=reg_poly2(val)


d=size(val,2);
p=(d+1)*(d+2)*1/2;

t=val;
tt=zeros(p-d-1,1);

j=0;m=d;
for  ii=1:d
    tt(j+(1:m))=val(ii).*val(ii:d);
    j=j+m;
    m=m-1;
end

%evaluation de la fonction polynomiale
ret=[1 t tt];
ret
val




%evaluation de la derivee
if nargout==2
    dd=zeros(d,p-d-1);
    for ii=1:d
        dd(ii,:)
    end
    
    dret=[zeros(d,1) eye(d) dd];
end
end
