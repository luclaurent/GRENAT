function [MatX,nbmono,MatDX,CoefDX,MatDDX,CoefDDX]=mono_04_003(X)

derprem=false;dersecond=false;
if nargout>=4;derprem=true;end
if nargout==6;dersecond=true;end

MatX=[
 ones(size(X,1),1) ...
X(:,1) ...
X(:,1).^2 ...
X(:,1).^3 ...
X(:,1).^4 ...
X(:,2) ...
X(:,1).*X(:,2) ...
X(:,1).^2.*X(:,2) ...
X(:,1).^3.*X(:,2) ...
X(:,2).^2 ...
X(:,1).*X(:,2).^2 ...
X(:,1).^2.*X(:,2).^2 ...
X(:,2).^3 ...
X(:,1).*X(:,2).^3 ...
X(:,2).^4 ...
X(:,3) ...
X(:,1).*X(:,3) ...
X(:,1).^2.*X(:,3) ...
X(:,1).^3.*X(:,3) ...
X(:,2).*X(:,3) ...
X(:,1).*X(:,2).*X(:,3) ...
X(:,1).^2.*X(:,2).*X(:,3) ...
X(:,2).^2.*X(:,3) ...
X(:,1).*X(:,2).^2.*X(:,3) ...
X(:,2).^3.*X(:,3) ...
X(:,3).^2 ...
X(:,1).*X(:,3).^2 ...
X(:,1).^2.*X(:,3).^2 ...
X(:,2).*X(:,3).^2 ...
X(:,1).*X(:,2).*X(:,3).^2 ...
X(:,2).^2.*X(:,3).^2 ...
X(:,3).^3 ...
X(:,1).*X(:,3).^3 ...
X(:,2).*X(:,3).^3 ...
X(:,3).^4
];
nbmono=35;

if derprem
MatDX=cell(1,size(X,2));

MatDX{1}=[
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
2.*X(:,1) ...
3.*X(:,1).^2 ...
4.*X(:,1).^3 ...
zeros(size(X,1),1) ...
X(:,2) ...
2.*X(:,1).*X(:,2) ...
3.*X(:,1).^2.*X(:,2) ...
zeros(size(X,1),1) ...
X(:,2).^2 ...
2.*X(:,1).*X(:,2).^2 ...
zeros(size(X,1),1) ...
X(:,2).^3 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
X(:,3) ...
2.*X(:,1).*X(:,3) ...
3.*X(:,1).^2.*X(:,3) ...
zeros(size(X,1),1) ...
X(:,2).*X(:,3) ...
2.*X(:,1).*X(:,2).*X(:,3) ...
zeros(size(X,1),1) ...
X(:,2).^2.*X(:,3) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
X(:,3).^2 ...
2.*X(:,1).*X(:,3).^2 ...
zeros(size(X,1),1) ...
X(:,2).*X(:,3).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
X(:,3).^3 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
];

MatDX{2}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
X(:,1) ...
X(:,1).^2 ...
X(:,1).^3 ...
2.*X(:,2) ...
2.*X(:,1).*X(:,2) ...
2.*X(:,1).^2.*X(:,2) ...
3.*X(:,2).^2 ...
3.*X(:,1).*X(:,2).^2 ...
4.*X(:,2).^3 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
X(:,3) ...
X(:,1).*X(:,3) ...
X(:,1).^2.*X(:,3) ...
2.*X(:,2).*X(:,3) ...
2.*X(:,1).*X(:,2).*X(:,3) ...
3.*X(:,2).^2.*X(:,3) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
X(:,3).^2 ...
X(:,1).*X(:,3).^2 ...
2.*X(:,2).*X(:,3).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
X(:,3).^3 ...
zeros(size(X,1),1) ...
];

MatDX{3}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
X(:,1) ...
X(:,1).^2 ...
X(:,1).^3 ...
X(:,2) ...
X(:,1).*X(:,2) ...
X(:,1).^2.*X(:,2) ...
X(:,2).^2 ...
X(:,1).*X(:,2).^2 ...
X(:,2).^3 ...
2.*X(:,3) ...
2.*X(:,1).*X(:,3) ...
2.*X(:,1).^2.*X(:,3) ...
2.*X(:,2).*X(:,3) ...
2.*X(:,1).*X(:,2).*X(:,3) ...
2.*X(:,2).^2.*X(:,3) ...
3.*X(:,3).^2 ...
3.*X(:,1).*X(:,3).^2 ...
3.*X(:,2).*X(:,3).^2 ...
4.*X(:,3).^3
];

CoefDX=[
0 1 2 3 4 0 1 2 3 0 1 2 0 1 0 0 1 2 3 0 1 2 0 1 0 0 1 2 0 1 0 0 1 0 0 
0 0 0 0 0 1 1 1 1 2 2 2 3 3 4 0 0 0 0 1 1 1 2 2 3 0 0 0 1 1 2 0 0 1 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 3 3 3 4 
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
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2) ...
6.*X(:,1).*X(:,2) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,3) ...
6.*X(:,1).*X(:,3) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2).*X(:,3) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,3).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
];

MatDDX{2}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
2.*X(:,1) ...
3.*X(:,1).^2 ...
zeros(size(X,1),1) ...
2.*X(:,2) ...
4.*X(:,1).*X(:,2) ...
zeros(size(X,1),1) ...
3.*X(:,2).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
X(:,3) ...
2.*X(:,1).*X(:,3) ...
zeros(size(X,1),1) ...
2.*X(:,2).*X(:,3) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
X(:,3).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
];

MatDDX{3}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
2.*X(:,1) ...
3.*X(:,1).^2 ...
zeros(size(X,1),1) ...
X(:,2) ...
2.*X(:,1).*X(:,2) ...
zeros(size(X,1),1) ...
X(:,2).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,3) ...
4.*X(:,1).*X(:,3) ...
zeros(size(X,1),1) ...
2.*X(:,2).*X(:,3) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
3.*X(:,3).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
];

MatDDX{4}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
2.*X(:,1) ...
3.*X(:,1).^2 ...
zeros(size(X,1),1) ...
2.*X(:,2) ...
4.*X(:,1).*X(:,2) ...
zeros(size(X,1),1) ...
3.*X(:,2).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
X(:,3) ...
2.*X(:,1).*X(:,3) ...
zeros(size(X,1),1) ...
2.*X(:,2).*X(:,3) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
X(:,3).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
];

MatDDX{5}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*ones(size(X,1),1) ...
2.*X(:,1) ...
2.*X(:,1).^2 ...
6.*X(:,2) ...
6.*X(:,1).*X(:,2) ...
12.*X(:,2).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,3) ...
2.*X(:,1).*X(:,3) ...
6.*X(:,2).*X(:,3) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,3).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
];

MatDDX{6}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
X(:,1) ...
X(:,1).^2 ...
2.*X(:,2) ...
2.*X(:,1).*X(:,2) ...
3.*X(:,2).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,3) ...
2.*X(:,1).*X(:,3) ...
4.*X(:,2).*X(:,3) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
3.*X(:,3).^2 ...
zeros(size(X,1),1) ...
];

MatDDX{7}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
2.*X(:,1) ...
3.*X(:,1).^2 ...
zeros(size(X,1),1) ...
X(:,2) ...
2.*X(:,1).*X(:,2) ...
zeros(size(X,1),1) ...
X(:,2).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,3) ...
4.*X(:,1).*X(:,3) ...
zeros(size(X,1),1) ...
2.*X(:,2).*X(:,3) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
3.*X(:,3).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
];

MatDDX{8}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
X(:,1) ...
X(:,1).^2 ...
2.*X(:,2) ...
2.*X(:,1).*X(:,2) ...
3.*X(:,2).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,3) ...
2.*X(:,1).*X(:,3) ...
4.*X(:,2).*X(:,3) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
3.*X(:,3).^2 ...
zeros(size(X,1),1) ...
];

MatDDX{9}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*ones(size(X,1),1) ...
2.*X(:,1) ...
2.*X(:,1).^2 ...
2.*X(:,2) ...
2.*X(:,1).*X(:,2) ...
2.*X(:,2).^2 ...
6.*X(:,3) ...
6.*X(:,1).*X(:,3) ...
6.*X(:,2).*X(:,3) ...
12.*X(:,3).^2
];

CoefDDX=[
0 0 2 6 12 0 0 2 6 0 0 2 0 0 0 0 0 2 6 0 0 2 0 0 0 0 0 2 0 0 0 0 0 0 0 
0 0 0 0 0 0 1 2 3 0 2 4 0 3 0 0 0 0 0 0 1 2 0 2 0 0 0 0 0 1 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 2 3 0 1 2 0 1 0 0 2 4 0 2 0 0 3 0 0 
0 0 0 0 0 0 1 2 3 0 2 4 0 3 0 0 0 0 0 0 1 2 0 2 0 0 0 0 0 1 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 2 2 2 6 6 12 0 0 0 0 0 0 0 2 2 6 0 0 0 0 0 2 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 2 2 3 0 0 0 2 2 4 0 0 3 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 2 3 0 1 2 0 1 0 0 2 4 0 2 0 0 3 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 2 2 3 0 0 0 2 2 4 0 0 3 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 2 2 2 2 2 6 6 6 12 
];
end

end

