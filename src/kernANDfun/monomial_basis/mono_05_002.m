function [poly,polyD,polyDD]=mono_05_002()

derprem=false;dersecond=false;
if nargout>=2;derprem=true;end
if nargout==3;dersecond=true;end

Xpow=[
0 1 2 3 4 5 0 1 2 3 4 0 1 2 3 0 1 2 0 1 0 
0 0 0 0 0 0 1 1 1 1 1 2 2 2 2 3 3 3 4 4 5 
];
poly.Xpow=reshape(Xpow',[1,21,2]);
Xcoef=[
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
];
poly.Xcoef=reshape(Xcoef,[1,21,2]);
poly.nbMono=21;

if derprem
DXpow=[
0 0 1 2 3 4 0 0 1 2 3 0 0 1 2 0 0 1 0 0 0 
0 0 0 0 0 0 0 1 1 1 1 0 2 2 2 0 3 3 0 4 0 
0 0 0 0 0 0 0 1 2 3 4 0 1 2 3 0 1 2 0 1 0 
0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 2 2 2 3 3 4 
];
polyD.Xpow=permute(reshape(DXpow',21,1,2,2),[2 1 3 4]);
DXcoef=[
0 1 2 3 4 5 0 1 2 3 4 0 1 2 3 0 1 2 0 1 0 
0 0 0 0 0 0 1 1 1 1 1 2 2 2 2 3 3 3 4 4 5 
];
polyD.Xcoef=reshape(DXcoef',[1,21,2]);
end

if dersecond
DDXpow=[
0 0 0 1 2 3 0 0 0 1 2 0 0 0 1 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 1 1 1 0 0 2 2 0 0 3 0 0 0 
0 0 0 0 0 0 0 0 1 2 3 0 0 1 2 0 0 1 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 2 2 0 3 0 
0 0 0 0 0 0 0 0 1 2 3 0 0 1 2 0 0 1 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 2 2 0 3 0 
0 0 0 0 0 0 0 0 0 0 0 0 1 2 3 0 1 2 0 1 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 2 2 3 
];
polyDD.Xpow=permute(reshape(DDXpow',21,1,2,4),[2 1 3 4]);
DDXcoef=[
0 0 2 6 12 20 0 0 2 6 12 0 0 2 6 0 0 2 0 0 0 
0 0 0 0 0 0 0 1 2 3 4 0 2 4 6 0 3 6 0 4 0 
0 0 0 0 0 0 0 1 2 3 4 0 2 4 6 0 3 6 0 4 0 
0 0 0 0 0 0 0 0 0 0 0 2 2 2 2 6 6 6 12 12 20 
];
polyDD.Xcoef=reshape(DDXcoef',[1,21,4]);
end

end

