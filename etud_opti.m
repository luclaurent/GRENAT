%Fichier d'étude et de mise en oeuvre des démarche de la biblio
%L LAURENT   --  31/01/2010   --  luc.laurent@ens-cachan.fr
clf;clc;close all; clear all;

%Tracé de la fonction de la fonction étudiée
x=-2:0.1:2;
y=-1:0.1:3;
[X,Y]=meshgrid(x,y);
Z=rosenbrock(X,Y);
figure;
surfc(X,Y,Z)
shading interp

%% Tirages: plan d'expérience


%% Génération du métamodèle

%type d'interpolation
%PRG: regression polynomiale

meta.type='PRG';
