//
//  File.swift
//  
//
//  Created by stu on 12/04/2024.
//

import Foundation

public struct MIDIJSONPatchChangeData: Codable, Hashable {
    public let clockPosition:   Float32
    public let channelNumber:   UInt8
    public let bankNumber:      UInt8
    public let patchNumber:     UInt8
    public let patchName:       String
    
    public init(
        clockPosition:  Float32,
        channelNumber:  UInt8,
        bankNumber:     UInt8,
        patchNumber:    UInt8,
        patchName: String
    ) {
        self.clockPosition  = clockPosition
        self.channelNumber  = channelNumber
        self.bankNumber     = bankNumber
        self.patchNumber    = patchNumber
        self.patchName      = patchName
    }
    
    public var normalizedMIDIChannel: Self {
        .init(
            clockPosition:  self.clockPosition,
            channelNumber:  self.channelNumber % 16,
            bankNumber:     self.bankNumber,
            patchNumber:    self.patchNumber,
            patchName:      self.patchName
        )
    }
}
