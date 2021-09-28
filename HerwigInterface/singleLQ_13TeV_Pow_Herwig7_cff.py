import FWCore.ParameterSet.Config as cms

#from Configuration.Generator.TTbar_Pow_LHE_13TeV_cff import externalLHEProducer
#from Configuration.Generator.Herwig7Settings.Herwig7CH3TuneSettings_cfi import *
#from Configuration.Generator.Herwig7Settings.Herwig7StableParticlesForDetector_cfi import *
#from Configuration.Generator.Herwig7Settings.Herwig7LHECommonSettings_cfi import *
#from Configuration.Generator.Herwig7Settings.Herwig7LHEPowhegSettings_cfi import *


herwig7SingleLQBlock = cms.PSet(
    herwig7SingleLQ = cms.vstring(
        #'herwig7CH3PDF',   
        #     
        #'herwig7CH3AlphaS',
        'cd /Herwig/Shower', 
        'set AlphaQCD:AlphaIn 0.118', 
        'cd /',
        #'herwig7CH3MPISettings',
        'set /Herwig/Hadronization/ColourReconnector:ReconnectionProbability 0.4712', 
        'set /Herwig/UnderlyingEvent/MPIHandler:pTmin0 3.04', 
        'set /Herwig/UnderlyingEvent/MPIHandler:InvRadius 1.284', 
        'set /Herwig/UnderlyingEvent/MPIHandler:Power 0.1362',
        #'herwig7StableParticlesForDetector',
        'set /Herwig/Decays/DecayHandler:MaxLifeTime 10*mm', 
        'set /Herwig/Decays/DecayHandler:LifeTimeOption Average',
        #'hw_lhe_common_settings',
        'cd /Herwig/EventHandlers', 
        'library LesHouches.so', 

        'create /ThePEG/ParticleData S0bar',
        'setup S0bar 9911561 S0bar 400.0 0.0 0.0 0.0 -1 3 1 0',
        'create /ThePEG/ParticleData S0',
        'setup S0 -9911561 S0 400.0 0.0 0.0 0.0 1 -3 1 0',
        'makeanti S0bar S0',

        'create ThePEG::LesHouchesEventHandler LesHouchesHandler', 
        'set LesHouchesHandler:PartonExtractor /Herwig/Partons/PPExtractor', 
        'set LesHouchesHandler:CascadeHandler /Herwig/Shower/ShowerHandler', 
        'set LesHouchesHandler:DecayHandler /Herwig/Decays/DecayHandler', 
        'set LesHouchesHandler:HadronizationHandler /Herwig/Hadronization/ClusterHadHandler', 
        'set LesHouchesHandler:WeightOption VarNegWeight', 
        'set /Herwig/Generators/EventGenerator:EventHandler /Herwig/EventHandlers/LesHouchesHandler', 
        'create ThePEG::Cuts /Herwig/Cuts/NoCuts', 
        'create ThePEG::LHAPDF /Herwig/Partons/LHAPDF ThePEGLHAPDF.so', 

        'set /Herwig/Partons/LHAPDF:PDFName LUXlep-NNPDF31_nlo_as_0118_luxqed', 
        'set /Herwig/Partons/RemnantDecayer:AllowTop Yes',
        'set /Herwig/Partons/RemnantDecayer:AllowLeptons Yes', 

        'set /Herwig/Partons/LHAPDF:RemnantHandler /Herwig/Partons/HadronRemnants', 
        'set /Herwig/Particles/p+:PDF /Herwig/Partons/LHAPDF', 
        'set /Herwig/Particles/pbar-:PDF /Herwig/Partons/LHAPDF', 
        'set /Herwig/Partons/PPExtractor:FirstPDF  /Herwig/Partons/LHAPDF', 
        'set /Herwig/Partons/PPExtractor:SecondPDF /Herwig/Partons/LHAPDF', 
        'set /Herwig/Shower/ShowerHandler:PDFA /Herwig/Partons/LHAPDF', 
        'set /Herwig/Shower/ShowerHandler:PDFB /Herwig/Partons/LHAPDF', 
        'set /Herwig/Shower/ShowerHandler:PDFARemnant /Herwig/Partons/LHAPDF', 
        'set /Herwig/Shower/ShowerHandler:PDFBRemnant /Herwig/Partons/LHAPDF', 
        'set /Herwig/Shower/ShowerHandler:HardEmission 0', 
        #'set /Herwig/Generators/EventGenerator:EventHandler:CascadeHandler:MPIHandler NULL', 

        'set /Herwig/Particles/e-:PDF /Herwig/Partons/NoPDF', 
        'set /Herwig/Particles/e+:PDF /Herwig/Partons/NoPDF', 

        'create ThePEG::LesHouchesFileReader LesHouchesReader', 
        #'set LesHouchesReader:FileName cmsgrid_final.lhe', 
        'set LesHouchesReader:FileName pwgevents.lhe', 
        'set LesHouchesReader:AllowedToReOpen No', 
        'set LesHouchesReader:InitPDFs 0', 
        'set LesHouchesReader:Cuts /Herwig/Cuts/NoCuts', 
        'set LesHouchesReader:MomentumTreatment RescaleEnergy', 
        'set LesHouchesReader:PDFA /Herwig/Partons/LHAPDF', 
        'set LesHouchesReader:PDFB /Herwig/Partons/LHAPDF', 
        'insert LesHouchesHandler:LesHouchesReaders 0 LesHouchesReader', 
        'set /Herwig/Shower/ShowerHandler:MaxPtIsMuF Yes', 
        'set /Herwig/Shower/ShowerHandler:RestrictPhasespace Yes', 
        'set /Herwig/Shower/ShowerHandler:Interactions QCDandQED',
        'set /Herwig/Shower/PartnerFinder:PartnerMethod Random', 
        'set /Herwig/Shower/PartnerFinder:ScaleChoice Partner',
        #'hw_lhe_powheg_settings'
        'set /Herwig/Shower/ShowerHandler:MaxPtIsMuF Yes', 
        'set /Herwig/Shower/ShowerHandler:RestrictPhasespace Yes', 
        'set /Herwig/Shower/PartnerFinder:PartnerMethod Random', 
        'set /Herwig/Shower/PartnerFinder:ScaleChoice Partner', 
        'set /Herwig/Particles/t:NominalMass 172.5'
        )
)

generator = cms.EDFilter("Herwig7GeneratorFilter",
    #herwig7CH3SettingsBlock,
    #herwig7StableParticlesForDetectorBlock,
    #herwig7LHECommonSettingsBlock,
    #herwig7LHEPowhegSettingsBlock,
    herwig7SingleLQBlock,
    configFiles = cms.vstring(),
    parameterSets = cms.vstring(
        'herwig7SingleLQ',
    ),
    crossSection = cms.untracked.double(-1),
    dataLocation = cms.string('${HERWIGPATH:-6}'),
    eventHandlers = cms.string('/Herwig/EventHandlers'),
    filterEfficiency = cms.untracked.double(1.0),
    generatorModule = cms.string('/Herwig/Generators/EventGenerator'),
    repository = cms.string('${HERWIGPATH}/HerwigDefaults.rpo'),
    run = cms.string('InterfaceMatchboxTest'),
    runModeList = cms.untracked.string("read,run"),
    seed = cms.untracked.int32(12345)
)

ProductionFilterSequence = cms.Sequence(generator)
