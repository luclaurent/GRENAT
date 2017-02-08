function [poly,polyD,polyDD]=mono_03_002()

derprem=false;dersecond=false;
if nargout>=2;derprem=true;end
if nargout==3;dersecond=true;end

Xpow=[
0 1 2 3 0 1 2 0 1 0 
0 0 0 0 1 1 1 2 2 3 
];
poly.Xpow=reshape(Xpow',[1,10,2]);
Xcoef=[
1 1 1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 1 1 
];
poly.Xcoef=reshape(Xcoef,[1,10,2]);
poly.nbMono=10;

if derprem
DXpow=[
0 0 1 2 0 0 1 0 0 0 
0 0 0 0 0 1 1 0 2 0 
0 0 0 0 0 1 2 0 1 0 
0 0 0 0 0 0 0 1 1 2 
];
polyD.Xpow=permute(reshape(DXpow',10,1,2,2),[2 1 3 4]);
DXcoef=[
0 1 2 3 0 1 2 0 1 0 
0 0 0 0 1 1 1 2 2 3 
];
polyD.Xcoef=reshape(DXcoef',[1,10,2]);
end

if dersecond
DDXpow=[
0 0 0 1 0 0 0 0 0 0 
0 0 0 0 0 0 1 0 0 0 
0 0 0 0 0 0 1 0 0 0 
0 0 0 0 0 0 0 0 1 0 
0 0 0 0 0 0 1 0 0 0 
0 0 0 0 0 0 0 0 1 0 
0 0 0 0 0 0 0 0 1 0 
0 0 0 0 0 0 0 0 0 1 
];
polyDD.Xpow=permute(reshape(DDXpow',10,1,2,4),[2 1 3 4]);
DDXcoef=[
0 0 2 6 0 0 2 0 0 0 
0 0 0 0 0 1 2 0 2 0 
0 0 0 0 0 1 2 0 2 0 
0 0 0 0 0 0 0 2 2 6 
];
polyDD.Xcoef=reshape(DDXcoef',[1,10,4]);
end

end

