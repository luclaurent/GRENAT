function [MatX,nbmono,MatDX,CoefDX,MatDDX,CoefDDX]=mono_01_001(X)

derprem=false;dersecond=false;
if nargout>=4;derprem=true;end
if nargout==6;dersecond=true;end

nb_val=size(X,1);
 nb_var=size(X,2);

Vones=ones(nb_val,1);
Vzeros=zeros(nb_val,1);

MatX=[
 Vones ...
X(:,1)
];
nbmono=2;

if derprem
MatDX=cell(1,nb_var);

MatDX{1}=[
Vzeros ...
Vones ...
];

CoefDX=[
0 1 
];
end

if dersecond
MatDDX=cell(nb_var,nb_var);

MatDDX{1}=[
Vzeros ...
Vzeros ...
];

CoefDDX=[
0 0 
];
end

end

