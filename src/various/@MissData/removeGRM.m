function VV=removeGRM(obj,V,type)
%size of the input vector
sV=size(V);
%deal with no force parameter
if nargin<3;type='';end
%deal with different options (in type)
force=false;
sizS=obj.nS;
opt='';
switch type
    case {'f','F','force','Force','FORCE'}
        force=true;
        opt='f';
    case {'n','N','new','New','NEW'}
        sizS=obj.NnS;
        opt='n';
end
if (sV(1)==sizS*(obj.nP+1)&&sV(2)==sizS*(obj.nP+1))||force
    %split the matrix in four parts
    Va=V(1:sizS,1:sizS);
    Vb=V(1:sizS,sizS+1:end);
    Vbt=V(sizS+1:end,1:sizS);
    Vc=V(sizS+1:end,sizS+1:end);
    %
    VaR=obj.removeRM(Va,opt);
    VbR=obj.removeRV(obj.removeGV(Vb',opt)',opt);
    VbtR=obj.removeRV(obj.removeGV(Vbt,opt)',opt)';
    VcR=obj.removeGM(Vc,opt);
    %
    VV=[VaR VbR;VbtR VcR];
else
    VV=V;
    Gfprintf(' ++ Wrong size of the input matrix\n ++ |(%i,%i), expected: (%i,%i)|\n',sV(1),sV(2),sizS*(obj.nP+1),sizS*(obj.nP+1));
end
end