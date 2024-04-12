//
//  File.swift
//  
//
//  Created by stu on 12/04/2024.
//

import Foundation

public struct MIDIJSONNoteEventData: Codable {
    public let clockPosition:  Float32
    public let noteLength:     Float32
    public let channelNumber:  UInt8
    public let noteNumber:     UInt8
    public let noteVelocity:   UInt8
    
    public init(
        clockPosition: Float32,
        noteLength: Float32,
        channelNumber: UInt8,
        noteNumber: UInt8,
        noteVelocity: UInt8
    ) {
        self.clockPosition = clockPosition
        self.noteLength = noteLength
        self.channelNumber = channelNumber
        self.noteNumber = noteNumber
        self.noteVelocity = noteVelocity
    }
    
    /// channel % 16
    public var normalizedMIDIChannel: Self {
        .init(
            clockPosition:  self.clockPosition,
            noteLength:     self.noteLength,
            channelNumber:  self.channelNumber % 16,
            noteNumber:     self.noteNumber,
            noteVelocity:   self.noteVelocity
        )
    }
}

extension MIDIJSONNoteEventData: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.clockPosition == rhs.clockPosition
        && lhs.channelNumber == rhs.channelNumber
        && lhs.noteNumber == rhs.noteNumber
        }
}

/// this doesn't appear to work
//extension MIDIFileNoteEventData: Hashable {
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(clockPosition)
//        hasher.combine(channelNumber)
//        hasher.combine(noteNumber)
//    }
//}
