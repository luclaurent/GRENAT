%% check missing data
function check(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Gfprintf(' >> Check missing data \n');
%
obj.checkResp();
obj.checkGrad();
obj.show();
end