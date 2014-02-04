%% Fonction assurant l'effacement de toutes les grandeurs et la fermeture des fenetres ouvertes
%% L. LAURENT -- 30/01/2014 laurent@lmt.ens-cachan.fr

function clean

clc;close all hidden; clear all;clear all global

%si pas affichage, on ferme les figures ouvertes
screenSize = get(0,'ScreenSize');
if ~isequal(screenSize(3:4),[1 1])
 clf
end
