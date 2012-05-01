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

if doe.dim_pb==1&&(strcmp(meta.type,'KRG')||strcmp(meta.type,'CKRG'))
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
    legend('approx','STO','REG','sample responses','eval')
    hold off
    figure
    plot(grid_XY,K.GZ,'r')
    hold on
    plot(grid_XY,K.GZ_sto,'b')
    plot(grid_XY,K.GZ_reg,'--b')
    plot(tirages,grad,'ok')
    plot(grid_XY,Z.GZ,'k')
    legend('G approx','G STO','G REG','sample grad','grad')
   
    if isfield(K,'wei')&&isfield(K,'ei')&&isfield(K,'lcb')
    figure
    subplot(3,1,1)
    plot(grid_XY,K.Z,'r')
    hold on
    plot(tirages,eval,'ok')
    plot(grid_XY,Z.Z,'k')
    legend('approx','eval','sample resp.')
    hold off
    subplot(3,1,2)
    plot(grid_XY,K.var,'b')
    hold on
    plot(grid_XY,K.lcb,'--k')
    legend('var','LCB')
    hold off
       subplot(3,1,3)
    plot(grid_XY,K.wei,'b')
    hold on
    plot(grid_XY,K.ei,'r')
    plot(grid_XY,K.explor,'--r')
    plot(grid_XY,K.exploit,'--b')
    hold off
    legend('WEI','EI','Explor','Exploit')
    end
elseif doe.dim_pb==2&&(strcmp(meta.type,'KRG')||strcmp(meta.type,'CKRG'))
    %%
    figure
    surf(grid_XY(:,:,1),grid_XY(:,:,2),K.var*10^20)
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