BNote: the file forCMS.tar is the one originally provided by the theorist in April 2021 (i.e. before the changes committed in this repository).

# Make main directory

```
mkdir generateLQ
cd generateLQ
```

# Install POWHEG-BOX-RES

Take the code from the repository:
```
svn checkout --username anonymous --password anonymous svn://powhegbox.mib.infn.it/trunk/POWHEG-BOX-RES
```

# Clone repository

Clone the repository in a new folder:
```
git clone git@github.com:CMSROMA/LQGen.git
cd LQGen
```

# Generate LQ events with POWHEG+HERWIG

## Compile POWHEG-BOX-RES

Setup environment and LHAPDF_DATA_PATH from cvmfs (https://cernvm.cern.ch/fs/):
```
bash
source setup.sh
```

Add necessary empty directories:
```
mkdir include
mkdir obj-gfortran
```

Compile after changing the location of your POWHEG-BOX-RES in MakeFile (RES=/afs/cern.ch/work/c/ccaillol/generateLQ_newModel/POWHEG-BOX-RES):
```
make
```

## Generate Leptoquark events in LHE format

Create a new folder for each signal hypothesis:
```
mkdir LQumu_M3000_Lambda1p0
cp testrun/powheg.input-NLO LQumu_M3000_Lambda1p0/powheg.input
cd LQumu_M3000_Lambda1p0
```

Edit the configuration (powheg.input).
Below an example to create a LQ with u+mu coupling and charge 1/3 (i.e. in the config y_1m=1.0 and charge = 1/3 * 3 = 1)
```

# LQ parameters
mLQ 3000   ! Mass of the LQ


numevts 100     ! number of events to be generated

# LQ couplings

!  / y_1e y_1m y_1t \    u/d
!  | y_2e y_2m y_2t |    c/s
!  \ y_3e y_3m y_3t /    t/b

y_1e 0
y_2e 0
y_3e 0
y_1m 1.0
y_2m 0
y_3m 0
y_1t 0
y_2t 0
y_3t 0

charge 1    ! Set this to the charge of the desired LQ's absolute charge times 3. Expect 1, 5 (for up-type quarks) or 2, 4 (for down-type quarks)

```

Generate events:
```
../pwhg_main 
```

The output file is pwgevents.lhe. (MLQ=3000 GeV, y_1m=1.0, charge = 1, 100 events, 0.25 MB). A typical event:
```
<init>
     2212     2212  6.50000E+03  6.50000E+03     -1     -1     -1     -1     -4      1
  5.66914E-04  2.70456E-07  1.00000E+00   2000
</init>
<event>
      6   2000  5.72273E-04  2.29099E+02 -1.00000E+00  1.09546E-01
      13    -1     0     0     0     0  0.000000000E+00  0.000000000E+00  1.497596761E+03  1.497596761E+03  0.000000000E+00  0.00000E+00  9.000E+00
       2    -1     0     0   511     0  0.000000000E+00  0.000000000E+00 -1.743563962E+03  1.743563962E+03  0.000000000E+00  0.00000E+00  9.000E+00
 9911561     2     1     2   501     0 -1.820140531E+02  1.391297968E+02 -2.072545192E+02  3.008814242E+03  2.992912042E+03  0.00000E+00  9.000E+00
      21     1     1     2   511   501  1.820140531E+02 -1.391297968E+02 -3.871268193E+01  2.323464818E+02  4.396221379E-06  0.00000E+00  9.000E+00
       2     1     3     3   501     0  6.152253429E+02  6.364104164E+02 -1.296781053E+03  1.570083291E+03  0.000000000E+00  0.00000E+00  9.000E+00
      13     1     3     3     0     0 -7.972393960E+02 -4.972806197E+02  1.089526534E+03  1.438730951E+03  1.050000000E-01  0.00000E+00  9.000E+00
#rwgt            1           1   3.0282270117710407E-004    54217137    24108698           0           1           0
<weights>
0.57227E-03
0.63668E-03
0.58882E-03
0.65149E-03
0.51160E-03
....

<event>
      6   2000  5.72273E-04  2.83713E+01 -1.00000E+00  1.54629E-01
       2    -1     0     0   501     0  0.000000000E+00  0.000000000E+00  2.651952096E+03  2.651952096E+03  0.000000000E+00  0.00000E+00  9.000E+00
      22    -1     0     0     0     0  0.000000000E+00  0.000000000E+00 -1.118921947E+03  1.118921947E+03  0.000000000E+00  0.00000E+00  9.000E+00
 9911561     2     1     2   501     0 -2.819245267E+01 -3.180888494E+00  1.796852952E+03  3.505530087E+03  3.009859752E+03  0.00000E+00  9.000E+00
     -13     1     1     2     0     0  2.819245267E+01  3.180888494E+00 -2.638228034E+02  2.653439561E+02  1.050000000E-01  0.00000E+00  9.000E+00
       2     1     3     3   501     0  3.388162995E+02  1.395742306E+03  1.400208563E+03  2.005860686E+03  0.000000000E+00  0.00000E+00  9.000E+00
      13     1     3     3     0     0 -3.670087522E+02 -1.398923195E+03  3.966443892E+02  1.499669401E+03  1.050000000E-01  0.00000E+00  9.000E+00
#rwgt            1           2   4.8889441859415145E-004    54217137    24108855           0           1           0
<weights>
0.57227E-03
0.54891E-03
0.57044E-03
0.54060E-03
0.61519E-03
...

9911561 is the Leptoquark 
px                py               pz               Energy           Mass
-1.820140531E+02  1.391297968E+02 -2.072545192E+02  3.008814242E+03  2.992912042E+03
```

### Generate a chosen set of mass and coupling and split the lhe file

edit the file make_LHE.sh
```
LQPROCESS=LeptonInducedLQ_umu
INPUTPOWHEG=testrun/powheg.input-NLO
Mass=( 1000 2000 3000 )
Y=( 0p1 1p0 )


OUTPUTDIR=/afs/cern.ch/work/s/santanas/Workspace/CMS/generateLQ_NLO/LQGen
evts=1000
evtsperfile=100
```

You also need to replace y_1m by the coupling you want to modify if not generating umu. 

The mass values have to be integer number in GeV (es. 1000 2000). The coupling values (l) have to be written with a p to instead of the dot (es 0p1 for 0.1). 
**There has to be a blank between each value of mass and coupling es Mass=( 1000 2000 3000 )**


To run the script
```
./make_LHE.sh
```

At the end the LHE file is automatically splitted in several files each with a number of events equal to "evtsperfile" (except the last one that might have a smaller number depending on the integer match). A ".list" file is also created with the list of all the splitted lhe files for a given sample (the list is stored inside the folder of each sample inside the "split" directory):

```
bash-4.2$ ls LeptonInducedLQ_umu_M3000_Lambda1p0/
FlavRegList			 pwgalone-output.top  pwg-NLO.top		  pwgubound.dat     pwhg_checklimits	sigvirtual_equiv
LeptonInducedLQ_umu_M3000_Lambda1p0.lhe  pwgcounters.dat      pwg-none-borngrid-stat.dat  pwgxgrid-btl.dat  sigreal_btl0_equiv split
powheg.input pwghistnorms.top     pwg-stat.dat    pwgxgrid-rm.dat   sigreal_rad_equiv

bash-4.2$ ls LeptonInducedLQ_umu_M3000_Lambda1p0/split/
LeptonInducedLQ_umu_M3000_Lambda1p0__10.lhe  LeptonInducedLQ_umu_M3000_Lambda1p0__4.lhe  LeptonInducedLQ_umu_M3000_Lambda1p0__8.lhe
LeptonInducedLQ_umu_M3000_Lambda1p0__1.lhe   LeptonInducedLQ_umu_M3000_Lambda1p0__5.lhe  LeptonInducedLQ_umu_M3000_Lambda1p0__9.lhe
LeptonInducedLQ_umu_M3000_Lambda1p0__2.lhe   LeptonInducedLQ_umu_M3000_Lambda1p0__6.lhe  LeptonInducedLQ_umu_M3000_Lambda1p0.list
LeptonInducedLQ_umu_M3000_Lambda1p0__3.lhe   LeptonInducedLQ_umu_M3000_Lambda1p0__7.lhe
```

### Format the LHE files

The LHE files produced above need to be edited 1) to remove the forbidden string "#--" and 2) to have uncertainties stored in a CMS-readable format. Edit "EditLHE.py" with the location of your files and sets of mass and coupling points, then from any CMSSW area run: 
```
python EditLHE.py
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

gengetopt: Follow instructions at https://www.gnu.org/software/gengetopt/gengetopt.html. Then add the location of the gengetopt executable to your PATH.

For example:
```
wget https://ftp.gnu.org/gnu/gengetopt/gengetopt-2.23.tar.xz .
tar -xvf gengetopt-2.23.tar.xz
cd gengetopt-2.23
./configure --prefix=/afs/cern.ch/work/s/santanas  
make
make install
```
Then in the ~/.tcshrc file:
```
setenv PATH "/afs/cern.ch/work/s/santanas/bin:$PATH"
```

It should work also in the ~/.local directory (instead of /afs/cern.ch/work/s/santanas).

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

TO BE CHECKED IF NEEDED!!!
IMPORTANT: Change the line starting with "/build/jenkins/workspace/lcg_release_pipeline" (line 5) with line of the local path
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

Setup HERWIGPATH (custom version compiled at the previous step, the folder where the file HerwigDefaults.rpo is present):
```
setenv HERWIGPATH /afs/cern.ch/work/s/santanas/Workspace/CMS/generateLQ_NLO/LQGen/HerwigInstallation/share/Herwig
```

Create/edit configuration file for GEN step from LHE file. 

Depending on the year, different global tags and configurations should be used (check the cfg files for 2016, 2016APV, 2017, or 2018).
The config files templates are in the HerwigInterface folder: 
```
config_LQ_Herwig_2016APV_cfg.py  config_LQ_Herwig_2016_cfg.py     config_LQ_Herwig_2017_cfg.py     config_LQ_Herwig_2018_cfg.py
```
The ID of the LQ depends on the couplings/charge generated, and needs to be modified in the cfg file.
Below is the part of the config file that should be modified by adding the LQ id (in this case 9911561). 
You can check the id in the LHE files produced with POWHEG in previosu step.
```
'create /ThePEG/ParticleData S0bar',
'setup S0bar 9911561 S0bar 400.0 0.0 0.0 0.0 -1 3 1 0',
'create /ThePEG/ParticleData S0',
'setup S0 -9911561 S0 400.0 0.0 0.0 0.0 1 -3 1 0',
'makeanti S0bar S0',
```

Prepare the area for running, from "CMSSW_10_6_28_LQGen/src" folder:

```
git cms-addpkg Configuration/Generator
cp ../../config_LQ_Herwig_2018_cfg.py .
cp ../../make_GEN.py .
scram b
```

Run GEN step for a single sample:
```
cmsRun config_LQ_Herwig_2018_cfg.py files=/afs/cern.ch/work/s/santanas/Workspace/CMS/generateLQ_NLO/LQGen/LeptonInducedLQ_umu_M3000_Lambda1p0/split/LeptonInducedLQ_mod_umu_M3000_Lambda1p0__1.lhe output=LeptonInducedLQ_mod_umu_M3000_Lambda1p0__1.root maxEvents=100
```
Note: The .lhe text file should be the one created in the first step, after the editing (indicate the full path).

-------------- Below things should be checked

The outputs are:
"LeptonInducedLQ_mod_umu_M3000_Lambda1p0__1.root" (GEN file in EDM format, 1000 events: 70 MB , about 1-2 min. on lxplus)
"InterfaceMatchboxTest-S123456790.log" (log file of Herwig processing)

This is a script to run the GEN step on several samples, by providing a list of LHE files.
```
python make_GEN.py -i $CURRENTWORKDIR/SingleLQ_ueLQue_M2000_Lambda1p0/split/SingleLQ_ueLQue_M2000_Lambda1p0.list -o /afs/cern.ch/work/s/santanas/Workspace/CMS/LQGen/HerwigInterface/CMSSW_10_6_28_LQGen/src/SingleLQ_ueLQue_M2000_Lambda1p0__GEN -s config_utau_2016_cfg.py -n 10
```

At the end, a ".list" file is created in the output directory with the list of all the GEN files. Ex. :
```
[santanas@lxplus789 src]$ ls /afs/cern.ch/work/s/santanas/Workspace/CMS/LQGen/HerwigInterface/CMSSW_10_6_28_LQGen/src/SingleLQ_ueLQue_M2000_Lambda1p0__GEN
SingleLQ_ueLQue_M2000_Lambda1p0__GEN.list  SingleLQ_ueLQue_M2000_Lambda1p0__2.root  SingleLQ_ueLQue_M2000_Lambda1p0__5.root  SingleLQ_ueLQue_M2000_Lambda1p0__8.root
SingleLQ_ueLQue_M2000_Lambda1p0__1.root    SingleLQ_ueLQue_M2000_Lambda1p0__3.root  SingleLQ_ueLQue_M2000_Lambda1p0__6.root  SingleLQ_ueLQue_M2000_Lambda1p0__9.root
SingleLQ_ueLQue_M2000_Lambda1p0__10.root   SingleLQ_ueLQue_M2000_Lambda1p0__4.root  SingleLQ_ueLQue_M2000_Lambda1p0__7.root
```

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

For more details go in the package area: git@github.com:CMSROMA/GenAna.git
