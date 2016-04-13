%% G�n�ration des monomes des polynomes (en fonction du degr� et du nb de variables)
% L.LAURENT -- 25/02/2012 -- luc.laurent@lecnam.net

clear all
% degr�
deg_min=2;
deg_max=2;
% nb variables
dim_min=5;
dim_max=5;

%dossier de stockage
doss='base_monomes';
if exist(doss,'dir')~=7
    unix(['mkdir ' doss])
end

%fichier de stockage
file='mono';
ext='.m';

%stockage
mono1=cell(deg_max,dim_max);
monod1=mono1;
monod2=mono1;
cmonod1=mono1;
cmonod2=mono1;
%matlabpool(8)
for deg=deg_min:deg_max
    for nbv=dim_min:dim_max
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
            end
            temp2=repmat(temp1,prod(nb_tir(ii+1:end)),1);
            clear temp1 temp
            combinaison(:,ii)=temp2;
            combinaison
            clear temp2;
        end
        combinaison=uint8(combinaison);
        
        % g�n�ration combinaison
        %levels=(deg+1)*ones(1,nbv,'uint8');
        %combinaison=sparse(fullfact(levels)-1);
        %suppression ligne td sum term>deg
        ind=[];
        
        parfor cc=1:size(combinaison,1)
            if sum(combinaison(cc,:))>deg
                ind=[ind cc];
            end
        end
        %[ind]=find(sum(combinaison,2)>deg);
        monomes_pow=combinaison;
        
        clear combinaison
        %puissance monomes
        
        monomes_pow(ind,:)=[];
        nbMono=size(monomes_pow,1);
        clear ind
        %coef deriv�es premi�re et monomes d�riv�es premi�res
        coef_der1=monomes_pow;
        monomes_der1=repmat(monomes_pow,1,nbv);
        for pp=1:nbv
            monomes_der1(:,(pp-1)*nbv+pp)=monomes_der1(:,(pp-1)*nbv+pp)-1;
        end
        
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
        parfor cc=1:numel(monomes_der2)
            if monomes_der2(cc)<0
                monomes_der2(cc)=0;
            end
        end
        %[ind]=find(monomes_der2<0);
        %monomes_der2(ind)=0;
        clear ind
        %sauvegarde r�sultats
        mono1{deg,nbv}=monomes_pow;
        monod1{deg,nbv}=monomes_der1;
        monod2{deg,nbv}=monomes_der2;
        cmonod1{deg,nbv}=coef_der1;
        cmonod2{deg,nbv}=coef_der2;
        clear combinaison comb_mod temp temp1 temp2 ind indd
        clear monomes_pow monomes_der1 monomes_der2 coef_der2 coef_der1
    end
end

% 
% %stockage des monomes
% for ii=deg_min:deg_max
%     for jj=dim_min:dim_max
%         fonction=[file '_' num2str(ii,'%02i') '_' num2str(jj,'%03i')];
%         fichier=[doss '/' fonction ext];
%         fid=fopen(fichier,'w');
%         fprintf(fid,'%s\n\n',['function [MatX,nbmono,MatDX,CoefDX,MatDDX,CoefDDX]=' fonction '(X)']);
%         fprintf(fid,'derprem=false;dersecond=false;\n');
%         fprintf(fid,'if nargout>=4;derprem=true;end\n');
%         fprintf(fid,'if nargout==6;dersecond=true;end\n\n');
%         fprintf(fid,'MatX=[\n');
%         mat=mono1{ii,jj};
%         %balayage des puissances du monome et construction de la matrice
%         %associ�e
%         indic=true;
%         for mm=1:size(mat,1)
%             if sum(mat(mm,:))==0
%                 fprintf(fid,' ones(size(X,1),1) ...\n');
%             else
%                 indic=false;
%                 for ll=1:size(mat(mm,:),2)
%                     if ll~=1
%                         if mat(mm,ll-1)~=0&&mat(mm,ll)~=0
%                             fprintf(fid,'.*');
%                         elseif mat(mm,ll)~=0&&indic
%                             fprintf(fid,'.*');
%                             indic=false;
%                         end
%                     end
%                     if mat(mm,ll)~=0
%                         if mat(mm,ll)~=1
%                             fprintf(fid,'X(:,%i).^%i',ll,mat(mm,ll));
%                         else
%                             fprintf(fid,'X(:,%i)',ll);
%                         end
%                         indic=true;
%                     end
%                 end
%                 if mm~=size(mat,1)
%                     fprintf(fid,' ...\n');
%                 else
%                     fprintf(fid,'\n');
%                 end
%             end
%         end
%         fprintf(fid,'];\n');
%         fprintf(fid,'nbmono=%i;\n\n',size(mat,1));
%         %ecriture d�riv�e premi�re
%         fprintf(fid,'if derprem\n');
%         fprintf(fid,'MatDX=cell(1,size(X,2));\n\n');
%         matD=monod1{ii,jj};
%         matC=cmonod1{ii,jj};
%         for nn=1:jj
%             fprintf(fid,'MatDX{%i}=[\n',nn);
%             mat=matD(:,[jj*(nn-1)+1:jj*nn]);
%             coef=matC(:,nn);
%             for mm=1:size(mat,1)
%                 if sum(mat(mm,:))==0&&coef(mm)~=0
%                     if coef(mm)~=1
%                         fprintf(fid,'%g.*',coef(mm));
%                         
%                     end
%                     fprintf(fid,'ones(size(X,1),1) ...\n');
%                 elseif coef(mm)==0
%                     fprintf(fid,'zeros(size(X,1),1) ...\n');
%                 else
%                     if coef(mm)~=1
%                         fprintf(fid,'%g.*',coef(mm));
%                     end
%                     
%                     indic=false;
%                     for ll=1:size(mat(mm,:),2)
%                         if ll~=1
%                             if mat(mm,ll-1)~=0&&mat(mm,ll)~=0
%                                 fprintf(fid,'.*');
%                             elseif mat(mm,ll)~=0&&indic
%                                 fprintf(fid,'.*');
%                                 indic=false;
%                             end
%                         end
%                         if mat(mm,ll)~=0
%                             if mat(mm,ll)~=1
%                                 fprintf(fid,'X(:,%i).^%i',ll,mat(mm,ll));
%                             else
%                                 fprintf(fid,'X(:,%i)',ll);
%                             end
%                             indic=true;
%                         end
%                     end
%                     if mm~=size(mat,1)
%                         fprintf(fid,' ...\n');
%                     else
%                         fprintf(fid,'\n');
%                     end
%                 end
%             end
%             fprintf(fid,'];\n\n');
%         end
%         
%         %ecriture coefficients d�riv�e premi�re
%         
%         fprintf(fid,'CoefDX=[\n');
%         mat=cmonod1{ii,jj}';
%         for ll=1:size(mat,1);
%             fprintf(fid,'%i ',mat(ll,:));
%             fprintf(fid,'\n');
%         end
%         fprintf(fid,'];\n');
%         %ecriture d�riv�e seconde
%         fprintf(fid,'end\n\n');
%         fprintf(fid,'if dersecond\n');
%         fprintf(fid,'MatDDX=cell(size(X,2),size(X,2));\n\n');
%         matDD=monod2{ii,jj};
%         matCC=cmonod2{ii,jj};
%         for nn=1:jj*jj
%             fprintf(fid,'MatDDX{%i}=[\n',nn);
%             mat=matDD(:,jj*(nn-1)+1:jj*nn);
%             coef=matCC(:,nn);
%             for mm=1:size(mat,1)
%                 if sum(mat(mm,:))==0&&coef(mm)~=0
%                     if coef(mm)~=1
%                         fprintf(fid,'%g.*',coef(mm));
%                         
%                     end
%                     fprintf(fid,'ones(size(X,1),1) ...\n');
%                 elseif coef(mm)==0||any(mat(mm,:)<0)
%                     fprintf(fid,'zeros(size(X,1),1) ...\n');
%                 else
%                     if coef(mm)~=1
%                         fprintf(fid,'%g.*',coef(mm));
%                     end
%                     
%                     indic=false;
%                     for ll=1:size(mat(mm,:),2)
%                         if ll~=1
%                             if mat(mm,ll-1)~=0&&mat(mm,ll)~=0
%                                 fprintf(fid,'.*');
%                             elseif mat(mm,ll)~=0&&indic
%                                 fprintf(fid,'.*');
%                                 indic=false;
%                             end
%                         end
%                         if mat(mm,ll)~=0
%                             if mat(mm,ll)~=1
%                                 fprintf(fid,'X(:,%i).^%i',ll,mat(mm,ll));
%                             else
%                                 fprintf(fid,'X(:,%i)',ll);
%                             end
%                             indic=true;
%                         end
%                     end
%                     if mm~=size(mat,1)
%                         fprintf(fid,' ...\n');
%                     else
%                         fprintf(fid,'\n');
%                     end
%                 end
%             end
%             fprintf(fid,'];\n\n');
%         end
%         %ecriture coefficients d�riv�e seconde
%         fprintf(fid,'CoefDDX=[\n');
%         mat=cmonod2{ii,jj}';
%         for ll=1:size(mat,1);
%             fprintf(fid,'%i ',mat(ll,:));
%             fprintf(fid,'\n');
%         end
%         fprintf(fid,'];\n');
%         %fprintf(fid,'cmonod2=cmonod2'';\n');
%         fprintf(fid,'end\n\n');
%         fprintf(fid,'end\n\n');
%         
%         fclose(fid);
%     end
%     
% end
