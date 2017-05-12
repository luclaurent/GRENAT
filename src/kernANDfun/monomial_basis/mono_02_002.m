function [poly,polyD,polyDD]=mono_02_002()

derprem=false;dersecond=false;
if nargout>=2;derprem=true;end
if nargout==3;dersecond=true;end

Xpow=[
0 1 2 0 1 0 
0 0 0 1 1 2 
];
poly.Xpow=reshape(Xpow',[1,6,2]);
Xcoef=[
1 1 1 1 1 1 
1 1 1 1 1 1 
];
poly.Xcoef=reshape(Xcoef,[1,6,2]);
poly.nbMono=6;

if derprem
DXpow=[
0 0 1 0 0 0 
0 0 0 0 1 0 
0 0 0 0 1 0 
0 0 0 0 0 1 
];
polyD.Xpow=permute(reshape(DXpow',6,1,2,2),[2 1 3 4]);
DXcoef=[
0 1 2 0 1 0 
0 0 0 1 1 2 
];
polyD.Xcoef=reshape(DXcoef',[1,6,2]);
end

if dersecond
DDXpow=[
0 0 0 0 0 0 
0 0 0 0 0 0 
0 0 0 0 0 0 
0 0 0 0 0 0 
0 0 0 0 0 0 
0 0 0 0 0 0 
0 0 0 0 0 0 
0 0 0 0 0 0 
];
polyDD.Xpow=permute(reshape(DDXpow',6,1,2,4),[2 1 3 4]);
DDXcoef=[
0 0 2 0 0 0 
0 0 0 0 1 0 
0 0 0 0 1 0 
0 0 0 0 0 2 
];
polyDD.Xcoef=reshape(DDXcoef',[1,6,4]);
end

end

