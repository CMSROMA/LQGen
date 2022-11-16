# Auto generated configuration file
# using: 
# Revision: 1.19 
# Source: /local/reps/CMSSW/CMSSW/Configuration/Applications/python/ConfigBuilder.py,v 
# with command line options: Configuration/Generator/python/singleLQ_13TeV_Pow_Herwig7_cff.py --conditions auto:run2_mc -s GEN --datatier GEN -n 10 --eventcontent RAWSIM --python_filename singleLQ_13TeV_Pow_Herwig7_cfg.py --no_exec
import FWCore.ParameterSet.Config as cms

import FWCore.ParameterSet.VarParsing as VarParsing

process = cms.Process('GEN')

# setup 'standard'  options
options = VarParsing.VarParsing('standard')
## setup any defaults you want
options.files = "/eos/cms/store/group/phys_exotica/lq-LQ-lq/test_GEN_1/singleLQ_13TeV_Pow_M2000_Lambda1p0.lhe"
options.output = "singleLQ_13TeV_Pow_Herwig7_M2000_Lambda0p1_GEN.root"
options.maxEvents = -1
options.parseArguments()

process.source = cms.Source("LHESource",
    fileNames = cms.untracked.vstring("file:"+str(options.files).split("'")[1]),
)

# import of standard configurations
process.load('Configuration.StandardSequences.Services_cff')
process.load('SimGeneral.HepPDTESSource.pythiapdt_cfi')
process.load('FWCore.MessageService.MessageLogger_cfi')
process.load('Configuration.EventContent.EventContent_cff')
process.load('SimGeneral.MixingModule.mixNoPU_cfi')
process.load('Configuration.StandardSequences.GeometryRecoDB_cff')
process.load('Configuration.StandardSequences.MagneticField_cff')
process.load('Configuration.StandardSequences.Generator_cff')
process.load('IOMC.EventVertexGenerators.VtxSmearedRealistic25ns13TeV2016Collision_cfi')
process.load('GeneratorInterface.Core.genFilterSummary_cff')
process.load('Configuration.StandardSequences.EndOfProcess_cff')
process.load('Configuration.StandardSequences.FrontierConditions_GlobalTag_cff')

process.MessageLogger.cerr.FwkReport.reportEvery = 100

process.maxEvents = cms.untracked.PSet(
        input = cms.untracked.int32(options.maxEvents)
)

process.options = cms.untracked.PSet(

)

# Production Info
process.configurationMetadata = cms.untracked.PSet(
    annotation = cms.untracked.string('Configuration/Generator/python/singleLQ_13TeV_Pow_Herwig7_cff.py nevts:10'),
    name = cms.untracked.string('Applications'),
    version = cms.untracked.string('$Revision: 1.19 $')
)

# Output definition

process.RAWSIMoutput = cms.OutputModule("PoolOutputModule",
    SelectEvents = cms.untracked.PSet(
        SelectEvents = cms.vstring('generation_step')
    ),
    compressionAlgorithm = cms.untracked.string('LZMA'),
    compressionLevel = cms.untracked.int32(1),
    dataset = cms.untracked.PSet(
        dataTier = cms.untracked.string('GEN'),
        filterName = cms.untracked.string('')
    ),
    eventAutoFlushCompressedSize = cms.untracked.int32(20971520),
    fileName = cms.untracked.string(options.output),
    outputCommands = process.RAWSIMEventContent.outputCommands,
    splitLevel = cms.untracked.int32(0)
)

# Additional output definition

# Other statements
process.genstepfilter.triggerConditions=cms.vstring("generation_step")
from Configuration.AlCa.GlobalTag import GlobalTag
process.GlobalTag = GlobalTag(process.GlobalTag, '106X_mcRun2_asymptotic_v13', '')

process.generator = cms.EDFilter("Herwig7GeneratorFilter",
    configFiles = cms.vstring(),
    crossSection = cms.untracked.double(-1),
    dataLocation = cms.string('${HERWIGPATH:-6}'),
    eventHandlers = cms.string('/Herwig/EventHandlers'),
    filterEfficiency = cms.untracked.double(1.0),
    generatorModule = cms.string('/Herwig/Generators/EventGenerator'),
    herwig7SingleLQ = cms.vstring(
        'cd /Herwig/Shower', 
        'set AlphaQCD:AlphaIn 0.118', 
        'cd /', 
        'set /Herwig/Hadronization/ColourReconnector:ReconnectionProbability 0.4712', 
        'set /Herwig/UnderlyingEvent/MPIHandler:pTmin0 3.04', 
        'set /Herwig/UnderlyingEvent/MPIHandler:InvRadius 1.284', 
        'set /Herwig/UnderlyingEvent/MPIHandler:Power 0.1362', 
        'set /Herwig/Decays/DecayHandler:MaxLifeTime 10*mm', 
        'set /Herwig/Decays/DecayHandler:LifeTimeOption Average', 
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
        'set /Herwig/Particles/e-:PDF /Herwig/Partons/NoPDF', 
        'set /Herwig/Particles/e+:PDF /Herwig/Partons/NoPDF', 
        'create ThePEG::LesHouchesFileReader LesHouchesReader', 
        'set LesHouchesReader:FileName %s' % options.files[0], 
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
        'set /Herwig/Shower/ShowerHandler:MaxPtIsMuF Yes', 
        'set /Herwig/Shower/ShowerHandler:RestrictPhasespace Yes', 
        'set /Herwig/Shower/PartnerFinder:PartnerMethod Random', 
        'set /Herwig/Shower/PartnerFinder:ScaleChoice Partner', 
        'set /Herwig/Particles/t:NominalMass 172.5'
    ),
    parameterSets = cms.vstring('herwig7SingleLQ'),
    repository = cms.string('${HERWIGPATH}/HerwigDefaults.rpo'),
    run = cms.string('InterfaceMatchboxTest'),
    runModeList = cms.untracked.string('read,run'),
    seed = cms.untracked.int32(12345)
)


process.ProductionFilterSequence = cms.Sequence(process.generator)

# Path and EndPath definitions
process.generation_step = cms.Path(process.pgen)
process.genfiltersummary_step = cms.EndPath(process.genFilterSummary)
process.endjob_step = cms.EndPath(process.endOfProcess)
process.RAWSIMoutput_step = cms.EndPath(process.RAWSIMoutput)

# Schedule definition
process.schedule = cms.Schedule(process.generation_step,process.genfiltersummary_step,process.endjob_step,process.RAWSIMoutput_step)
from PhysicsTools.PatAlgos.tools.helpers import associatePatAlgosToolsTask
associatePatAlgosToolsTask(process)
# filter all path with the production filter sequence
for path in process.paths:
	getattr(process,path).insert(0, process.ProductionFilterSequence)


# Customisation from command line

# Add early deletion of temporary data products to reduce peak memory need
from Configuration.StandardSequences.earlyDeleteSettings_cff import customiseEarlyDelete
process = customiseEarlyDelete(process)
# End adding early deletion
