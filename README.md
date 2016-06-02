GRENAT 
=======
GRENAT  = **GR**adient **EN**hanced **A**pproximation **T**oolbox


GRENAT regroups many techniques for generating surrogate models. These surrogate models can be built using responses and gradients obtained on some sample points.

The available surrogate models are

* Radial Basis Function (RBF/GRBF)
* Kriging/Cokriging (KRG/GKRG)
* Support Vector Regression (SVR/GSVR)

This toolbox is the result of a teamwork with [Luc LAURENT](http://www.lmssc.cnam.fr/fr/equipe/luc-laurent) ([LMSSC](http://www.lmssc.cnam.fr)), [Pierre-Alain Boucard](http://w3.lmt.ens-cachan.fr/site/php_perso/perso_page_lmt.php?nom=BOUCARD) ([LMT-Cachan](http://www.lmt.ens-cachan.fr/) and [Bruno Soulier](http://w3.lmt.ens-cachan.fr/site/php_perso/perso_page_lmt.php?nom=SOULIER) ([LMT-Cachan](http://www.lmt.ens-cachan.fr/). 

Features
------
GRENAT are able to 

* Normalize the input data
* Build the surrogate models
* Estimate hyperparameters (using optimizer and dedicated criteria)
* Evaluate the surrogate model at sample and non-sample points (and calculate the gradients of the approximation)
* Compute the variance of the prediction
* Compute the Cross-Validation of the surrogate model
* Compute the Expected Improvement (and derivate formulations)

External included toolboxes
------

GRENAT uses the
 
* [MultiDOE](https://bitbucket.org/luclaurent/multidoe) toolbox
* A modified version of the Particle Swarm Optimization Toolbox [PSOt](http://www.mathworks.com/matlabcentral/fileexchange/7506-particle-swarm-optimization-toolbox)

These toolbox are included in GRENAT.

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

[Documentation](https://goo.gl/t0hmjG)
------
The automatic building of the documentation is based on the [m2html](http://www.artefact.tk/software/matlab/m2html/) software.

The obtained documentation is available here.

References
----
Approachs available in this toolbox are presented in the following documents:

* [Luc Laurent PhD Thesis](https://tel.archives-ouvertes.fr/tel-00972299) in french
* L. Laurent, P.-A. Boucard, and B. Soulier. Generation of a cokriging metamodel using a multiparametric strategy. *Computational Mechanics*, 51(2):151–169, February 2013. doi: [10.1007/s00466-012-0711-0](https://dx.doi.org/10.1007/s00466-012-0711-0)
* L. Laurent, P.-A. Boucard, and B. Soulier. A dedicated multiparametric strategy for the fast construction of a cokriging metamodel. *Computers & Structures*, 124(0):61–73, 2013. doi: [10.1016/j.compstruc.2013.03.012](https://dx.doi.org/10.1016/j.compstruc.2013.03.012)
* L. Laurent, P.-A. Boucard, and B. Soulier. Fast multilevel optimization using a multiparametric strategy and a cokriging metamodel. In Y. Tsompanakis, B.H.V. Topping, (Editors), *Proceedings of the Second International Conference on Soft Computing Technology in Civil, Structural and Environmental Engineering*, 6-9 September, number Paper 50. Civil-Comp Press, Stirlingshire, UK, 2011. doi: [10.4203/ccp.97.50](https://dx.doi.org/10.4203/ccp.97.50)

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