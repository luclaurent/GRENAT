%% Erase all variables and close all opened windows
%% L. LAURENT -- 30/01/2014 -- luc.laurent@lecnam.net

function customClean

clc;
close all hidden;
clear all;
clear all global

%if display available, the windows have to be closed
screenSize = get(0,'ScreenSize');
if ~isequal(screenSize(3:4),[1 1])
 clf
end
end
