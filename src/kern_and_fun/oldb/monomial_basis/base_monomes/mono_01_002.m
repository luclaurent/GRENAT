function [MatX,nbmono,MatDX,CoefDX,MatDDX,CoefDDX]=mono_01_002(X)

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
X(:,2)
];
nbmono=3;

if derprem
MatDX=cell(1,nb_var);

MatDX{1}=[
Vzeros ...
Vones ...
Vzeros ...
];

MatDX{2}=[
Vzeros ...
Vzeros ...
Vones ...
];

CoefDX=[
0 1 0 
0 0 1 
];
end

if dersecond
MatDDX=cell(nb_var,nb_var);

MatDDX{1}=[
Vzeros ...
Vzeros ...
Vzeros ...
];

MatDDX{2}=[
Vzeros ...
Vzeros ...
Vzeros ...
];

MatDDX{3}=[
Vzeros ...
Vzeros ...
Vzeros ...
];

MatDDX{4}=[
Vzeros ...
Vzeros ...
Vzeros ...
];

CoefDDX=[
0 0 0 
0 0 0 
0 0 0 
0 0 0 
];
end

end

