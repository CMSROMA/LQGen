#!/bin/bash

Mass=( 1000 2000 3000 4000 5000 )
Y=( 0p1 0p3 0p5 0p7 1p0)

evts=100000

filename="list.txt"

for m in "${Mass[@]}"
do 
	for i in "${Y[@]}"
	do
		mkdir -p LQue_M${m}_Lambda${i}
		echo  " mkdir -p LQue_M${m}_Lambda${i}"
		cp testpowheg/powheg.input LQue_M${m}_Lambda${i}
		sed -i "s/^numevts.*/numevts ${evts} ! number of events to be generated/" LQue_M${m}_Lambda${i}/powheg.input
		sed -i "s/^LQmass.*/LQmass ${m}/" LQue_M${m}_Lambda${i}/powheg.input
		lambda=$(echo "${i}" | sed "s/p/./" )
		#echo "${lambda}"	
		sed -i "s/^yLQ.*/yLQ ${lambda}/" LQue_M${m}_Lambda${i}/powheg.input
		cd LQue_M${m}_Lambda${i}
		../pwhg_main powheg.input
		cp pwgevents.lhe pwgevents_M${m}_Lambda${i}.lhe
		cd .. 
		echo "file:/data/mcampana/CMS/LQGen/LQue_M${m}_Lambda${i}/pwgevents_M${m}_Lambda${i}.lhe">>${filename}
	done 
done
