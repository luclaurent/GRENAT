%% etude calcul gradient par différences finies
%% 04/07/2012


%fonction prise en compte
fun='fct_manu';
%point etudié
pt=3;
%pas difference finie
diff_pas=0.1;

%calcul dérivée
% exacte:
[Z_ex,GZ_ex,~,GGZ_ex]=feval(fun,pt);
%différences finies
%ordre 1
pt_AV=pt+diff_pas;
pt_AR=pt-diff_pas;
Z_AV=feval(fun,pt_AV);
Z_AR=feval(fun,pt_AR);
%ordre 2
pt_AV2=pt+diff_pas/2;
pt_AR2=pt-diff_pas/2;
Z_AV2=feval(fun,pt_AV2);
Z_AR2=feval(fun,pt_AR2);

%calcul grad
GZ_AV=(Z_AV-Z_ex)/diff_pas;
GZ_AR=-(Z_AR-Z_ex)/diff_pas;
GZ_2=(Z_AV2-Z_AR2)/diff_pas;

%calcul des erreurs
err_AV=abs(GZ_AV-GZ_ex)/abs(GZ_ex);
err_AR=abs(GZ_AR-GZ_ex)/abs(GZ_ex);
err_2=abs(GZ_2-GZ_ex)/abs(GZ_ex);

fprintf('Exacte: %4.2f\n',GZ_ex)
fprintf('AV: %4.2f erreur: %4.2f\n',GZ_AV,err_AV)
fprintf('AR: %4.2f erreur: %4.2f\n',GZ_AR,err_AR)
fprintf('2: %4.2f erreur: %4.2f\n',GZ_2,err_2)

%% etude fine +  plot

pas=logspace(-20,0,1e4);
for ii=1:numel(pas)
    diff_pas=pas(ii);
    %calcul dérivée
    % exacte:
    [Z_ex,GZ_ex]=feval(fun,pt);
    %différences finies
    %ordre 1
    pt_AV=pt+diff_pas;
    pt_AR=pt-diff_pas;
    Z_AV=feval(fun,pt_AV);
    Z_AR=feval(fun,pt_AR);
    %ordre 2
    pt_AV2=pt+diff_pas/2;
    pt_AR2=pt-diff_pas/2;
    Z_AV2=feval(fun,pt_AV2);
    Z_AR2=feval(fun,pt_AR2);
    
    GZ_AV=(Z_AV-Z_ex)/diff_pas;
    GZ_AR=-(Z_AR-Z_ex)/diff_pas;
    GZ_2=(Z_AV2-Z_AR2)/diff_pas;
    %calcul des erreurs
    err_AV(ii)=abs(GZ_AV-GZ_ex)/abs(GZ_ex);
    err_AR(ii)=abs(GZ_AR-GZ_ex)/abs(GZ_ex);
    err_2(ii)=abs(GZ_2-GZ_ex)/abs(GZ_ex);
    
    %erreur de troncature
    err_tronc(ii)=diff_pas*abs(GGZ_ex)/2;
    %erreur arrondi
    err_arr(ii)=2*abs(eps)/diff_pas;
    
end

figure;
type_plot='stairs';
feval(type_plot,pas,err_AV,'k');
set(gca,'Xscale','log')
set(gca,'Yscale','log')
hold on
feval(type_plot,pas,err_AR,'m');
set(gca,'Xscale','log')
set(gca,'Yscale','log')
feval(type_plot,pas,err_2,'b');
set(gca,'Xscale','log')
set(gca,'Yscale','log')
feval(type_plot,pas,err_tronc,'-.r');
set(gca,'Xscale','log')
set(gca,'Yscale','log')
feval(type_plot,pas,err_arr,'-.k');
set(gca,'Xscale','log')
set(gca,'Yscale','log')
legend('AV','AR','CD2','Err tronc','Err arr')