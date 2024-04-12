//
//  File.swift
//  
//
//  Created by stu on 12/04/2024.
//

import Foundation

public struct MIDIJSONCCData: Codable, Hashable {
    public let clockPosition:   Float32
    public let channelNumber:   UInt8
    public let ccNumber:        UInt8
    public let ccValue:         UInt8
    
    public init(
        clockPosition: Float32,
        channelNumber: UInt8,
        ccNumber: UInt8,
        ccValue: UInt8
    ) {
        self.clockPosition  = clockPosition
        self.channelNumber  = channelNumber
        self.ccNumber       = ccNumber
        self.ccValue        = ccValue
    }
    
    public var normalizedMIDIChannel: Self {
        .init(
            clockPosition: self.clockPosition,
            channelNumber: self.channelNumber % 16,
            ccNumber: self.ccNumber,
            ccValue: self.ccValue
        )
    }
}
