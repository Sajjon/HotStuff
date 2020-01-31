//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2020-01-31.
//

import Foundation

public enum MessageType: String, Equatable {
    case newView
    case prepare
    case preCommit
    case commit
    case decide
}

