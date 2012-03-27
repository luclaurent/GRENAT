function [MatX,nbmono,MatDX,CoefDX,MatDDX,CoefDDX]=mono_01_001(X)

derprem=false;dersecond=false;
if nargout>=4;derprem=true;end
if nargout==6;dersecond=true;end

MatX=[
 ones(size(X,1),1) ...
X(:,1)
];
nbmono=2;

if derprem
MatDX=cell(1,size(X,2));

MatDX{1}=[
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
];

CoefDX=[
0 1 
];
end

if dersecond
MatDDX=cell(size(X,2),size(X,2));

MatDDX{1}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
];

CoefDDX=[
0 0 
];
end

end

