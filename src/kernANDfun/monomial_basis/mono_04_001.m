function [poly,polyD,polyDD]=mono_04_001()

derprem=false;dersecond=false;
if nargout>=2;derprem=true;end
if nargout==3;dersecond=true;end

Xpow=[
0 1 2 3 4 
];
poly.Xpow=reshape(Xpow',[1,5,1]);
Xcoef=[
1 1 1 1 1 
];
poly.Xcoef=reshape(Xcoef,[1,5,1]);
poly.nbMono=5;

if derprem
DXpow=[
0 0 1 2 3 
];
polyD.Xpow=permute(reshape(DXpow',5,1,1,1),[2 1 3 4]);
DXcoef=[
0 1 2 3 4 
];
polyD.Xcoef=reshape(DXcoef',[1,5,1]);
end

if dersecond
DDXpow=[
0 0 0 1 2 
];
polyDD.Xpow=permute(reshape(DDXpow',5,1,1,1),[2 1 3 4]);
DDXcoef=[
0 0 2 6 12 
];
polyDD.Xcoef=reshape(DDXcoef',[1,5,1]);
end

end

