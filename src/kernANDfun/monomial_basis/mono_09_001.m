function [poly,polyD,polyDD]=mono_09_001()

derprem=false;dersecond=false;
if nargout>=2;derprem=true;end
if nargout==3;dersecond=true;end

Xpow=[
0 1 2 3 4 5 6 7 8 9 
];
poly.Xpow=reshape(Xpow',[1,10,1]);
Xcoef=[
1 1 1 1 1 1 1 1 1 1 
];
poly.Xcoef=reshape(Xcoef,[1,10,1]);
poly.nbMono=10;

if derprem
DXpow=[
0 0 1 2 3 4 5 6 7 8 
];
polyD.Xpow=permute(reshape(DXpow',10,1,1,1),[2 1 3 4]);
DXcoef=[
0 1 2 3 4 5 6 7 8 9 
];
polyD.Xcoef=reshape(DXcoef',[1,10,1]);
end

if dersecond
DDXpow=[
0 0 0 1 2 3 4 5 6 7 
];
polyDD.Xpow=permute(reshape(DDXpow',10,1,1,1),[2 1 3 4]);
DDXcoef=[
0 0 2 6 12 20 30 42 56 72 
];
polyDD.Xcoef=reshape(DDXcoef',[1,10,1]);
end

end

