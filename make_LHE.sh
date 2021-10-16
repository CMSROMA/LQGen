#!/bin/bash

LQPROCESS=SingleLQ_ueLQue
INPUTPOWHEG=testpowheg/powheg.input
Mass=( 2000 3000 )
Y=( 1p0 )

OUTPUTDIR=/afs/cern.ch/work/s/santanas/Workspace/CMS/LQGen
evts=100
evtsperfile=10 

for m in "${Mass[@]}"
do 
	for i in "${Y[@]}"
	do
	        LQNAME=${LQPROCESS}_M${m}_Lambda${i}
		LQDIR=${OUTPUTDIR}/${LQNAME}
		echo  "mkdir -p ${LQDIR}"
		mkdir -p $LQDIR
		cp $INPUTPOWHEG $LQDIR/powheg.input
		sed -i "s/^numevts.*/numevts ${evts} ! number of events to be generated/" $LQDIR/powheg.input
		sed -i "s/^LQmass.*/LQmass ${m}/" $LQDIR/powheg.input
		lambda=$(echo "${i}" | sed "s/p/./" )
		echo "${lambda}"	
		sed -i "s/^yLQ.*/yLQ ${lambda}/" $LQDIR/powheg.input
		cd $LQDIR
		../pwhg_main powheg.input
		mv pwgevents.lhe ${LQNAME}.lhe
		cd .. 
		python split_LHE.py -i ${LQDIR}/${LQNAME}.lhe -o ${LQDIR}/split -n ${evtsperfile}		
	done 
done


