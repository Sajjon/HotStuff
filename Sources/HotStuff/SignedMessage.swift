//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2020-01-31.
//

import Foundation

public struct SignedMessage: ParcelOwner {
    let message: Message
    public let partialSignature: PartialSignature
}
public extension SignedMessage {
    var parcel: Parcel { message.parcel }
    var quorumCertificate: QuorumCertificate? {
        switch message.type {
        case .newView:
            guard
                let justification = message.justify,
                case .byReplicaHighestPrepareQC(let highQC) = justification
            else {
                fatalError("Expected to always have highQC")
            }
            return highQC
        default:
            return message.justify?.quorumCertificate
        }
        
    }
    
}
