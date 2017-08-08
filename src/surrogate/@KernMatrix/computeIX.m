%compute indices
function iX=computeIX(obj)
if obj.requireIndices
    ns=obj.nS;
    np=obj.nP;
    % Building indices system
    %table of indices for inter-lenghts  (1), responses (1)
    tmpIX=allcomb(1:ns,1:ns);
    iXsampling=tmpIX(tmpIX(:,1)<=tmpIX(:,2),:);
    iXmatrix=(iXsampling(:,1)-1)*ns+iXsampling(:,2);
    %
    iX.iXsampling=iXsampling;
    iX.matrix=iXmatrix;
    %for gradients
    if obj.computeD
        %
        sizeMatRc=(ns^2+ns)/2;
        sizeMatRa=np*sizeMatRc;
        sizeMatRi=np^2*sizeMatRc;
        iXmatrixAb=zeros(sizeMatRa,1);
        iXmatrixI=zeros(sizeMatRi,1);
        %
        ite=0;
        iteAb=0;
        %table of indices for 1st derivatives (2)
        for ii=1:ns
            %
            ite=ite(end)+(1:(ns-ii+1));
            iteAb=iteAb(end)+(1:((ns-ii+1)*np));
            %
            debb=(ii-1)*np*ns+ii;
            finb=ns^2*np-(ns-ii);
            lib=debb:ns:finb;
            %
            iXmatrixAb(iteAb)=lib;
        end
        %table of indices for second derivatives
        a=zeros(ns*np,np);
        decal=0;
        precI=0;
        for ii=1:ns
            li=1:ns*np^2;
            a(:)=decal+li;
            decal=a(end);
            b=a';
            iteI=precI+(1:(np^2*(ns-(ii-1))));
            debb=(ii-1)*np^2+1;
            finb=np^2*ns;
            iteb=debb:finb;
            iXmatrixI(iteI)=b(iteb);
            precI=iteI(end);
        end
        %store indices
        iX.matrixAb=iXmatrixAb;
        iX.matrixI=iXmatrixI;
    end
    %
    obj.iX=iX;
    %
    obj.requireIndices=false;
else
    iX=obj.iX;
end

end