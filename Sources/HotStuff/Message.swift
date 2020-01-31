//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2020-01-31.
//

import Foundation

/// Container of tuple: `type`, `viewNumber`, `node`
public protocol ParcelConvertible: Comparable {
    /// `type ∈ {new-view, prepare, pre-commit, commit, decide}`
    var type: MessageType { get }
     
    /// `curView`, sender's current view number
    var viewNumber: ViewNumber { get }
     
     /// proposed node (the leaf node of a proposed branch)
    var node: Node { get }
}

public extension ParcelConvertible {
    static func < (lhs: Self, rhs: Self) -> Bool {
          lhs.viewNumber < rhs.viewNumber
      }
}

public protocol ParcelOwner: ParcelConvertible {
    var parcel: Parcel { get }
}

public extension ParcelOwner {
    var type: MessageType { parcel.type }
    var viewNumber: ViewNumber { parcel.viewNumber }
    var node: Node { parcel.node }
}

public struct Parcel: ParcelConvertible, Equatable {
    public let type: MessageType
    public let viewNumber: ViewNumber
    public let node: Node
}

public struct Message: ParcelOwner {
//    public static func == (lhs: Message, rhs: Message) -> Bool {
//        lhs.parcel == rhs.parcel &&
//    }
    
    
    public let parcel: Parcel
    
    /// `justify`,  The leader always uses this field to carry the `QC` for the different phases. Replicas use it in new-view messages to carry the highest prepareQC.
    public let justify: Justification?
}

public extension Message {
    enum Justification: Equatable {
        // Used by replicas in `newView` messages
        case byReplicaHighestPrepareQC(QuorumCertificate)
        case byLeader(qc: QuorumCertificate)
    }
}

public extension Message.Justification {
    var quorumCertificate: QuorumCertificate? {
        switch self {
        case .byReplicaHighestPrepareQC(let quorumCertificate):
            return quorumCertificate
        case .byLeader(let quorumCertificate):
            return quorumCertificate
        }
    }
}
