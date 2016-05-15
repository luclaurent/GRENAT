function [MatX,nbmono,MatDX,CoefDX,MatDDX,CoefDDX]=mono_02_017(X)

derprem=false;dersecond=false;
if nargout>=4;derprem=true;end
if nargout==6;dersecond=true;end

MatX=[
];
nbmono=0;

if derprem
MatDX=cell(1,size(X,2));

MatDX{1}=[
