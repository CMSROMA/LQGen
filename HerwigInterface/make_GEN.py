#! /usr/bin/env python

import os
import sys
import optparse
import datetime
import subprocess
import io

from glob import glob

usage = "usage: python make_GEN.py -i SingleLQ_ueLQue_M2000_Lambda1p0.list -o /afs/cern.ch/work/s/santanas/Workspace/CMS/LQGen/HerwigInterface/CMSSW_10_6_28_LQGen/src/SingleLQ_ueLQue_M2000_Lambda1p0__GEN -s singleLQ_13TeV_Pow_Herwig7_cfg_mod.py -n 10"

parser = optparse.OptionParser(usage)

parser.add_option("-i", "--inputlist", dest="inputlist",
                  help="input list with LHE files")

parser.add_option("-o", "--output", dest="outputdir",
                  help="the directory contains the output of the program. Can be AFS or EOS directory.")

parser.add_option("-s", "--script", dest="scriptname",
                  help="the script to be run")

parser.add_option("-n","--nEvents", dest="nEvents", type=int,
                  help="number of events for each file (mandatory otherwise herwig job will not finish)")


(opt, args) = parser.parse_args()

if not opt.inputlist:
    parser.error('input list not provided')

if not opt.outputdir:
    parser.error('output dir not provided')

if not opt.scriptname:
    parser.error('script name not provided')

if not opt.nEvents:
    parser.error('number of events in each file not provided')

################################################

print ("mkdir -p "+opt.outputdir)
os.system("mkdir -p "+opt.outputdir)

listname = (opt.outputdir).split("/")[-1]
listfile = open(opt.outputdir+"/"+listname+".list",'w')

for line in open(opt.inputlist):
    line = line.strip()
    print line

    samplename = (line.split("/")[-1]).split(".")[0]
    rootfilename = samplename+".root"

    command = "cmsRun "+opt.scriptname+" "+" files="+line+" output="+opt.outputdir+"/"+rootfilename+" maxEvents="+str(opt.nEvents)
    print (command)
    os.system(command)

    mvcommand = "mv "+opt.outputdir+"/"+samplename+"* "+opt.outputdir+"/"+rootfilename
    print (mvcommand)
    os.system(mvcommand)

    listfile.write(opt.outputdir+"/"+rootfilename+"\n")

listfile.close()
print ("List created: "+opt.outputdir+"/"+listname+".list")
