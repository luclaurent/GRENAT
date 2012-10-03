#!/bin/bash

if [ $# == 0 ]
then
	liste=` seq 0 47 `
else
	liste=$*
fi

echo $liste

for i in $liste
do
echo ">> Noeud $i"
# test de processus actif ou non
res=`psnode $i |grep MATLAB`
if [ "${#res}" != 0 ]
then
if [[ ($i == "0") || ($i == "1") ]]
then
qsub -l nodes=01:NODE$i:ppn=1,walltime=00:01:00 -q bigmem kill_matlab.sh
else
qsub -l nodes=01:NODE$i:ppn=1,walltime=00:01:00 kill_matlab.sh
fi
else
echo "Rien sur noeud $i"
fi
done
