function [poly,polyD,polyDD]=mono_09_002()

derprem=false;dersecond=false;
if nargout>=2;derprem=true;end
if nargout==3;dersecond=true;end

Xpow=[
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 0 1 2 3 4 5 6 7 0 1 2 3 4 5 6 0 1 2 3 4 5 0 1 2 3 4 0 1 2 3 0 1 2 0 1 0 
0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 4 4 4 4 4 4 5 5 5 5 5 6 6 6 6 7 7 7 8 8 9 
];
poly.Xpow=reshape(Xpow',[1,55,2]);
Xcoef=[
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
];
poly.Xcoef=reshape(Xcoef,[1,55,2]);
poly.nbMono=55;

if derprem
DXpow=[
0 0 1 2 3 4 5 6 7 8 0 0 1 2 3 4 5 6 7 0 0 1 2 3 4 5 6 0 0 1 2 3 4 5 0 0 1 2 3 4 0 0 1 2 3 0 0 1 2 0 0 1 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 2 2 2 2 2 2 2 0 3 3 3 3 3 3 0 4 4 4 4 4 0 5 5 5 5 0 6 6 6 0 7 7 0 8 0 
0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 8 0 1 2 3 4 5 6 7 0 1 2 3 4 5 6 0 1 2 3 4 5 0 1 2 3 4 0 1 2 3 0 1 2 0 1 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 3 3 3 3 3 3 4 4 4 4 4 5 5 5 5 6 6 6 7 7 8 
];
polyD.Xpow=permute(reshape(DXpow',55,1,2,2),[2 1 3 4]);
DXcoef=[
0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 0 1 2 3 4 5 6 7 0 1 2 3 4 5 6 0 1 2 3 4 5 0 1 2 3 4 0 1 2 3 0 1 2 0 1 0 
0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 4 4 4 4 4 4 5 5 5 5 5 6 6 6 6 7 7 7 8 8 9 
];
polyD.Xcoef=reshape(DXcoef',[1,55,2]);
end

if dersecond
DDXpow=[
0 0 0 1 2 3 4 5 6 7 0 0 0 1 2 3 4 5 6 0 0 0 1 2 3 4 5 0 0 0 1 2 3 4 0 0 0 1 2 3 0 0 0 1 2 0 0 0 1 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 0 0 2 2 2 2 2 2 0 0 3 3 3 3 3 0 0 4 4 4 4 0 0 5 5 5 0 0 6 6 0 0 7 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 0 0 1 2 3 4 5 6 0 0 1 2 3 4 5 0 0 1 2 3 4 0 0 1 2 3 0 0 1 2 0 0 1 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 0 2 2 2 2 2 2 0 3 3 3 3 3 0 4 4 4 4 0 5 5 5 0 6 6 0 7 0 
0 0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 0 0 1 2 3 4 5 6 0 0 1 2 3 4 5 0 0 1 2 3 4 0 0 1 2 3 0 0 1 2 0 0 1 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 0 2 2 2 2 2 2 0 3 3 3 3 3 0 4 4 4 4 0 5 5 5 0 6 6 0 7 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 0 1 2 3 4 5 6 0 1 2 3 4 5 0 1 2 3 4 0 1 2 3 0 1 2 0 1 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 2 2 2 2 2 2 3 3 3 3 3 4 4 4 4 5 5 5 6 6 7 
];
polyDD.Xpow=permute(reshape(DDXpow',55,1,2,4),[2 1 3 4]);
DDXcoef=[
0 0 2 6 12 20 30 42 56 72 0 0 2 6 12 20 30 42 56 0 0 2 6 12 20 30 42 0 0 2 6 12 20 30 0 0 2 6 12 20 0 0 2 6 12 0 0 2 6 0 0 2 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 8 0 2 4 6 8 10 12 14 0 3 6 9 12 15 18 0 4 8 12 16 20 0 5 10 15 20 0 6 12 18 0 7 14 0 8 0 
0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 8 0 2 4 6 8 10 12 14 0 3 6 9 12 15 18 0 4 8 12 16 20 0 5 10 15 20 0 6 12 18 0 7 14 0 8 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 2 2 2 2 2 2 2 6 6 6 6 6 6 6 12 12 12 12 12 12 20 20 20 20 20 30 30 30 30 42 42 42 56 56 72 
];
polyDD.Xcoef=reshape(DDXcoef',[1,55,4]);
end

end

