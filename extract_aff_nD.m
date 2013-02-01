%affichage extraction

aff.newfig=true;
aff.d3=true;
aff.d2=false;
aff.contour3=true;
aff.pts=true;
aff.grad_eval=false;
aff.grad_meta=false;
aff.contour2=false;
affichage(grid_XY,K,tirages,eval,grad,aff);

if doe.dim_pb==1&&(strcmp(meta.type,'KRG')||strcmp(meta.type,'InKRG')||strcmp(meta.type,'CKRG'))
    
    figure
    plot(grid_XY,K.var,'r')
    legend('variance');
    figure
    plot(grid_XY,K.Z,'r')
    hold on
    plot(grid_XY,K.Z_sto,'b')
    plot(grid_XY,K.Z_reg,'--b')
    plot(tirages,eval,'ok')
    plot(grid_XY,Z.Z,'k')
    legend('approx','STO','REG','sample responses','eval','Location','EastOutside')
    hold off
    figure
    plot(grid_XY,K.GZ,'r')
    hold on
    plot(grid_XY,K.GZ_sto,'b')
    plot(grid_XY,K.GZ_reg,'--b')
    plot(tirages,grad,'ok')
    plot(grid_XY,Z.GZ,'k')
    legend('G approx','G STO','G REG','sample grad','grad','Location','EastOutside')
end
if doe.dim_pb==1&&isfield(K,'wei')&&isfield(K,'ei')&&isfield(K,'lcb')&&isfield(K,'gei')
    xmin=min(grid_XY(:));
    xmax=max(grid_XY(:));
    figure
    subplot(5,1,1)
    plot(grid_XY,K.Z,'r')
    hold on
    plot(tirages,eval,'ok')
    plot(grid_XY,Z.Z,'k')
    xlim([xmin xmax])
    legend('approx','sample resp.','eval','Location','EastOutside')
    hold off
    subplot(5,1,2)
    [AX,H1,H2]=plotyy(grid_XY,K.var,grid_XY,K.lcb);
    set(H1,'Color','b')
    set(H2,'LineStyle','--','Color','k')
    legend('var','LCB','Location','EastOutside')
    set(AX,'xlim',[xmin xmax])
    hold off
    subplot(5,1,3)
    plot(grid_XY,K.explor_EI,'r')
    hold on
    plot(grid_XY,K.exploit_EI,'b')
    hold off
    hold on
    plot(grid_XY,K.ei,'b')
    hold off
    xlim([xmin xmax])
    legend('Explor','Exploit','EI','Location','EastOutside')
    subplot(5,1,4)
    clear txt_legend
    txt_legend{1}=['WEI ' num2str(meta.enrich.para_wei(1),'%4.2f')];
    type={'b','r','k','--b','--r','--k','-.b','-.r','-.k','--g','--m'};
    normer=false;
    for ii=1:size(K.wei,3)
        data=K.wei(:,:,ii);
        if normer            
            Dmax=max(data(:));
            Dmin=min(data(:));
            a=1/(Dmax-Dmin);
            b=-Dmin*a;
        else
            b=0;a=1;
        end
        plot(grid_XY,a*data+b,type{ii})
        if ii>1
            txt_legend={txt_legend{1:end},['WEI ' num2str(meta.enrich.para_wei(ii),'%4.2f')]};
        end
        hold on
    end
    xlim([xmin xmax])
    legend(txt_legend,'Location','EastOutside')
    
    %[~,H1,H2]=plotyy(grid_XY,K.wei,grid_XY,K.ei);
    %set(H1,'Color','b')
    %set(H2,'LineStyle','--','Color','k')
    %legend('EI','WEI','Location','EastOutside')
    subplot(5,1,5)
    clear txt_legend
    txt_legend{1}='GEI 0';
    type={'b','r','k','--b','--r','--k','-.b','-.r','.k'};
    normer=true;
    for ii=1:size(K.gei,3)
        data=K.gei(:,:,ii);
        if normer            
            Dmax=max(data(:));
            Dmin=min(data(:));
            a=1/(Dmax-Dmin);
            b=-Dmin*a;
        else
            b=0;a=1;
        end
        plot(grid_XY,a*data+b,type{ii})
        if ii>1
            txt_legend={txt_legend{1:end},['GEI ' num2str(ii-1)]};
        end
        hold on
    end
    xlim([xmin xmax])
    legend(txt_legend,'Location','EastOutside')
    title('Donnees normalisees')
    hold off
end
if doe.dim_pb==2&&(strcmp(meta.type,'KRG')||strcmp(meta.type,'CKRG'))
    %%
    figure
    surf(grid_XY(:,:,1),grid_XY(:,:,2),K.var)
    title('variance')
    %%
    figure
    subplot(2,2,1)
    surf(grid_XY(:,:,1),grid_XY(:,:,2),K.Z)
    hold on
    plot3(tirages(:,1),tirages(:,2),eval,'ok')
    hold off
    title('approx')
    subplot(2,2,2)
    surf(grid_XY(:,:,1),grid_XY(:,:,2),K.Z_sto)
    hold on
    plot3(tirages(:,1),tirages(:,2),eval,'ok')
    hold off
    title('STO')
    subplot(2,2,3)
    surf(grid_XY(:,:,1),grid_XY(:,:,2),K.Z_reg)
    hold on
    plot3(tirages(:,1),tirages(:,2),eval,'ok')
    hold off
    title('REG')
    subplot(2,2,4)
    surf(grid_XY(:,:,1),grid_XY(:,:,2),Z.Z)
    hold on
    plot3(tirages(:,1),tirages(:,2),eval,'ok')
    hold off
    title('eval')
    hold off
    %%
    figure
    subplot(4,2,1)
    surf(grid_XY(:,:,1),grid_XY(:,:,2),K.GZ(:,:,1))
    hold on
    plot3(tirages(:,1),tirages(:,2),grad(:,1),'ok')
    hold off
    title('GX approx')
    subplot(4,2,2)
    surf(grid_XY(:,:,1),grid_XY(:,:,2),K.GZ(:,:,2))
    hold on
    plot3(tirages(:,1),tirages(:,2),grad(:,2),'ok')
    hold off
    title('GY approx')
    %%
    subplot(4,2,3)
    surf(grid_XY(:,:,1),grid_XY(:,:,2),K.GZ_sto(:,:,1))
    hold on
    plot3(tirages(:,1),tirages(:,2),grad(:,1),'ok')
    hold off
    title('GY STO')
    subplot(4,2,4)
    surf(grid_XY(:,:,1),grid_XY(:,:,2),K.GZ_sto(:,:,2))
    hold on
    plot3(tirages(:,1),tirages(:,2),grad(:,2),'ok')
    hold off
    title('GX STO')
    %%
    subplot(4,2,5)
    surf(grid_XY(:,:,1),grid_XY(:,:,2),K.GZ_reg(:,:,1))
    hold on
    plot3(tirages(:,1),tirages(:,2),grad(:,1),'ok')
    hold off
    title('GX REG')
    subplot(4,2,6)
    surf(grid_XY(:,:,1),grid_XY(:,:,2),K.GZ_reg(:,:,2))
    hold on
    plot3(tirages(:,1),tirages(:,2),grad(:,2),'ok')
    hold off
    title('GY REG')
    %%
    subplot(4,2,7)
    surf(grid_XY(:,:,1),grid_XY(:,:,2),Z.GZ(:,:,1))
    hold on
    plot3(tirages(:,1),tirages(:,2),grad(:,1),'ok')
    hold off
    title('GX eval')
    hold off
    subplot(4,2,8)
    surf(grid_XY(:,:,1),grid_XY(:,:,2),Z.GZ(:,:,2))
    hold on
    plot3(tirages(:,1),tirages(:,2),grad(:,2),'ok')
    hold off
    title('GX eval')
    hold off
    
end