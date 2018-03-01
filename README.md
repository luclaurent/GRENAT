GRENAT 
=======
GRENAT  = **GR**adient **EN**hanced **A**pproximation **T**oolbox


GRENAT regroups many techniques for generating surrogate models. These surrogate models can be built using responses and gradients obtained at some sample points.

The available surrogate models are

* Radial Basis Function (RBF/GRBF)
* Kriging/Cokriging (KRG/GKRG)
* Support Vector Regression (SVR/GSVR)

This toolbox is the result of the PhD thesis of [Luc LAURENT](http://www.lmssc.cnam.fr/fr/equipe/luc-laurent) ([LMSSC](http://www.lmssc.cnam.fr)), supervised by [Pierre-Alain Boucard](http://w3.lmt.ens-cachan.fr/site/php_perso/perso_page_lmt.php?nom=BOUCARD) ([LMT-Cachan](http://www.lmt.ens-cachan.fr/)) and [Bruno Soulier](http://w3.lmt.ens-cachan.fr/site/php_perso/perso_page_lmt.php?nom=SOULIER) ([LMT-Cachan](http://www.lmt.ens-cachan.fr/)). 

Features
------
GRENAT is able to 

* Normalize the input data
* Build the surrogate models
* Estimate hyperparameters (using optimizer and dedicated criteria)
* Evaluate the surrogate model at sample and non-sample points (and calculate the gradients of the approximation)
* Compute the variance of the prediction
* Compute the Cross-Validation of the surrogate model
* Compute the Expected Improvement (and derivated formulations)

External included toolboxes
------

GRENAT uses the
 
* [MultiDOE](https://bitbucket.org/luclaurent/multidoe) toolbox
* A modified version of the Particle Swarm Optimization Toolbox [PSOt](http://www.mathworks.com/matlabcentral/fileexchange/7506-particle-swarm-optimization-toolbox)

These toolbox are included in GRENAT.

Download
------

The toolbox can be downloaded [here](https://bitbucket.org/luclaurent/grenat/downloads).

If you use `git`, you can clone the repository using the following command

    git clone --recursive git@bitbucket.org:luclaurent/grenat.git GRENAT

Due to the use of submodules, the option  `--recursive` is *mandatory*.

If you forgot to use this option, you can activate the submodules by going in the folder on which you have cloned the repository and execute the following command:

    git submodule update --init --recursive
 

First start
------

Some examples are proposed by functions:

* `ExampleUse1D.m` 1 dimensional example
* `ExampleUse2D.m` 2 dimensional example
* `ExampleUseDOE.m` example using the included sampling techniques


Requirements
------
The toolbox requires:


* the Global Optimization Toolbox of the Matlab's software (optional)
* the Parallel Computing Toolbox of the Matlab's software (optional)

[Documentation](https://goo.gl/FlnVAK)
------
The automatic building of the documentation is based on the [m2html](http://www.artefact.tk/software/matlab/m2html/) software.

The obtained documentation is available [here](https://goo.gl/FlnVAK).

References
----
Available approachs of this toolbox are presented in the following documents:

* L. Laurent, R. Le Riche, B. Soulier and P.-A. Boucard. An Overview of Gradient-Enhanced Metamodels with Applications. *Archives of Computational Methods in Engineering*, July 2017. doi: [10.1007/s11831-017-9226-3](https://doi.org/10.1007/s11831-017-9226-3) [hal](https://hal-emse.ccsd.cnrs.fr/emse-01525674)
* [Luc Laurent PhD Thesis](https://tel.archives-ouvertes.fr/tel-00972299) in french
* L. Laurent, P.-A. Boucard, and B. Soulier. Generation of a cokriging metamodel using a multiparametric strategy. *Computational Mechanics*, 51(2):151-169, February 2013. doi: [10.1007/s00466-012-0711-0](https://dx.doi.org/10.1007/s00466-012-0711-0) [hal](https://hal.archives-ouvertes.fr/hal-01376462)
* L. Laurent, P.-A. Boucard, and B. Soulier. A dedicated multiparametric strategy for the fast construction of a cokriging metamodel. *Computers & Structures*, 124(0):61-73, 2013. doi: [10.1016/j.compstruc.2013.03.012](https://dx.doi.org/10.1016/j.compstruc.2013.03.012) [hal](https://hal.archives-ouvertes.fr/hal-01376464)
* L. Laurent, P.-A. Boucard, and B. Soulier. Fast multilevel optimization using a multiparametric strategy and a cokriging metamodel. In Y. Tsompanakis, B.H.V. Topping, (Editors), *Proceedings of the Second International Conference on Soft Computing Technology in Civil, Structural and Environmental Engineering*, 6-9 September, number Paper 50. Civil-Comp Press, Stirlingshire, UK, 2011. doi: [10.4203/ccp.97.50](https://dx.doi.org/10.4203/ccp.97.50)

Applications of this toolbox
---
Please [notice me](mailto:luc.laurent@lecnam.net) if you use the toolbox, I will add your publications below.

* Nicolas Courrier. Couplage optimisation à convergence partielle et stratégie multiparamétrique en calcul de structures. Mécanique des solides. Université Paris-Saclay, 2015. Français. [tel](https://tel.archives-ouvertes.fr/tel-01264667)
* C. Limoge. Méthode de diagnostic à grande échelle de la vulnérabilité sismique des Monuments Historiques : Chapelles et églises baroques des hautes vallées de Savoie. Génie civil. Université Paris-Saclay, 2016. Français. [tel](https://tel.archives-ouvertes.fr/tel-01314443)
* L. Laurent, A. Legay. Optimal positioning of a wall in an acoustic cavity using reduced models and surrogate based optimization. 12th World Congress of Structural and Multidisciplinary Optimisation, WCSMO 12, Jun 2017, Braunschweig, France. [hal](https://hal.archives-ouvertes.fr/hal-01567251)
* A. Legay, L. Laurent. Thin wall optimal positioning in an acoustic cavity using XFEM, reduced models and surrogate based optimization. eXtended Discretization MethodS for partial differential equations on complex and evolving domains, X-DMS 2017, Jun 2017, Umeå, Sweden. [hal](https://hal.archives-ouvertes.fr/hal-01567252)
* L. Laurent, A. Legay. Positionnement optimal de parois en vibro-acoustique à l'aide de modèles réduits et d'optimisation par métamodèle. 13e Colloque National en Calcul des Structures, May 2017, Giens, France. [hal](https://hal.archives-ouvertes.fr/hal-01567253)
* A. Benaouali and S. Kachel. A surrogate-based integrated framework for the aerodynamic design op- timization of a subsonic wing planform shape. Proceedings of the Institution of Mechanical Engineers, Part G: Journal of Aerospace Engineering, 2017. doi: [10.1177/0954410017699007](https://doi.org/10.1177/0954410017699007) [ResearchGate](https://www.researchgate.net/publication/315517815_A_surrogate-based_integrated_framework_for_the_aerodynamic_design_optimization_of_a_subsonic_wing_planform_shape/comments)

License ![GNU GPLv3](http://www.gnu.org/graphics/gplv3-88x31.png)
----

    GRENAT - GRadient ENhanced Approximation Toolbox 
    A toolbox for generating and exploiting gradient-enhanced surrogate models
    Copyright (C) 2016  Luc LAURENT <luc.laurent@lecnam.net>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.