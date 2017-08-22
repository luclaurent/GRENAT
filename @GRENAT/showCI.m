%display the confidence intervals approximated by the metamodel
function showCI(obj,ciVal,nonsamplePts)
%type of confidence intervals
ciOk=false;ciValDef=95;
if nargin>1;if ~isempty(ciVal);if ismember(ciVal,[68,95,99]);ciOk=true;end, end, end
if ~ciOk;ciVal=ciValDef;end
%store non sample points
if nargin>2;obj.nonsamplePts=nonsamplePts;end
obj.confDisp.title=([num2str(ciVal) '% confidence intervals']);
%evaluation of the confidence interval
evalCI(obj);
%load data to display
ciDisp=obj.nonsampleCI.(['ci' num2str(ciVal)]);
%display the CI
displaySurrogateCI(obj.nonsamplePts,ciDisp,obj.confDisp,obj.nonsampleResp);
end