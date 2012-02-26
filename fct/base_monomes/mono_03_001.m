function [mono,nbmono,monod1,cmonod1,monod2,cmonod2]=mono_03_001()

derprem=false;dersecond=false;
if nargout>=4;derprem=true;end
if nargout==6;dersecond=true;end

mono=[
0 1 2 3 
];
nbmono=4;

if derprem
monod1=[
0 0 1 2 
];
cmonod1=[
0 1 2 3 
];
end

if dersecond
monod2=[
0 0 0 1 
];
cmonod2=[
0 1 2 3 
];
end

end

