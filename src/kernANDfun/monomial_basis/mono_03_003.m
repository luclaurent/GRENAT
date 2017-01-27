function [MatX,nbmono,MatDX,CoefDX,MatDDX,CoefDDX]=mono_03_003(X)

derprem=false;dersecond=false;
if nargout>=4;derprem=true;end
if nargout==6;dersecond=true;end

nb_val=size(X,1);
 nb_var=size(X,2);

Vones=ones(nb_val,1);
Vzeros=zeros(nb_val,1);

MatX=[
 Vones ...
X(:,1) ...
X(:,1).^2 ...
X(:,1).^3 ...
X(:,2) ...
X(:,1).*X(:,2) ...
X(:,1).^2.*X(:,2) ...
X(:,2).^2 ...
X(:,1).*X(:,2).^2 ...
X(:,2).^3 ...
X(:,3) ...
X(:,1).*X(:,3) ...
X(:,1).^2.*X(:,3) ...
X(:,2).*X(:,3) ...
X(:,1).*X(:,2).*X(:,3) ...
X(:,2).^2.*X(:,3) ...
X(:,3).^2 ...
X(:,1).*X(:,3).^2 ...
X(:,2).*X(:,3).^2 ...
X(:,3).^3
];
nbmono=20;

if derprem
MatDX=cell(1,nb_var);

MatDX{1}=[
Vzeros ...
Vones ...
2.*X(:,1) ...
3.*X(:,1).^2 ...
Vzeros ...
X(:,2) ...
2.*X(:,1).*X(:,2) ...
Vzeros ...
X(:,2).^2 ...
Vzeros ...
Vzeros ...
X(:,3) ...
2.*X(:,1).*X(:,3) ...
Vzeros ...
X(:,2).*X(:,3) ...
Vzeros ...
Vzeros ...
X(:,3).^2 ...
Vzeros ...
Vzeros ...
];

MatDX{2}=[
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vones ...
X(:,1) ...
X(:,1).^2 ...
2.*X(:,2) ...
2.*X(:,1).*X(:,2) ...
3.*X(:,2).^2 ...
Vzeros ...
Vzeros ...
Vzeros ...
X(:,3) ...
X(:,1).*X(:,3) ...
2.*X(:,2).*X(:,3) ...
Vzeros ...
Vzeros ...
X(:,3).^2 ...
Vzeros ...
];

MatDX{3}=[
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vones ...
X(:,1) ...
X(:,1).^2 ...
X(:,2) ...
X(:,1).*X(:,2) ...
X(:,2).^2 ...
2.*X(:,3) ...
2.*X(:,1).*X(:,3) ...
2.*X(:,2).*X(:,3) ...
3.*X(:,3).^2
];

CoefDX=[
0 1 2 3 0 1 2 0 1 0 0 1 2 0 1 0 0 1 0 0 
0 0 0 0 1 1 1 2 2 3 0 0 0 1 1 2 0 0 1 0 
0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 2 2 2 3 
];
end

if dersecond
MatDDX=cell(nb_var,nb_var);

MatDDX{1}=[
Vzeros ...
Vzeros ...
2.*Vones ...
6.*X(:,1) ...
Vzeros ...
Vzeros ...
2.*X(:,2) ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
2.*X(:,3) ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
];

MatDDX{2}=[
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vones ...
2.*X(:,1) ...
Vzeros ...
2.*X(:,2) ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
X(:,3) ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
];

MatDDX{3}=[
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vones ...
2.*X(:,1) ...
Vzeros ...
X(:,2) ...
Vzeros ...
Vzeros ...
2.*X(:,3) ...
Vzeros ...
Vzeros ...
];

MatDDX{4}=[
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vones ...
2.*X(:,1) ...
Vzeros ...
2.*X(:,2) ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
X(:,3) ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
];

MatDDX{5}=[
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
2.*Vones ...
2.*X(:,1) ...
6.*X(:,2) ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
2.*X(:,3) ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
];

MatDDX{6}=[
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vones ...
X(:,1) ...
2.*X(:,2) ...
Vzeros ...
Vzeros ...
2.*X(:,3) ...
Vzeros ...
];

MatDDX{7}=[
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vones ...
2.*X(:,1) ...
Vzeros ...
X(:,2) ...
Vzeros ...
Vzeros ...
2.*X(:,3) ...
Vzeros ...
Vzeros ...
];

MatDDX{8}=[
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vones ...
X(:,1) ...
2.*X(:,2) ...
Vzeros ...
Vzeros ...
2.*X(:,3) ...
Vzeros ...
];

MatDDX{9}=[
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
Vzeros ...
2.*Vones ...
2.*X(:,1) ...
2.*X(:,2) ...
6.*X(:,3)
];

CoefDDX=[
0 0 2 6 0 0 2 0 0 0 0 0 2 0 0 0 0 0 0 0 
0 0 0 0 0 1 2 0 2 0 0 0 0 0 1 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 1 2 0 1 0 0 2 0 0 
0 0 0 0 0 1 2 0 2 0 0 0 0 0 1 0 0 0 0 0 
0 0 0 0 0 0 0 2 2 6 0 0 0 0 0 2 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 2 0 0 2 0 
0 0 0 0 0 0 0 0 0 0 0 1 2 0 1 0 0 2 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 2 0 0 2 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 2 2 6 
];
end

end

