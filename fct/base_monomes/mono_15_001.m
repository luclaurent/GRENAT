function [MatX,nbmono,MatDX,CoefDX,MatDDX,CoefDDX]=mono_15_001(X)

derprem=false;dersecond=false;
if nargout>=4;derprem=true;end
if nargout==6;dersecond=true;end

MatX=[
 ones(size(X,1),1) ...
X(:,1) ...
X(:,1).^2 ...
X(:,1).^3 ...
X(:,1).^4 ...
X(:,1).^5 ...
X(:,1).^6 ...
X(:,1).^7 ...
X(:,1).^8 ...
X(:,1).^9 ...
X(:,1).^10 ...
X(:,1).^11 ...
X(:,1).^12 ...
X(:,1).^13 ...
X(:,1).^14 ...
X(:,1).^15
];
nbmono=16;

if derprem
MatDX=cell(1,size(X,2));

MatDX{1}=[
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
2.*X(:,1) ...
3.*X(:,1).^2 ...
4.*X(:,1).^3 ...
5.*X(:,1).^4 ...
6.*X(:,1).^5 ...
7.*X(:,1).^6 ...
8.*X(:,1).^7 ...
9.*X(:,1).^8 ...
10.*X(:,1).^9 ...
11.*X(:,1).^10 ...
12.*X(:,1).^11 ...
13.*X(:,1).^12 ...
14.*X(:,1).^13 ...
15.*X(:,1).^14
];

CoefDX=[
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 
];
end

if dersecond
MatDDX=cell(size(X,2),size(X,2));

MatDDX{1}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*ones(size(X,1),1) ...
6.*X(:,1) ...
12.*X(:,1).^2 ...
20.*X(:,1).^3 ...
30.*X(:,1).^4 ...
42.*X(:,1).^5 ...
56.*X(:,1).^6 ...
72.*X(:,1).^7 ...
90.*X(:,1).^8 ...
110.*X(:,1).^9 ...
132.*X(:,1).^10 ...
156.*X(:,1).^11 ...
182.*X(:,1).^12 ...
210.*X(:,1).^13
];

CoefDDX=[
0 0 2 6 12 20 30 42 56 72 90 110 132 156 182 210 
];
end

end

