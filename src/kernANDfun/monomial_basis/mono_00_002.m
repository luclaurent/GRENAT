function [poly,polyD,polyDD]=mono_00_002()

derprem=false;dersecond=false;
if nargout>=2;derprem=true;end
if nargout==3;dersecond=true;end

Xpow=[
0 
0 
];
poly.Xpow=reshape(Xpow',[1,1,2]);
Xcoef=[
1 
1 
];
poly.Xcoef=reshape(Xcoef,[1,1,2]);
poly.nbMono=1;

if derprem
DXpow=[
0 
0 
0 
0 
];
polyD.Xpow=permute(reshape(DXpow',1,1,2,2),[2 1 3 4]);
DXcoef=[
0 
0 
];
polyD.Xcoef=reshape(DXcoef',[1,1,2]);
end

if dersecond
DDXpow=[
0 
0 
0 
0 
0 
0 
0 
0 
];
polyDD.Xpow=permute(reshape(DDXpow',1,1,2,4),[2 1 3 4]);
DDXcoef=[
0 
0 
0 
0 
];
polyDD.Xcoef=reshape(DDXcoef',[1,1,4]);
end

end

