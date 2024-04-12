//
//  File.swift
//  
//
//  Created by stu on 12/04/2024.
//

import Foundation

public struct MIDIJSONTempoChangeData: Codable, Hashable {
    public let clockPosition: Float32
    public let tempoBPM: Float64
    
    public init(
        clockPosition: Float32,
        tempoBPM: Float64
    ) {
        self.clockPosition  = clockPosition
        self.tempoBPM       = tempoBPM
    }
}
