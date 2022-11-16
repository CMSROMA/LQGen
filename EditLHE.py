import os
import sys
import argparse

#couplings=["utau"]
#masses=["600","900","1200","1500","1800","2100","2400","2700","3000"]
#lambdas=["0p2","0p5","1p0","1p5","2p0"]

couplings=["btau"]
masses=["600","800","1000","1200","1400","1600","2000"]
lambdas=["0p5","1p0","1p5","2p0","3p0"]

for j in range(0,len(masses)):
  for k in range(0,len(lambdas)):
      for l in range(1,11):
         input_lhe="/afs/cern.ch/work/c/ccaillol/generateLQ_newModel/LQGen/LeptonInducedLQ_"+couplings[0]+"_M"+masses[j]+"_Lambda"+lambdas[k]+"/split/LeptonInducedLQ_"+couplings[0]+"_M"+masses[j]+"_Lambda"+lambdas[k]+"__"+str(l)+".lhe"
         output_lhe="/afs/cern.ch/work/c/ccaillol/generateLQ_newModel/LQGen/LeptonInducedLQ_"+couplings[0]+"_M"+masses[j]+"_Lambda"+lambdas[k]+"/split/LeptonInducedLQ_mod_"+couplings[0]+"_M"+masses[j]+"_Lambda"+lambdas[k]+"__"+str(l)+".lhe"
	 print input_lhe,output_lhe

         fin = open(input_lhe, "rt")
         #output file to write the result to
         fout = open(output_lhe, "wt")
         #for each line in the input file
         i=-1
         
         for line in fin:
                 #read replace the string and write to output file
                 if '#------------------------------------------------' in line:
                    fout.write(line.replace('#------------------------------------------------', '#'))
                 elif '<weights>' in line:
                    fout.write(line.replace('<weights>', '<rwgt>'))
         	    i=0
                 elif '</weights>' in line:
                    fout.write(line.replace('</weights>', '</rwgt>'))
                    i=-1
                 elif i>=0:
         	    i=i+1
                    if i==1 : fout.write("<wgt id='101'> " + line.rstrip('\n') + " </wgt> \n")
                    elif i==2 : fout.write("<wgt id='102'> " + line.rstrip('\n') + " </wgt> \n")
                    elif i==3 : fout.write("<wgt id='103'> " + line.rstrip('\n') + " </wgt> \n")
                    elif i==4 : fout.write("<wgt id='104'> " + line.rstrip('\n') + " </wgt> \n")
                    elif i==5 : fout.write("<wgt id='105'> " + line.rstrip('\n') + " </wgt> \n")
                    elif i==6 : fout.write("<wgt id='106'> " + line.rstrip('\n') + " </wgt> \n")
                    elif i==7 : fout.write("<wgt id='107'> " + line.rstrip('\n') + " </wgt> \n")
                    else : fout.write("<wgt id='"+str(i-8)+"'> " + line.rstrip('\n') + " </wgt> \n")
                 else:
                    fout.write(line)
         #close input and output files
         fin.close()
         fout.close()

