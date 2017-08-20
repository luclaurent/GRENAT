%% Show the list of available kernel functions
function showKernel(obj)
fprintf('List of available kernel functions\n');
dispTableTwoColumns(obj.listKernel,obj.listKernelTxt)
end