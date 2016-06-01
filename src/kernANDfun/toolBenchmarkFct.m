% benchmark de test des fonctions de correlation (tps calcul)

%     GRENAT - GRadient ENhanced Approximation Toolbox 
%     A toolbox for generating and exploiting gradient-enhanced surrogate models
%     Copyright (C) 2016  Luc LAURENT <luc.laurent@lecnam.net>
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

clear all
close all

typef='corr_'; %'rf_' ou 'corr_'
fct='sexp';

fct_all=[typef fct];

%%nouvelle et ancienne version
new='_new';old='_old';
%points en 1D, 2D, 3D, 4D, 5D et 6D
pt{1}=0.1;
pt{2}=[0.1 -0.3];
pt{3}=[0.1 -0.3 0.6];
pt{4}=[0.1 -0.3 0.6 0.8];
pt{5}=[0.1 -0.3 0.6 0.8 -0.1];
pt{6}=[0.1 -0.3 0.6 0.8 -0.1 -0.4];
dim=6;
%nombre points
nb_pt=5000;
pas=50;
%parametre
para=0.9;
%borne verification
verif=1e-10;
bilan=true;
%affichage
aff=false;

stps_new=zeros(dim,length(1:pas:nb_pt),3);
stps_old=zeros(dim,length(1:pas:nb_pt),3);
sgain=zeros(dim,length(1:pas:nb_pt),3);
ite_j=1;
%balayage des possibilit�s
for ii=1:dim
    fprintf('============\n'),
    fprintf('Dimension %i\n',ii);
    ite_j=1;
    for jj=1:pas:nb_pt
        if aff;fprintf('nb de pts %i\n',jj);end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul reponse seule
        if aff;fprintf('>>Reponses seules\n');end
        tic
        rep_new=feval([fct_all new],repmat(pt{ii},jj,1),para);
        tps_new=toc;
        tic
        rep_old=feval([fct_all old],repmat(pt{ii},jj,1),para);
        tps_old=toc;
        gain=(tps_old-tps_new)/tps_old;
        stps_new(ii,ite_j,1)=tps_new;
        stps_old(ii,ite_j,1)=tps_old;
        sgain(ii,ite_j,1)=gain;
        etat_rep=all(abs(rep_new-rep_old)<verif);
        bilan=bilan&&etat_rep;
        if aff;
            fprintf('Reponses: ');if etat_rep;fprintf('OK\n');else fprintf('BUG\n');end 
        end
        if aff;fprintf('Temps: NEW [%4.2e s]// OLD [%4.2e s] || GAIN: %4.2e\n',tps_new,tps_old,gain);end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul reponse et derivees premieres
        if aff;fprintf('>>Reponses et derivees premieres\n');end
        tic
        [rep_new,drep_new]=feval([fct_all new],repmat(pt{ii},jj,1),para);
        tps_new=toc;
        tic
        [rep_old,drep_old]=feval([fct_all old],repmat(pt{ii},jj,1),para);
        tps_old=toc;
        gain=(tps_old-tps_new)/tps_old;
        stps_new(ii,ite_j,2)=tps_new;
        stps_old(ii,ite_j,2)=tps_old;
        sgain(ii,ite_j,2)=gain;
        etat_rep=all(abs(rep_new-rep_old)<verif);
        etat_drep=all(abs(drep_new(:)-drep_old(:))<verif);
        bilan=bilan&&etat_rep&&etat_drep;
        if aff;
            fprintf('Reponses: ');if etat_rep;fprintf('OK\n');else fprintf('BUG\n');end 
        end
        if aff;
            fprintf('Derivees 1eres: ');if etat_drep;fprintf('OK\n');else fprintf('BUG\n');end 
        end
        if aff;fprintf('Temps: NEW [%4.2e s]// OLD [%4.2e s] || GAIN: %4.2e\n',tps_new,tps_old,gain);end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %calcul reponse et derivees premieres et secondes
        if aff;fprintf('>>Reponses et derivees premieres et secondes\n');end
        tic
        [rep_new,drep_new,ddrep_new]=feval([fct_all new],repmat(pt{ii},jj,1),para);
        tps_new=toc;
        tic
        [rep_old,drep_old,ddrep_old]=feval([fct_all old],repmat(pt{ii},jj,1),para);
        tps_old=toc;
        gain=(tps_old-tps_new)/tps_old;
        stps_new(ii,ite_j,3)=tps_new;
        stps_old(ii,ite_j,3)=tps_old;
        sgain(ii,ite_j,3)=gain;
        etat_rep=all(abs(rep_new-rep_old)<verif);
        etat_drep=all(abs(drep_new(:)-drep_old(:))<verif);
        etat_ddrep=all(abs(ddrep_new(:)-ddrep_old(:))<verif);
        bilan=bilan&&etat_rep&&etat_drep&&etat_ddrep;
        if aff;
            fprintf('Reponses: ');if etat_rep;fprintf('OK\n');else fprintf('BUG\n');end 
        end
        if aff;
            fprintf('Derivees 1eres: ');if etat_drep;fprintf('OK\n');else fprintf('BUG\n');end 
        end
        if aff;
            fprintf('Derivees 2ndes: ');if etat_ddrep;fprintf('OK\n');else fprintf('BUG\n');end 
        end
        if aff;fprintf('Temps: NEW [%4.2e s]// OLD [%4.2e s] || GAIN: %4.2e\n',tps_new,tps_old,gain);end
        ite_j=ite_j+1;
       
    end
end
if bilan;fprintf('\n\n TOUT: OK\n');else fprintf('\n\n TOUT: BUG\n');end

%trac� graphs
figure
xx=1:pas:nb_pt;
for ii=1:dim
    subplot(2,3,ii)    
    semilogy(xx,stps_new(ii,:,1),'b')
    hold on
    semilogy(xx,stps_old(ii,:,1),'r')
    hold on
    semilogy(xx,stps_new(ii,:,2),'--b')
    hold on
    semilogy(xx,stps_old(ii,:,2),'--r')
    hold on
    semilogy(xx,stps_new(ii,:,3),'.-b')
    hold on
    semilogy(xx,stps_old(ii,:,3),'.-r')
    legend('new R','old R','new R,D1','old R,D1','new R,D1,D2','old R,D1,D2')
    title(['Dim ' num2str(ii)]);
    
end
figure
for ii=1:dim
    subplot(2,3,ii)
    
    plot(xx,sgain(ii,:,1),'k')
    hold on
    plot(xx,sgain(ii,:,2),'r')
    hold on
    plot(xx,sgain(ii,:,3),'b')
    legend('R','R,D1','R,D1,D2')
    title(['Dim ' num2str(ii)]);
end
