function [MatX,nbmono,MatDX,CoefDX,MatDDX,CoefDDX]=mono_04_001(X)

derprem=false;dersecond=false;
if nargout>=4;derprem=true;end
if nargout==6;dersecond=true;end

MatX=[
 ones(size(X,1),1) ...
X(:,1) ...
X(:,1).^2 ...
X(:,1).^3 ...
X(:,1).^4
];
nbmono=5;

if derprem
MatDX=cell(1,size(X,2));

MatDX{1}=[
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
2.*X(:,1) ...
3.*X(:,1).^2 ...
4.*X(:,1).^3
];

CoefDX=[
0 1 2 3 4 
];
end

if dersecond
MatDDX=cell(size(X,2),size(X,2));

MatDDX{1}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*ones(size(X,1),1) ...
6.*X(:,1) ...
12.*X(:,1).^2
];

CoefDDX=[
0 0 2 6 12 
];
end

end

