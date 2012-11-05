#!/bin/bash

for ii in `seq $1 $2`
do
	echo "Kill job n°$ii"
	qdel $ii
done
