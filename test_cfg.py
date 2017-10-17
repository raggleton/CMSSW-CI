import FWCore.ParameterSet.Config as cms

process = cms.Process("TravisTest")

process.options = cms.untracked.PSet(wantSummary = cms.untracked.bool(True))
process.options.allowUnscheduled = cms.untracked.bool(False) 

process.load("FWCore.MessageLogger.MessageLogger_cfi")
process.MessageLogger.cerr.FwkReport.reportEvery = 10

process.load('Configuration.StandardSequences.FrontierConditions_GlobalTag_condDBv2_cff')
process.load("Configuration.StandardSequences.GeometryRecoDB_cff")
process.load('RecoMET.METFilters.BadChargedCandidateFilter_cfi')
process.load('RecoMET.METFilters.BadPFMuonFilter_cfi')

process.GlobalTag.globaltag = '80X_mcRun2_asymptotic_2016_TrancheIV_v8'
process.BadChargedCandidateFilter.muons = cms.InputTag("slimmedMuons")
process.BadChargedCandidateFilter.PFCandidates = cms.InputTag("packedPFCandidates")
process.BadPFMuonFilter.muons = cms.InputTag("slimmedMuons")
process.BadPFMuonFilter.PFCandidates = cms.InputTag("packedPFCandidates")

# EXAMPLE PATH
process.analysis = cms.Path(process.BadChargedCandidateFilter + process.BadPFMuonFilter)

# INPUT
process.source = cms.Source("PoolSource",
    secondaryFileNames = cms.untracked.vstring(),
    fileNames = cms.untracked.vstring('file:ttbar_miniaodsim_summer16_v2_PUMoriond17_80X.root'),
)

# OUTPUT
process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(50)
)

process.MINIAODSIMoutput = cms.OutputModule("PoolOutputModule",
    outputCommands = cms.untracked.vstring("keep *_slimmedJets*_*_*"),
    fileName = cms.untracked.string("patTuple.root")
)
process.MINIAODSIMoutput_step = cms.EndPath(process.MINIAODSIMoutput)
