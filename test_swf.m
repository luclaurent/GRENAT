%% Test SWF

para=5;

trac=linspace(0,10,100);
ev_trac=fct_manu(trac);

doe=[0.2 1 3.2  6.5 7.5]';
ev_doe=fct_manu(doe);
app_t=zeros(size(trac));
supp=app_t;suppm=supp;
vec_para=linspace(0.1,50,200);
err=zeros(size(vec_para));
for ii=1:length(vec_para)
 err(ii)=loo_swf(doe,ev_doe,vec_para(ii));
end
figure
plot(vec_para,err)

for ii=1:length(trac)
    [W,Wm]=fct_swf(trac(ii),doe,para);
    app_t(ii)=Wm'*ev_doe;
    supp(ii)=W(3);
    suppm(ii)=Wm(3);
end


figure
plot(trac,ev_trac,'b')
hold on
plot(doe,ev_doe,'ro')
plot(trac,app_t,'k');
hold off

figure
%plot(trac,supp)
hold on
plot(trac,suppm,'r')
hold off