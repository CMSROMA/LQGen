Note: the file forCMS.tar is the one originally provided by the theorist in April 2021 (i.e. before the changes committed in this repository).

# Clone repository

Clone the repository in a new folder:
```
git clone git@github.com:CMSROMA/LQGen.git
cd LQGen
```

# Generate LQ events with POWHEG+HERWIG

## Install POWHEG-BOX-V2

Take the code from the repository:
```
svn checkout --username anonymous --password anonymous svn://powhegbox.mib.infn.it/trunk/POWHEG-BOX-V2
```

Setup environment and LHAPDF_DATA_PATH from cvmfs (https://cernvm.cern.ch/fs/):
```
bash
source setup.sh
```

Compile:
```
make
```

## Generate Leptoquark events in LHE format

Create a new folder for each signal hypothesis:
```
mkdir LQue_M3000_Lambda1p0
cp testpowheg/powheg.input LQue_M3000_Lambda1p0
cd LQue_M3000_Lambda1p0
```

Edit the configuration (powheg.input):
```
numevts 10000     ! number of events to be generated

lhans1 82400      ! pdf set for hadron 1 (LHA numbering for LUXlep-NNPDF31_nlo_as_0118_luxqed, https://lhapdf.hepforge.org/pdfsets)
lhans2 82400      ! pdf set for hadron 2 (LHA numbering for LUXlep-NNPDF31_nlo_as_0118_luxqed, https://lhapdf.hepforge.org/pdfsets)


whichproc "LQue"
#whichproc "LQumu"

LQmass 3000
yLQ 1
```

Generate events:
```
../pwhg_main powheg.input
```

The output file is pwgevents.lhe (MLQ=3000 GeV, yLQ=1, 10k events, 8.8 MB). A typical event:
```
<event>
      5  10001  6.16955E-04  3.02683E+03 -1.00000E+00  7.74632E-02
       2    -1     0     0   501     0  0.000000000E+00  0.000000000E+00  2.069951259E+03  2.069951259E+03  0.000000000E+00  0.00000E+00  9.000E+00
      11    -1     0     0     0     0  0.000000000E+00  0.000000000E+00 -1.106509229E+03  1.106509229E+03  0.000000000E+00  0.00000E+00  9.000E+00
 9911561     2     1     2   501     0  0.000000000E+00  0.000000000E+00  9.634420299E+02  3.176460489E+03  3.026826835E+03  0.00000E+00  9.000E+00
       2     1     3     3   501     0 -9.764825564E+02 -9.832978689E+02  1.120091442E+03  1.781852328E+03  0.000000000E+00  0.00000E+00  9.000E+00
      11     1     3     3     0     0  9.764825564E+02  9.832978689E+02 -1.566494120E+02  1.394608160E+03  5.109989100E-04  0.00000E+00  9.000E+00
#rwgt            1           1   4.3750714067884451E-004    54217137           1           0
</event>
...

9911561 is the Leptoquark 
p                py               pz               Energy           Mass
0.000000000E+00  0.000000000E+00  9.634420299E+02  3.176460489E+03  3.026826835E+03
```


## Compile Herwig package for showering of LHE events


Setup environment and LHAPDF_DATA_PATH from cvmfs (https://cernvm.cern.ch/fs/):
```
bash
source setup.sh
```

---

(Only the first time) Software needed for the installation. You can install it in local if you don't have root access (i.e. on lxplus at CERN).

Mercurial:
```
pip3 install --user mercurial
```

gengetopt: Follow instructions at https://www.gnu.org/software/gengetopt/gengetopt.html. Then add the location of the gengetopt executable to your PATH:
```
PATH=$HOME/.local/bin:/home/...../bin:$PATH
```
---

```
cd HerwigInstallation
```

Install:
```
./InstallationScript.sh
```
(it takes about 30 minutes)

Edit HerwigDefaults.rpo file:
```
emacs -nw share/Herwig/HerwigDefaults.rpo
```
Change the line starting with "/build/jenkins/workspace/lcg_release_pipeline" (line 5) with line of the local path
"/..../HerwigInstallation/lib/Herwig/" (line 8), i.e. both line 5 and line 8 should have the same content.


## Run Herwig showering in CMSSW

(Instructions for tcsh)

Start from a new terminal.

Setup CMSSW environment:
``` 
source /cvmfs/cms.cern.ch/cmsset_default.csh
```

Create CMSSW area:
```
cd  HerwigInterface
scram project -n CMSSW_10_6_28_LQGen CMSSW CMSSW_10_6_28
cd CMSSW_10_6_28_LQGen/src
cmsenv
```

(Do these following two steps after "cmsenv", otherwise the settings will be overwritten)

Setup LHAPDF_DATA_PATH (should include "LUXlep-NNPDF31_nlo_as_0118_luxqed"):
```
setenv LHAPDF_DATA_PATH /cvmfs/sft.cern.ch/lcg/external/lhapdfsets/current:/cvmfs/sft.cern.ch/lcg/releases/MCGenerators/lhapdf/6.3.0-3c8e0/x86_64-centos7-gcc8-opt/share/LHAPDF
```

Setup HERWIGPATH (custom version compiled at the previous step):
```
setenv HERWIGPATH /.../HerwigInstallation/share/Herwig
```

Create configuration file for GEN step from LHE file
```
git cms-addpkg Configuration/Generator
cp ../../singleLQ_13TeV_Pow_Herwig7_cff.py Configuration/Generator/python
scram b
cmsDriver.py Configuration/Generator/python/singleLQ_13TeV_Pow_Herwig7_cff.py --conditions auto:run2_mc -s GEN --datatier GEN -n 10 --eventcontent RAWSIM --python_filename singleLQ_13TeV_Pow_Herwig7_cfg.py --no_exec
```

Edit the "singleLQ_13TeV_Pow_Herwig7_cfg.py" config file.

1) Set the input LHE file:
```
'set LesHouchesReader:FileName pwgevents.lhe',
```
This should be the .lhe text file created in the first step (indicate the full path).

2) Set the number of events to be generated, and report frequency:
```
process.MessageLogger.cerr.FwkReport.reportEvery = 100 

process.maxEvents = cms.untracked.PSet(
        input = cms.untracked.int32(1000)
)
```

Run GEN step:
```
cmsRun singleLQ_13TeV_Pow_Herwig7_cfg.py
```

The outputs are:
"singleLQ_13TeV_Pow_Herwig7_cff_py_GEN.root" (GEN file in EDM format, 1000 events: 70 MB , about 1-2 min. on lxplus)
"InterfaceMatchboxTest-S123456790.log" (log file of Herwig processing)


# Generator level analysis on LQ events with CMSSW

(go to the main folder "LQGen")

```
mkdir GenAnalysis
cd GenAnalysis

scram project -n CMSSW_10_6_28_LQAna CMSSW CMSSW_10_6_28
cd CMSSW_10_6_28_LQAna/src
cmsenv

git clone git@github.com:CMSROMA/GenAna.git CMSROMA/GenAna
cd CMSROMA/GenAna/

scram b
```

Edit config file "python/GenAnalq_cfg.py" as needed (i.e. input file).

Run analysis:
```
cmsRun python/GenAnalq_cfg.py
```

Outputs:
```
GenAnalq.root (containing both histograms and tree)
```
