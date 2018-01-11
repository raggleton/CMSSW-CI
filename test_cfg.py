"""This does nothing except select the EDM collections with "slimmedJets" in their name"""

import FWCore.ParameterSet.Config as cms

process = cms.Process("MyTest")

process.options = cms.untracked.PSet(wantSummary = cms.untracked.bool(True))
process.options.allowUnscheduled = cms.untracked.bool(False) 

process.load("FWCore.MessageLogger.MessageLogger_cfi")
process.MessageLogger.cerr.FwkReport.reportEvery = 10

process.analysis = cms.Path()

# INPUT
process.source = cms.Source("PoolSource",
    secondaryFileNames = cms.untracked.vstring(),
    fileNames = cms.untracked.vstring('file:2017B_JetHT_EC3BBDF0-C7CD-E711-A70B-0025905A6092_small.root'),
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
