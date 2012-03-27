%% procédure de test de la régression polynomiale
init_rep;
close all
dim=1;
poly=4;
doe.bornes=[-5 5];
doe.type='LHS';
doe.nb_samples=10;
doe.aff=false;

tirages=gene_doe(doe);
grille=linspace(doe.bornes(1),doe.bornes(2),30);
[ev,dev]=fct_manu(tirages);
[gev,gdev]=fct_manu(grille);

[M]=reg_polyN(tirages,poly);
%feval(['reg_poly' num2str(poly)],tirages);

coef=(M'*M)\M'*ev;

[EVREG]=reg_polyN(grille',poly);
%feval(['reg_poly' num2str(poly)],grille');

ev_app=EVREG*coef;
%dev_app=DEVREG*coef;

hold on
plot(tirages,ev,'ro')
plot(grille,gev,'b')
plot(grille,ev_app,'-k','LineWidth',2)
%plot(grille,dev_app,'-r','LineWidth',2)
hold off