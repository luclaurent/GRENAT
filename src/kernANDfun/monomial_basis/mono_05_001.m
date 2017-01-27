function [MatX,nbmono,MatDX,CoefDX,MatDDX,CoefDDX]=mono_05_001(X)

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
X(:,1).^4 ...
X(:,1).^5
];
nbmono=6;

if derprem
MatDX=cell(1,nb_var);

MatDX{1}=[
Vzeros ...
Vones ...
2.*X(:,1) ...
3.*X(:,1).^2 ...
4.*X(:,1).^3 ...
5.*X(:,1).^4
];

CoefDX=[
0 1 2 3 4 5 
];
end

if dersecond
MatDDX=cell(nb_var,nb_var);

MatDDX{1}=[
Vzeros ...
Vzeros ...
2.*Vones ...
6.*X(:,1) ...
12.*X(:,1).^2 ...
20.*X(:,1).^3
];

CoefDDX=[
0 0 2 6 12 20 
];
end

end

