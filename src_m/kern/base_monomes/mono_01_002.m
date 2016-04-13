function [MatX,nbmono,MatDX,CoefDX,MatDDX,CoefDDX]=mono_01_002(X)

derprem=false;dersecond=false;
if nargout>=4;derprem=true;end
if nargout==6;dersecond=true;end

MatX=[
 ones(size(X,1),1) ...
X(:,1) ...
X(:,2)
];
nbmono=3;

if derprem
MatDX=cell(1,size(X,2));

MatDX{1}=[
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
zeros(size(X,1),1) ...
];

MatDX{2}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
];

CoefDX=[
0 1 0 
0 0 1 
];
end

if dersecond
MatDDX=cell(size(X,2),size(X,2));

MatDDX{1}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
];

MatDDX{2}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
];

MatDDX{3}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
];

MatDDX{4}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
];

CoefDDX=[
0 0 0 
0 0 0 
0 0 0 
0 0 0 
];
end

end

