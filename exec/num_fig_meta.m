%%fonction specifiant le nombre de figures associees a un critere sur le
%%metamodele
%% L. LAURENT -- 28/01/2013 -- laurent@lmt.ens-cachan.fr

function num_fig_fin=num_fig_meta(crit,num_fig_orig)

%si pas de nombre de figures initial
if nargin==1;num_fig_orig=0;end

num_fig_fin=num_fig_orig;

for  it_type=1:length(crit)
    switch crit{it_type}
        case {'NB_PTS','HIST_R2','HIST_Q3','CV_MSE','CONV_R2_EX','CONV_Q3_EX',...
                'CONV_EI','CONV_EIR','CONV_EIRb','CONV_GEIR','CONV_GEI',...
                'CONV_VAR','CONV_VARR','CONV_LCB',...
                'CONV_LCBR','CONV_WEI','CONV_WEIR','CONV_WEIRb',...
                'CONV_GEIRb'};
            num_fig_fin=num_fig_fin+1;
        case {'CONV_REP','CONV_LOC','CONV_REP_EX','CONV_LOC_EX',...
                'CONV_EIRn','CONV_WEIRn','CONV_GEIRn'}
            num_fig_fin=num_fig_fin+2;
    end
end