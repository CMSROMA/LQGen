#! /usr/bin/env python

import os
import sys
import optparse
import datetime
import subprocess
import io

from glob import glob

usage = "usage: python split_LHE.py -i SingleLQ_ueLQue_M2000_Lambda1p0/SingleLQ_ueLQue_M2000_Lambda1p0.lhe -o /afs/cern.ch/work/s/santanas/Workspace/CMS/LQGen/TEST_1 -n 1000"

parser = optparse.OptionParser(usage)

parser.add_option("-i", "--inputfile", dest="inputfile",
                  help="input LHE file")

parser.add_option("-o", "--output", dest="outputdir",
                  help="the directory contains the output of the program. Can be AFS or EOS directory.")

parser.add_option("-n","--nEventsPerFile", dest="nEventsPerFile", type=int,
                  help="number of events for each file",
                  default=-1)

(opt, args) = parser.parse_args()

if not opt.inputfile:   
    parser.error('input file not provided')

if not opt.outputdir:   
    parser.error('output dir not provided')


################################################

# create outputdir
lhefilename = ((opt.inputfile).split("/")[-1]).split(".")[0]
print (lhefilename)

print ("mkdir -p "+opt.outputdir)
os.system("mkdir -p "+opt.outputdir)

# Count number of events in LHE 
nevTot = 0
for line in open(opt.inputfile,'r'):
    if '<event>' in line:
        nevTot += 1

if (opt.nEventsPerFile == -1):
    opt.nEventsPerFile = nevTot

print ("Number of events per file: ", opt.nEventsPerFile)


# Find start of lhe file
nameFileStart="fileStart.txt"
fileStart = open(nameFileStart,'w')
for line in open(opt.inputfile,'r'):
    if '<event>' in line:
        break
    fileStart.write(line)
fileStart.close()

# Find end of lhe file
nEnd=0
nameFileEnd="fileEnd.txt"
fileEnd = open(nameFileEnd,'w')
for line in open(opt.inputfile,'r'):
    if (nEnd == nevTot):
        fileEnd.write(line)
    if '</event>' in line:
        nEnd += 1
fileEnd.close()

# Split LHE file
nevtmp = 0
nev = 0 
nfile = 1
evtStart = False
currentfilename = None
currentfile = None

for line in open(opt.inputfile,'r'):

    if(nev == nevTot):
        currentfile.close()
        break;

    if(nevtmp == opt.nEventsPerFile):        
        nfile+=1
        nevtmp=0
        currentfile.close()

    #currentline = "===> nfile="+str(nfile)+" nevtmp="+str(nevtmp)+" "+line
    currentline = line

    if '<event>' in line:
        evtStart = True

    if evtStart:

        if(nevtmp == 0 and ('<event>' in line) ):
            #print (currentline)
            currentfilename = lhefilename+"__"+str(nfile)+".lhe"
            print ("creating a new file: ", currentfilename)
            currentfile = open(opt.outputdir+"/"+currentfilename,'w')

        currentfile.write(currentline)

        if '</event>' in line:
            nevtmp += 1
            nev += 1
            evtStart = False

print ("Original LHE file splitted in "+str(nfile)+" files")

namelistlhe = opt.outputdir+"/"+lhefilename+".list"
listlhe = open(namelistlhe,"w")
for k in range(1,nfile+1):
    print("cat "+nameFileStart+" "+opt.outputdir+"/"+lhefilename+"__"+str(k)+".lhe"+" "+nameFileEnd+" >> tmp_"+str(k)+".lhe")
    os.system("cat "+nameFileStart+" "+opt.outputdir+"/"+lhefilename+"__"+str(k)+".lhe"+" "+nameFileEnd+" >> tmp_"+str(k)+".lhe")
    print("mv tmp_"+str(k)+".lhe"+" "+opt.outputdir+"/"+lhefilename+"__"+str(k)+".lhe")
    os.system("mv tmp_"+str(k)+".lhe"+" "+opt.outputdir+"/"+lhefilename+"__"+str(k)+".lhe")
    listlhe.write(opt.outputdir+"/"+lhefilename+"__"+str(k)+".lhe"+"\n")
listlhe.close()

# clean
os.system("rm -f "+nameFileStart)
os.system("rm -f "+nameFileEnd)
