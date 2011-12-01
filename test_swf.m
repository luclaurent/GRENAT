%% Test SWF
clear all
para=5.11;

trac=linspace(0,10,100);
ev_trac=fct_manu(trac);

doe=linspace(0.1,9.8,5);doe=doe';%[0.2 1 3.2 5 8 9.5]';
[ev_doe,dev_doe]=fct_manu(doe);
app_t=zeros(size(trac));appd_t=app_t;
supp=zeros(size(trac,1),length(doe));suppm=supp;suppdm=supp;
vec_para=linspace(0.1,50,200);
err=zeros(size(vec_para));ec=err;
for ii=1:length(vec_para)
    [err(ii)]=loo_swf(doe,ev_doe,vec_para(ii));
    for ll=1:length(trac)
        %[W,Wm,dW,dWm]=fct_swf(trac(ii),doe,para);
        for jj=1:length(doe)
            ecart(jj)=abs(trac(ll)-doe(jj));
            dist=vec_para(ii)-ecart(jj);            
            fposi(jj)=0.5*(dist+abs(dist));            
            W(jj)=(fposi(jj)/(vec_para(ii)*ecart(jj)))^2;
        end
                Wm=fposi.^2./(ecart.^2.*sum(fposi.^2./ecart.^2));%W/sum(W);
        Wm=Wm';
        app_t(ll)=Wm'*ev_doe;
    end    
        ec(ii)=norm(app_t-ev_trac);
    
end
figure
plot(vec_para,err)
title('err CV')
figure
plot(vec_para,ec)
title('dist reelle')

for ii=1:length(trac)
    %[W,Wm,dW,dWm]=fct_swf(trac(ii),doe,para);
    for jj=1:length(doe)
        ecart(jj)=abs(trac(ii)-doe(jj));
        dist=para-ecart(jj);
        dist
        fposi(jj)=0.5*(dist+abs(dist));
        fposi
        W(jj)=(fposi(jj)/(para*ecart(jj)))^2;
        W(jj)
    end
    W
    Wm=fposi.^2./(ecart.^2.*sum(fposi.^2./ecart.^2));%W/sum(W);
    Wm=Wm';
    app_t(ii)=Wm'*ev_doe;
    %appd_t(ii)=dWm'*ev_doe;
    supp(ii,:)=W;
    suppm(ii,:)=Wm;
    %suppdm(ii,:)=dWm;
end


figure
plot(trac,ev_trac,'b')
hold on
plot(doe,ev_doe,'ro')
plot(trac,app_t,'k');
%plot(trac,appd_t,'m');
hold off

figure
hold on
plot(trac,supp(:,1),'b')
plot(trac,supp(:,2),'r')
plot(trac,supp(:,3),'k')
hold off

figure
hold on
plot(trac,suppm(:,1),'b')
plot(trac,suppm(:,2),'r')
plot(trac,suppm(:,3),'k')
hold off

% figure
% hold on
% plot(trac,suppdm(:,1),'b')
% plot(trac,suppdm(:,2),'r')
% plot(trac,suppdm(:,3),'k')
% hold off

