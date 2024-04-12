//
//  File.swift
//  
//
//  Created by stu on 12/04/2024.
//

import Foundation

let EXPANDED_MIDI_CHANNEL_COUNT = 128

extension Array where Element: Equatable {
    func removingDuplicates() -> [Element] {
        var out: Self = []
        self.forEach { e in
            if !out.contains(e) {
                out.append(e)
            }
        }
        return out
        
        
//        var addedDict = [Element: Bool]()
//        return filter {
//            addedDict.updateValue(true, forKey: $0) == nil
//        }
    }
}

public class MIDIJSONFileExport {
    public struct MIDIJSONData: Codable {
        let midiNoteEvents:     [MIDIJSONNoteEventData]
        let ccData:             [MIDIJSONCCData]
        let tempoData:          [MIDIJSONTempoChangeData]
        let programChangeData:  [MIDIJSONPatchChangeData]
        
        public init(
            midiNoteEvents: [MIDIJSONNoteEventData],
            ccData: [MIDIJSONCCData],
            tempoData: [MIDIJSONTempoChangeData],
            programChangeData: [MIDIJSONPatchChangeData]
        ) {
            self.midiNoteEvents = midiNoteEvents
            self.ccData = ccData
            self.tempoData = tempoData
            self.programChangeData = programChangeData
        }
    }
    
    public struct ChannelledNoteEventData { let channel: Int, noteEventsData: [MIDIJSONNoteEventData]}
    public struct SparseMIDIFileData: Encodable {}
    
    var PRINT_THIS = false
    
    private var collectedMidiNoteEvents:    [MIDIJSONNoteEventData] = []
    private var collectedCCData:            [MIDIJSONCCData] = []
    private var collectedTempoData:         [MIDIJSONTempoChangeData] = []
    private var collectedProgramChangeData: [MIDIJSONPatchChangeData] = []
    
    /// weeds out empty channels
    public var prunedMIDIFileData: [MIDIJSONData] {
        let channelOrderedMidiNoteEvents    = (0..<EXPANDED_MIDI_CHANNEL_COUNT).map { ch in
            collectedMidiNoteEvents.removingDuplicates()
                .filter { event in ch == event.channelNumber }
        }
        let channelOrderedCCMsgs            = (0..<EXPANDED_MIDI_CHANNEL_COUNT).map { ch in
            collectedCCData.filter { cc in ch == cc.channelNumber }
        }
        let channelOrderedProgramChangeMsgs = (0..<EXPANDED_MIDI_CHANNEL_COUNT).map { ch in
            collectedProgramChangeData.filter { pc in ch == pc.channelNumber }
        }
        
        let groupsCount = EXPANDED_MIDI_CHANNEL_COUNT / 16
        let dataPerDevice = (0..<groupsCount).map { deviceIdx in
            let channelRangeLo = deviceIdx * 16
            let channelRangeHi = channelRangeLo + 15
            
            let thisGroupMIDINoteEvents = channelOrderedMidiNoteEvents.enumerated()
                .filter { arrayIdx, channelNotesArray in
                    arrayIdx >= channelRangeLo && arrayIdx <= channelRangeHi
                }
                .map { $0.element }.reduce([], +)
                .map { $0.normalizedMIDIChannel }
            
            let thisGroupProgramChangeMsgs = channelOrderedProgramChangeMsgs.enumerated()
                .filter { arrayIdx, programChangesArray in
                    arrayIdx >= channelRangeLo && arrayIdx <= channelRangeHi
                }
                .map { $0.element }.reduce([], +)
                .map { $0.normalizedMIDIChannel }
            
            let thisGroupCCMsgs = channelOrderedCCMsgs.enumerated()
                .filter { arrayIdx, programChangesArray in
                    arrayIdx >= channelRangeLo && arrayIdx <= channelRangeHi
                }
                .map { $0.element }.reduce([], +)
                .map { $0.normalizedMIDIChannel}
            
            let thisGroupTempoData = collectedTempoData // because each file will need tempo data for its own rendering
            
            return (thisGroupMIDINoteEvents, thisGroupProgramChangeMsgs, thisGroupCCMsgs, thisGroupTempoData)
        }
            .filter { $0.0.count > 0 } // notes array is not empty
        
        let midiFileDataArray = dataPerDevice.map { deviceData in
            let midiFileNoteEventsDataArray = deviceData.0
            let patchChangeDataArray        = deviceData.1
            let midiFileCCDataArray         = deviceData.2
            let midiFileTempoChangeData     = deviceData.3
            
//            print("DEVICE:", "notes", midiFileNoteEventsDataArray.count, "patches", patchChangeDataArray.count, "ccs", midiFileCCDataArray.count, "tempi", deviceData.3.count)
//            print("notes")
//            for noteEventData in midiFileNoteEventsDataArray { print(noteEventData) }
            
            let channelsPresent = Set(midiFileNoteEventsDataArray.map { $0.channelNumber })
//            print("channelsPresent: \(channelsPresent)")
            
            print("cc's")
            //strip out cc's for channels that have no note events
            let relevantCCs = Set(midiFileCCDataArray).filter { channelsPresent.contains($0.channelNumber)}
            for cc in relevantCCs { print(cc) }

            print("patches")
            //strip out patch changes for channels that have no note events
            let relevantPatchChanges = Set(patchChangeDataArray).filter { channelsPresent.contains($0.channelNumber)}
            for patch in relevantPatchChanges { print(patch) }
            
            print("tempo changes")
            for tempo in midiFileTempoChangeData { print(tempo) }
            
            let deviceMIDIFileData = MIDIJSONData(
                midiNoteEvents:     midiFileNoteEventsDataArray,
                ccData:             Array(relevantCCs),
                tempoData:          midiFileTempoChangeData,
                programChangeData:  Array(relevantPatchChanges)
            )
            
            return deviceMIDIFileData
        }
        return midiFileDataArray
    }
    
    var exportMIDIFileCallback: (
        (String,
         [MIDIJSONPatchChangeData],
         [MIDIJSONNoteEventData],
         [MIDIJSONCCData],
         [MIDIJSONTempoChangeData]
        ) -> Void)?
    
    public init(exportMIDIFileCallback: ((
        String,
        [MIDIJSONPatchChangeData],
        [MIDIJSONNoteEventData],
        [MIDIJSONCCData],
        [MIDIJSONTempoChangeData]
    ) -> Void)?
    ) {
        self.exportMIDIFileCallback = exportMIDIFileCallback
    }
    
    public func outputMIDINoteEventData(_ data: MIDIJSONNoteEventData) {
        collectedMidiNoteEvents.append(data)
    }
    
    public func outputCCMidiMessage(_ msgData: MIDIJSONCCData) {
        collectedCCData.append(msgData)
    }
    
    public func outputTempoCallback(_ tempoChangeData: MIDIJSONTempoChangeData) {
        collectedTempoData.append(tempoChangeData)
    }
    
    public func outputPatchChangeCallback(_ patchChangeData: MIDIJSONPatchChangeData) {
        collectedProgramChangeData.append(patchChangeData)
    }

    public func onMIDIDataComplete() {
        //split into groups of 16
        let channelOrderedMidiNoteEvents    = (0..<EXPANDED_MIDI_CHANNEL_COUNT).map { ch in
            collectedMidiNoteEvents.filter { event in ch == event.channelNumber }
        }
        let channelOrderedCCMsgs            = (0..<EXPANDED_MIDI_CHANNEL_COUNT).map { ch in
            collectedCCData.filter { cc in ch == cc.channelNumber }
        }
        let channelOrderedProgramChangeMsgs = (0..<EXPANDED_MIDI_CHANNEL_COUNT).map { ch in
            collectedProgramChangeData.filter { pc in ch == pc.channelNumber }
        }
    
        let groupsCount = EXPANDED_MIDI_CHANNEL_COUNT / 16
        (0..<groupsCount).forEach { deviceIdx in
            let groupRangeLo = deviceIdx * 16
            let groupRangeHi = groupRangeLo + 16
            
            let thisGroupMIDINoteEvents = channelOrderedMidiNoteEvents.enumerated()
                .filter { arrayIdx, channelNotesArray in
                    arrayIdx >= groupRangeLo && arrayIdx < groupRangeHi
                }
                .map { $0.element }
                .reduce([], +)
                .map { $0.normalizedMIDIChannel }
                        
            if !thisGroupMIDINoteEvents.isEmpty {
                let thisGroupProgramChangeMsgs = channelOrderedProgramChangeMsgs.enumerated()
                    .filter { arrayIdx, programChangesArray in
                        arrayIdx >= groupRangeLo && arrayIdx < groupRangeHi
                    }
                    .map { $0.element }
                    .reduce([], +)
                    .map { $0.normalizedMIDIChannel }
                
                let thisGroupCCMsgs = channelOrderedCCMsgs.enumerated()
                    .filter { arrayIdx, programChangesArray in
                        arrayIdx >= groupRangeLo && arrayIdx < groupRangeHi
                    }
                    .map { $0.element }
                    .reduce([], +)
                    .map { $0.normalizedMIDIChannel}
                
                let fileInfoString = "\(deviceIdx)"
                
                if let exportMIDIFileCallback = self.exportMIDIFileCallback {
                    exportMIDIFileCallback(
                        fileInfoString,
                        thisGroupProgramChangeMsgs,
                        thisGroupMIDINoteEvents,
                        thisGroupCCMsgs,
                        collectedTempoData //because each file will need tempo data for its own rendering
                    )
                }
            }
        }

        collectedMidiNoteEvents = []
        collectedCCData         = []
        collectedTempoData      = []
    }
}

extension MIDIJSONFileExport: CustomStringConvertible {
    public var description: String {
        """
        MIDIFileExport data:
            collectedProgramChangeData: \(collectedProgramChangeData.map({ ($0.channelNumber, $0.patchNumber) }))
            collectedTempoData: \(collectedTempoData)
            collectedCCData: \(collectedCCData)
            collectedMidiNoteEvents: \(collectedMidiNoteEvents)
        """
    }
}
