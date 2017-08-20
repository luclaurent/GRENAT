%% function display table with two columns of text
function dispTableTwoColumnsStruct(tableFieldIn,structIn)
%size of every components in tableA
sizeA=cellfun(@numel,tableFieldIn);
maxA=max(sizeA);
%space after each component
spaceA=maxA-sizeA+3;
spaceTxt=' ';
%display table
for itT=1:numel(tableFieldIn)
    if isfield(structIn,tableFieldIn{itT})
        fprintf('%s%s%s\n',tableFieldIn{itT},spaceTxt(ones(1,spaceA(itT))),structIn.(tableFieldIn{itT}));
    end
end
end