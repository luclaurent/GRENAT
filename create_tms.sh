#!/bin/bash

fichierref='MOY_qual_meta_ref_tms.m'
fichierdeb='MOY_qual_meta_'
fichierfin='Dtms.m'

fcttest=(rastrigin rosenbrock schwefel)

nbtirmin=5
nbtirmax=200
nbtirpas=5

dimmin=2
dimmax=10

for index in ${fcttest[*]}
do
	for ii in `seq -w $dimmin $dimmax`
	do
		newnom=`echo "${fichierdeb}${index}_$ii$fichierfin"`
		echo "Nouveau nom $newnom"
		cp $fichierref $newnom
		txtfct="\'$index\'"
		sed -i -e 's/\(fct=\).*\(;\)/\1'$txtfct'\2/'  $newnom
		sed -i -e 's/\(nb_tir_min=\).*\(;\)/\1'$nbtirmin'\2/'  $newnom
		sed -i -e 's/\(nb_tir_max=\).*\(;\)/\1'$nbtirmax'\2/'  $newnom
		sed -i -e 's/\(pas_tir=\).*\(;\)/\1'$nbtirpas'\2/'  $newnom
		sed -i -e 's/\(doe\.dim_pb=\).*\(;\)/\1'$ii'\2/'  $newnom

	done
done



