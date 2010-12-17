function [fct,dfct]=fct(x)


fct=15*cos(x)+20;
if nargout==2
    dfct=-15*sin(x);
end