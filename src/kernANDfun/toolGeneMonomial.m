%% Build MATLAB's functions of monomial basis (depending on the order and the number of variables)
% L.LAURENT -- 25/02/2012 -- luc.laurent@lecnam.net

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

function toolGeneMonomial(polyOrder,nbVar)

if nargin<2
    % order
    orderMin=7;
    orderMax=10;
    % nb of variables
    npMin=7;
    npMax=8;
else
    orderMin=polyOrder;
    orderMax=polyOrder;
    npMin=nbVar;
    npMax=nbVar;
end
%path of the function
nameFun=mfilename;
nameFunFull=mfilename('fullpath');
dirFun=strrep(nameFunFull,nameFun,'');

%directory of storage
dirMB=fullfile(dirFun,'monomial_basis');
if exist(dirMB,'dir')~=7
    unix(['mkdir ' dirMB])
end

%fichier de stockage
file='mono';
ext='.m';

%stockage
mono1=cell(orderMax,npMax);
monod1=mono1;
monod2=mono1;
cmonod1=mono1;
cmonod2=mono1;
%matlabpool(8)
listOrder=orderMin:orderMax;

for itD=1:numel(listOrder)
    for nbv=npMin:npMax
        deg=listOrder(itD);
        fprintf('deg = %i  dim = %i\n',deg,nbv)
        %valeurs pour chaques variables
        val_var=cell(nbv,1);
        for ii=1:nbv
            val_var{ii}=uint8(0:deg);
            
        end
        nb_tir=(deg+1)*ones(1,nbv);
        
        % generation de la matrice des tirages
        % parcours des variables
        
        for ii=1:nbv
            if ii>1
                nb_ter_pre=prod(nb_tir(1:ii-1));
            else
                nb_ter_pre=1;
            end
            %parcours des valeurs par variables
            temp1=[];
            for jj=1:length(val_var{ii})
                temp=repmat(val_var{ii}(jj),nb_ter_pre,1);
                temp1=uint8([temp1;temp]);
                clear  temp
            end
            temp2=repmat(temp1,prod(nb_tir(ii+1:end)),1);
            clear temp1 temp
            combinaison(:,ii)=temp2;
            clear temp2
        end
        combinaison=uint8(combinaison);
        
        % g�n�ration combinaison
        %levels=(deg+1)*ones(1,nbv,'uint8');
        %combinaison=sparse(fullfact(levels)-1);
        %suppression ligne td sum term>deg
        %ind=[];
        
        %parfor cc=1:size(combinaison,1)
        %    if sum(combinaison(cc,:))>deg
        %        ind=[ind cc];
        %    end
        %end
        [ind]=find(sum(combinaison,2)<=deg);
        ind=ind';
        monomes_pow=combinaison(ind,:);
        
        clear combinaison
        %puissance monomes
        
        %monomes_pow(ind,:)=[];
        nbMono=size(monomes_pow,1);
        clear ind
        %coef deriv�es premi�re et monomes d�riv�es premi�res
        coef_der1=monomes_pow;
        monomes_der1=repmat(monomes_pow,1,nbv);
        for pp=1:nbv
            monomes_der1(:,(pp-1)*nbv+pp)=monomes_der1(:,(pp-1)*nbv+pp)-1;
        end
        %cancel zeros terms due to coefficients equal to zeros
        IXc=repmat(1:nbv,nbv,1);
        coeftmp=coef_der1(:,IXc(:)');
        monomes_der1(coeftmp==0)=0;
        %for cc=1:numel(monomes_der1)
        %    if monomes_der1(cc)<0
        %        monomes_der1(cc)=0;
        %    end
        %end
        %[ind]=find(monomes_der1<0);
        %monomes_der1(ind)=0;
        clear ind
        %coef deriv�es secondes et monomes d�riv�es secondes
        tt=[];
        for hh=1:size(coef_der1,2)
            tt=[tt repmat(coef_der1(:,hh),1,nbv)];
        end
        %                 tt
        %         tmp=repmat(tt,1,nbv);
        %         tmp
        %         tmp=reshape(tmp,nbMono,nbv*nbv);
        %         tmp
        %         monomes_der1
        coef_der2=monomes_der1.*tt;
        monomes_der2=int8(repmat(monomes_der1,1,nbv));
        for pp=1:nbv
            for oo=1:nbv
                indd=(oo-1)*nbv+(pp-1)*nbv^2+pp;
                monomes_der2(:,indd)=monomes_der2(:,indd)-1;
                
            end
        end
        %coef_der2=reshape(monomes_der2,,nbv)
        for cc=1:numel(monomes_der2)
            if monomes_der2(cc)<0
                monomes_der2(cc)=0;
            end
        end
        %cancel zeros terms due to coefficients equal to zeros
        IXc=repmat(1:nbv^2,nbv,1);
        coeftmp=coef_der2(:,IXc(:)');
        monomes_der2(coeftmp==0)=0;
        %[ind]=find(monomes_der2<0);
        %monomes_der2(ind)=0;
        clear ind
        %sauvegarde r�sultats
        mono1{itD,nbv}=monomes_pow;
        monod1{itD,nbv}=monomes_der1;
        monod2{itD,nbv}=monomes_der2;
        cmonod1{itD,nbv}=coef_der1;
        cmonod2{itD,nbv}=coef_der2;
        clear combinaison comb_mod temp temp1 temp2 ind indd
        clear monomes_pow monomes_der1 monomes_der2 coef_der2 coef_der1
    end
end

%keyboard

%stockage des monomes
for itD=1:numel(listOrder)
    for jj=npMin:npMax
        
        fonction=[file '_' num2str(listOrder(itD),'%02i') '_' num2str(jj,'%03i')];
        fichier=[dirMB '/' fonction ext];
        fid=fopen(fichier,'w');
        fprintf(fid,'%s\n\n',['function [poly,polyD,polyDD]=' fonction '()']);
        fprintf(fid,'derprem=false;dersecond=false;\n');
        fprintf(fid,'if nargout>=2;derprem=true;end\n');
        fprintf(fid,'if nargout==3;dersecond=true;end\n\n');
        %fprintf(fid,'nb_val=size(X,1);\n nb_var=size(X,2);\n\n');
        %fprintf(fid,'Vones=ones(nb_val,1);\n');
        %fprintf(fid,'Vzeros=zeros(nb_val,1);\n\n');
        mat=mono1{itD,jj}';
        %balayage des puissances du monome et construction de la matrice
        %associ�e
        Smat=size(mat);
        fprintf(fid,'Xpow=[\n');
        fprintf(fid,[repmat('%i ',1,Smat(2)) '\n'],mat');
        fprintf(fid,'];\n');
        fprintf(fid,'poly.Xpow=reshape(Xpow'',[1,%i,%i]);\n',Smat(2),Smat(1));
        fprintf(fid,'Xcoef=[\n');
        fprintf(fid,[repmat('%i ',1,Smat(2)) '\n'],ones(Smat));
        fprintf(fid,'];\n');
        fprintf(fid,'poly.Xcoef=reshape(Xcoef,[1,%i,%i]);\n',Smat(2),Smat(1));
        fprintf(fid,'poly.nbMono=%i;\n\n',Smat(2));
        %keyboard
        %writing first derivatives
        matD=monod1{itD,jj}';
        matC=cmonod1{itD,jj}';
        fprintf(fid,'if derprem\n');
        fprintf(fid,'DXpow=[\n');
        fprintf(fid,[repmat('%i ',1,Smat(2)) '\n'],matD');
        fprintf(fid,'];\n');
        fprintf(fid,'polyD.Xpow=permute(reshape(DXpow'',%i,1,%i,%i),[2 1 3 4]);\n',Smat(2),Smat(1),Smat(1));
        %
        fprintf(fid,'DXcoef=[\n');
        fprintf(fid,[repmat('%i ',1,Smat(2)) '\n'],matC');
        fprintf(fid,'];\n');
        fprintf(fid,'polyD.Xcoef=reshape(DXcoef'',[1,%i,%i]);\n',Smat(2),Smat(1));
        fprintf(fid,'end\n\n');
        %keyboard
        %writing second derivatives
        matDD=monod2{itD,jj}';
        matCC=cmonod2{itD,jj}';
        fprintf(fid,'if dersecond\n');
        fprintf(fid,'DDXpow=[\n');
        fprintf(fid,[repmat('%i ',1,Smat(2)) '\n'],matDD');
        fprintf(fid,'];\n');
        fprintf(fid,'polyDD.Xpow=permute(reshape(DDXpow'',%i,1,%i,%i),[2 1 3 4]);\n',Smat(2),Smat(1),Smat(1)*Smat(1));
        %
        fprintf(fid,'DDXcoef=[\n');
        fprintf(fid,[repmat('%i ',1,Smat(2)) '\n'],matCC');
        fprintf(fid,'];\n');
        fprintf(fid,'polyDD.Xcoef=reshape(DDXcoef'',[1,%i,%i]);\n',Smat(2),Smat(1)^2);
        fprintf(fid,'end\n\n');
        fprintf(fid,'end\n\n');
        %keyboard
        %
        fclose(fid);
    end    
end
end
