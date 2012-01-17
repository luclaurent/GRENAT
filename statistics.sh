#!/bin/bash

# procédure permettant d'obtenir des statistiques sur le code 
# nombre de fichiers, nb de lignes de code, nb de ligne de commentaires, nb de lignes total

# recherche des fichiers codés en matlab

files_pilot=`find ../code_pilotage -type f -name '*.m' |grep -v divers`
files_meta=`find ../code_meta -type f -name '*.m' |grep -v matlab2tikz|grep -v old|grep -v results`

echo "==================="
echo ">> code_pilotage"

nbfi=`echo "$files_pilot" | wc -l`
nbcom=`grep -i '^\%' $files_pilot | wc -l`
nbtli=`cat $files_pilot |wc -l`
nbcod=`echo $((nbtli-nbcom))`

echo "Nombre de fichiers: $nbfi"
echo "Nombre des lignes de commentaires: $nbcom"
echo "Nombre de lignes de code: $nbcod"
echo "Nombre total de lignes: $nbtli"
echo "=================="

echo "==================="
echo ">> code_meta"

nbfi=`echo "$files_meta" | wc -l`
nbcom=`grep -i '^\%' $files_meta | wc -l`
nbtli=`cat $files_meta |wc -l`
nbcod=`echo $((nbtli-nbcom))`

echo "Nombre de fichiers: $nbfi"
echo "Nombre des lignes de commentaires: $nbcom"
echo "Nombre de lignes de code: $nbcod"
echo "Nombre total de lignes: $nbtli"
echo "=================="
