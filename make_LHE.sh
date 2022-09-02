#!/bin/bash

LQPROCESS=LeptonInducedLQ_utau
#LQPROCESS=SingleLQ_test
INPUTPOWHEG=testrun/powheg.input-NLO
#Mass=( 1000 1500 2000 2500 3000 )
#Y=(1p0 2p0 3p0)
#Mass=( 600 800 1000 1200 1400 1600 2000 )
#Y=(0p5 1p0 1p5 2p0 3p0)
#Mass=( 2000 )
#Y=(1p0)
Mass=( 600 900 1200 1500 1800 2100 2400 2700 3000 )
Y=(0p2 0p5 1p0 1p5 2p0)

OUTPUTDIR=/afs/cern.ch/work/c/ccaillol/generateLQ_newModel/LQGen
evts=20000
evtsperfile=2000

for m in "${Mass[@]}"
do 
	for i in "${Y[@]}"
	do
	        LQNAME=${LQPROCESS}_M${m}_Lambda${i}
		LQDIR=${OUTPUTDIR}/${LQNAME}
		echo  "mkdir -p ${LQDIR}"
		mkdir -p $LQDIR
		cp $INPUTPOWHEG $LQDIR/powheg.input
	        #cp weights.xml $LQDIR/.
		sed -i "s/^numevts.*/numevts ${evts} ! number of events to be generated/" $LQDIR/powheg.input
		sed -i "s/^mLQ .*/mLQ ${m}/" $LQDIR/powheg.input
		lambda=$(echo "${i}" | sed "s/p/./" )
		echo "${lambda}"	
		sed -i "s/^y_1t.*/y_1t ${lambda}/" $LQDIR/powheg.input
		cd $LQDIR
		../pwhg_main 
		mv pwgevents.lhe ${LQNAME}.lhe
		cd .. 
		python split_LHE.py -i ${LQDIR}/${LQNAME}.lhe -o ${LQDIR}/split -n ${evtsperfile}		
	done 
done


