function [poly,polyD,polyDD]=mono_02_001()

derprem=false;dersecond=false;
if nargout>=2;derprem=true;end
if nargout==3;dersecond=true;end

Xpow=[
0 1 2 
];
poly.Xpow=reshape(Xpow',[1,3,1]);
Xcoef=[
1 1 1 
];
poly.Xcoef=reshape(Xcoef,[1,3,1]);
poly.nbMono=3;

if derprem
DXpow=[
0 0 1 
];
polyD.Xpow=permute(reshape(DXpow',3,1,1,1),[2 1 3 4]);
DXcoef=[
0 1 2 
];
polyD.Xcoef=reshape(DXcoef',[1,3,1]);
end

if dersecond
DDXpow=[
0 0 0 
];
polyDD.Xpow=permute(reshape(DDXpow',3,1,1,1),[2 1 3 4]);
DDXcoef=[
0 0 2 
];
polyDD.Xcoef=reshape(DDXcoef',[1,3,1]);
end

end

