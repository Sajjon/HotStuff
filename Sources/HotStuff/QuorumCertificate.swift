//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2020-01-31.
//

import Foundation

public struct QuorumCertificate: ParcelOwner {
    public let parcel: Parcel
    
    init(signedMessages: [SignedMessage], for parcel: Parcel) throws {
        guard signedMessages.allSatisfy({ $0.parcel == parcel }) else {
            throw Error.parcelMismatch
        }
        self.parcel = parcel
    }
    
}

public extension QuorumCertificate {

    enum Error: Int, Swift.Error, Equatable {
        case parcelMismatch
    }
}
