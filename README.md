Note: the file forCMS.tar is the one originally provided by the theorist in April 2021 (i.e. before the changes committed in this repository).

# Clone repository

Clone the repository in a new folder:
```
git clone git@github.com:CMSROMA/LQGen.git
cd LQGen
```

# Generate LQ events with POWHEG

## Install POWHEG-BOX-V2

Take the code from the repository:
```
svn checkout --username anonymous --password anonymous svn://powhegbox.mib.infn.it/trunk/POWHEG-BOX-V2
```

Setup environment and LHAPDF_DATA_PATH from cvmfs (https://cernvm.cern.ch/fs/):
```
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








