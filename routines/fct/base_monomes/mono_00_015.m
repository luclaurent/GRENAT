function [MatX,nbmono,MatDX,CoefDX,MatDDX,CoefDDX]=mono_00_015(X)

derprem=false;dersecond=false;
if nargout>=4;derprem=true;end
if nargout==6;dersecond=true;end

nb_val=size(X,1);
nb_var=size(X,2);

MatX=ones(nb_val,1);
nbmono=1;

if derprem
MatDX=cell(1,nb_var);

for ii=1:nb_var
    MatDX{ii}=zeros(nb_val,1);
end

CoefDX=zeros(1,nb_var);

end

if dersecond
MatDDX=cell(nb_var,nb_var);

for ii=1:nb_var^2
    MatDDX{ii}=zeros(nb_val,1);
end

CoefDDX=zeros(1,nb_var);
end

end

