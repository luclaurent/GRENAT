function err=loo_swf(tirages,eval,para)

rep=zeros(size(eval));
for ii=1:length(tirages)
    ev=eval([1:ii-1 ii+1:end]);
    tir=tirages([1:ii-1 ii+1:end]);
    [W,Wm]=fct_swf(eval(ii),tir,para);
    rep(ii)=Wm'*ev;
    
end

err=norm(eval-rep);

