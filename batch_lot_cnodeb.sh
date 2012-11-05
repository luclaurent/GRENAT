#!/bin/bash

#Execution script qsub -l nodes=01:ppn=1,pmem=30gb,walltime=100:00:00 -t <nb_job> -v FICH_SCRIPT=<nom_fichier>  batch_lot_cnode.sh
#Execution sur node 0/1 (mémoire 64gb) ajouter -q bigmem


# execution possible sans qsub pour lancement jobs sans tableau

# Ce script assure la création d'un tableau de job et prend en paramètres 
#	- <nb_job>: le nombre de jobs demandés (format 0-xxx%yyy avec xxx la fin de la plage de jobs et yyy le nb de jobs simultannés)
#	- <nom_fichier>: fichier texte contenant les noms des scripts maltab à lancer


## déclaration variables
# noms dossiers
DOSSIER_BASE="/data1/laurent"
META="code_meta_cluster"
NOM="laurent"
DOSSIER_RESULTS="resultats_cluster"
DOSSIER_DATA_EXEC="exec_cluster"
DOSSIER_PID="./"
# commande execution MATLAB
OPT_MATLAB="-nodesktop -nosplash -nodisplay -r"
LOG_MATLAB="-logfile"
# executable MatLab par défaut
exec_def="matlab-R2011b"
EXEC_MATLAB="/usr/local/bin/matlab-R2011b"
# mail
adr="laurent@lmt.ens-cachan.fr"
# extraction des données de l'execution
#liste_scripts=`echo $DATA_PERSO|awk '{print $1}'`
liste_scripts=$FICH_SCRIPT
# récupération numero du tableau de job (1ere valeur = 0)
num_job=$PBS_ARRAYID

#si execution sans tableau
#nombre de noeuds requis
NB_NODES="1"
#nombre de proc requis par noeud
NB_PROC="2"
#Mémoire requise (mb)
MEM_PAR_PROC="9000"
#temps calcul (format hh:mm:ss)
CPU_TIME="300:00:00"
#Script lancement job
SCRIPT_LANCE_JOB="batch_cnode.sh"


echo `date`
echo $SHELL
echo '-------------------------------------------'
echo ' INITIALISATION DOSSIERS'
echo '-------------------------------------------'
#recuperation date/heure
day=`date +%Y%m%d`
heure=`date +%H%M%S`


# récupération nom du fichier MatLab à récupérer
DOSSIER_SOURCE=${DOSSIER_BASE}
DOSSIER_RACINE=$DOSSIER_SOURCE
DOSSIER_META=${DOSSIER_RACINE}/${META}
DOSSIER_DONNEES_EXECUTIONS=${DOSSIER_RACINE}/${DOSSIER_DATA_EXEC}
DOSSIER_RESULTATS=${DOSSIER_RACINE}/${DOSSIER_RESULTS}

echo '  >> Préparation des fichiers de calcul'
echo "Dossier source: $DOSSIER_SOURCE"
echo "Dossier code metamodèle: $DOSSIER_META"
echo "Dossier de données d'execution: $DOSSIER_DONNEES_EXECUTIONS"
echo "Dossier resultats: $DOSSIER_RESULTATS"


if [ -z ${PBS_ARRAYID} ]
then
	
	echo '================'
	echo 'LANCEMENT CALCULS sans tableau'
	
liste_scripts_abs=`echo "$1"`
echo "Fichier de donnees ${liste_script_abs}"
	
	#parcours liste scripts
	while read line
	do
		#extraction numero job
		NUM_JOB_BRUT=`echo "$line"|awk '{print $1}'`
		NUM_JOB=`echo ${NUM_JOB_BRUT} | sed 's/\#//g'`
		#extraction nom script  MATLAB
		SCRIPT_MATLAB=`echo "$line"|awk '{print $2}'`
		#extraction nom job
		NOM_JOB_MANU=`echo "$line"|awk '{print $3}'`

		#affichage infos
		echo "+++++ JOB n° $NUM_JOB"
		echo "+++++ NOM SCRIPT: $SCRIPT_MATLAB"
		echo "+++++ NOM JOB: $NOM_JOB_MANU"

		#commande d'execution cluster
		CMD_CLUSTER=`echo "qsub -l nodes=${NB_NODES}:ppn=${NB_PROC},pmem=${MEM_PAR_PROC}mb,walltime=${CPU_TIME} -N ${NUM_JOB}_${NOM_JOB_MANU} -v FICHIER_MATLAB=${SCRIPT_MATLAB}.m,EXT_DOSS=${NUM_JOB} ${SCRIPT_LANCE_JOB}"`
		echo "+++++ Commande execution calcul"
		echo "$CMD_CLUSTER"
		${CMD_CLUSTER}
	done < ${liste_scripts_abs}
else

	echo '================'
	echo 'LANCEMENT CALCULS dans tableau'

echo '-------------------------------------------'
echo ' RECUPERATION SCRIPT MATLAB'
echo '-------------------------------------------'

liste_scripts_abs=`echo "${DOSSIER_META}/${liste_scripts}"`
echo "Fichier de donnees ${liste_script_abs}"
#numero pour lecture fichier scripts
num_fichier_matlab=`echo "$(printf %03d $num_job)"`
#récupération fichier matlab
num_rech=`echo "#####$num_fichier_matlab"`
FICHIER_MATLAB=`cat $liste_scripts_abs |grep $num_rech|awk '{print $2}'`
#récupération nom job
NOM_JOB_MANU=`cat $liste_scripts_abs |grep $num_rech|awk '{print $3}'`

echo " Numéro du job: $num_job"
echo " Nom fichier Matlab: $FICHIER_MATLAB"

echo '-------------------------------------------'
echo ' INITIALISATION CALCUL'
echo '-------------------------------------------'
# initialisation dossier de stockage
DOSSIER_BASE_TRAVAIL=${day}'_'${heure}'_'${FICHIER_MATLAB}'_'${num_job}
DOSSIER_TRAVAIL=${DOSSIER_DONNEES_EXECUTIONS}/${DOSSIER_BASE_TRAVAIL}

echo "Dossier de travail: $DOSSIER_TRAVAIL"

#Verification existence dossier de données d'execution
echo "  >> Vérification existence dossier de données d'execution"
if [ -d $DOSSIER_DONNEES_EXECUTIONS ]
then
        echo "Dossier de données d'execution existant"
else
	echo "Dossier de données d'execution inexistant -- Création"
	mkdir $DOSSIER_DONNEES_EXECUTIONS
fi
#Verification existence dossier de résultats
echo "  >> Vérification existence dossier de résultats"
if [ -d $DOSSIER_RESULTATS ]
then
        echo "Dossier de résultats existant"
else
	echo "Dossier de résultats inexistant -- Création"
	mkdir $DOSSIER_RESULTATS
fi

#Verification existence dossier temporaire
echo "  >> Vérification existence dossier de données d'execution"
if [ -d $DOSSIER_TRAVAIL ]
then
	echo "Dossier temporaire existant"
	echo "Création d'un dossier différent"
	test_exist=false
	ite=0
	while ! $test_exist
	do
		doss_test=`echo "${DOSSIER_TRAVAIL}_${ite}"`
		if [ -d $doss_test ]
		then
			ite=$(($ite+1))
		else
			echo "Création dossier temporaire sous le nom: $doss_test"
			mkdir $doss_test
			test_exist=true
			echo "Le dossier de travail: $DOSSIER_TRAVAIL"
			DOSSIER_TRAVAIL=`echo "${DOSSIER_TRAVAIL}_${ite}"`
			echo "devient: $DOSSIER_TRAVAIL"
		fi
	done
else
	echo "Dossier temporaire inexistant -- Création"
	mkdir $DOSSIER_TRAVAIL
fi

echo '  >> Copie des fichiers dans le dossier temporaire'
rsync -avuz --exclude 'results/' --exclude '.git/' ${DOSSIER_META}/* ${DOSSIER_TRAVAIL}/.


echo '-------------------------------------------'
echo ' RECUPERATION DES INFOS (PBS_NODEFILE)'
echo '-------------------------------------------'
cat $PBS_NODEFILE
echo '-------------------------------------------'

echo '  >> Premier noeud de la liste alloué'
PREMIERNODE=$(head -1  $PBS_NODEFILE )
echo $PREMIERNODE

echo '  >> Verification existence dossier /usrtmp/login/DOSSIER sur tous les noeuds alloués'

NGID=$( id -ng )
NUID=$( id -nu )

if [ "$NUID" != "$PBS_O_LOGNAME" ] ; then
  echo "PB uid"
  exit
fi

echo "NUID : $NUID"
echo "NGID : $NGID"

LISTNODE=$( sort $PBS_NODEFILE | uniq )

for node in $LISTNODE
do
   echo "----------------------  $node"

# rsh ne renvoit pas le exit status de la commande remote 
# --> mais ssh oui

# ssh renvoit le exit status de la commande remote
# rsh renvoit le exit status du rsh

# verif et/ou creation dossier laurent dans /usrtmp/ sur chaque noeud alloué
   DIR=$(rsh $node "ls /usrtmp | grep $NUID" )
   EXITSTATUS=$?
   if [ $EXITSTATUS != 0 ]
   then
     echo " exitstatus : $EXITSTATUS"
     echo " PB de connexion rsh sur $node"
     exit 1
   fi

   if [ "X$DIR" == "X" ]
   then
     echo "Pas de repertoire $nom dans /usrtmp/$NUID de $node"
     echo "On le cree"

     ssh $node "mkdir -p /usrtmp/$NUID && chown $NUID:$NGID /usrtmp/$NUID "
     EXITSTATUS=$?
     if [ $EXITSTATUS != 0 ]
     then
       echo " exitstatus : $EXITSTATUS"
       echo " PB de creation de /usrtmp/$NUID sur $node"
       exit 1
     fi
   else
     echo " /usrtmp/$NUID EXISTE sur $node"
   fi
   
# verif et/ou creation dossier $DOSSIER_TRAVAIL dans /usrtmp/laurent/$DOSSIER_TRAVAIL sur chaque noeud alloué
   DIR=$(rsh $node "ls /usrtmp/$NUID | grep $DOSSIER_BASE_TRAVAIL" )
   EXITSTATUS=$?
   if [ $EXITSTATUS != 0 ]
   then
     echo " exitstatus : $EXITSTATUS"
     echo " PB de connexion rsh sur $node"
     exit 1
   fi

   if [ "X$DIR" == "X" ]
   then
     echo "Pas de repertoire $DOSSIER_BASE_TRAVAIL dans /usrtmp/$NUID de $node"
     echo "On le cree"

     ssh $node "mkdir -p /usrtmp/$NUID/$DOSSIER_BASE_TRAVAIL && chown $NUID:$NGID /usrtmp/$NUID/$DOSSIER_BASE_TRAVAIL "
     EXITSTATUS=$?
     if [ $EXITSTATUS != 0 ]
     then
       echo " exitstatus : $EXITSTATUS"
       echo " PB de creation de /usrtmp/$NUID/$DOSSIER_BASE_TRAVAIL sur $node"
       exit 1
     fi
   else
     echo " /usrtmp/$NUID/$DOSSIER_BASE_TRAVAIL EXISTE sur $node"
   fi

done

echo '-------------------------------------------'
echo ' COPIE DES FICHIERS PAR RSYNC -Z'
echo '-------------------------------------------'
#copie fichiers sur nutmp
rsync -auz --exclude '.git' $DOSSIER_TRAVAIL/* /usrtmp/$NUID/$DOSSIER_BASE_TRAVAIL/. 

echo '-------------------------------------------'
echo ' RECHERCHE COMMANDE COMPLETE EXECUTABLE MATLAB'
echo '-------------------------------------------'
if [ "${#EXEC_MATLAB}" -eq 0 ]; then
echo " Recherche chemin MatLab"
exec_full=$(rsh $PREMIERNODE "which $exec_def")
if [ "${#exec_full}" -eq 0 ]; then
echo "Pas de récupération de chemin MatLab"
else
echo "Chemin complet MatLab"
echo "${exec_full}"
exec=$exec_full
fi
else
echo "Chemin MatLab défini manuellement"
echo "${EXEC_MATLAB}"
exec=${EXEC_MATLAB}
fi


echo '-------------------------------------------'
echo ' EXECUTION ET RAPATRIEMENT DES FICHIERS PAR RSYNC -Z'
echo '-------------------------------------------'
# commande d'execution
FICH_LOG=`echo "${FICHIER_MATLAB}_${num_job}.log"`
echo "Fichier log Matlab: $FICH_LOG"
cmd_matlab=${exec}' '${OPT_MATLAB}' '${FICHIER_MATLAB}' '${LOG_MATLAB}' '${FICH_LOG}
echo "Commande execution MatLab $cmd_matlab"
# pour lancer le calcul
#rsh $PREMIERNODE  " cd /usrtmp/$NUID/$DOSSIER_TRAVAIL/$pilotage && ${cmd_matlab} ;
#rsync -auz /usrtmp/$NUID/$DOSSIER_TRAVAIL/${pilotage}/results/* $DOSSIER_RESULTATS/."
# execution matlab
cd /usrtmp/$NUID/$DOSSIER_BASE_TRAVAIL/$meta && ${cmd_matlab} 
rsync -auz /usrtmp/$NUID/$DOSSIER_BASE_TRAVAIL $DOSSIER_RESULTATS/.
 
echo "Stockage des résultats dans $DOSSIER_RESULTATS"

echo '-------------------------------------------'
echo ' COMPRESSION DES DONNEES (SOURCE ET CLUSTER)'
echo '-------------------------------------------' 
# sur source
tar -cjf ${DOSSIER_DONNEES_EXECUTIONS}/${DOSSIER_BASE_TRAVAIL}.tar.bz2 ${DOSSIER_DONNEES_EXECUTIONS}/${DOSSIER_BASE_TRAVAIL}
rm -rf ${DOSSIER_DONNEES_EXECUTIONS}/${DOSSIER_BASE_TRAVAIL}

#sur cluster
tar -cjf /usrtmp/$NUID/$DOSSIER_BASE_TRAVAIL.tar.bz2 /usrtmp/$NUID/$DOSSIER_BASE_TRAVAIL && rm -rf /usrtmp/$NUID/$DOSSIER_BASE_TRAVAIL 

echo '-------------------------------------------'
echo ' ARRET PROCESSUS SI PLANTAGE'
echo '-------------------------------------------' 
rsh $PREMIERNODE " cd /usrtmp/$NUID/$DOSSIER_BASE_TRAVAIL/$DOSSIER_PID && for i in `ls -d pid*`; do echo $i ; processus=${i:4}; echo 'Arret processus:';echo $processus; kill -9 $processus; rm -f $i; done "


echo '-------------------------------------------'
echo ' ENVOI MAIL FIN DE CALCUL '
echo '-------------------------------------------'
sub=`echo "Fin calcul sur $PREMIERNODE"`
mutt -s "$sub" $adr < ${DOSSIER_RESULTATS}/${FICH_LOG}

fi
