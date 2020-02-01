//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2020-01-31.
//

import Foundation
import Combine

public final class Mempool {
    
    private var incommingClientCommandQueue: [ClientCommand]
}

public struct Replica {
    private let privateKey: PrivateKey
    
//    /// The highest `QC` this replica has voted `commit` for.
//    private var lockedQC: QuorumCertificate?
//
//    /// The highest `QC` this replica has voted `pre-commit` for
//    private var prepareQC: QuorumCertificate?
    
    private var view: View
    
    private var incommingMessageSubject: PassthroughSubject<SignedMessage>

    public var isLeader: Bool
}

// MARK:  as Replica
public extension Replica {
    func message(type: MessageType, node: Node, qc: QuorumCertificate?) -> Message {
        
        let justification: Message.Justification? = {
            guard let qc = qc else { return nil }
            return isLeader ? .byLeader(qc: qc) : .byReplicaHighestPrepareQC(qc)
        }()
        
        return Message(
            parcel: .init(
                type: type,
                viewNumber: currentViewNumber,
                node: node
            ),
            justify: justification
        )
    }
    
    func voteMessage(type: MessageType, node: Node, qc: QuorumCertificate?) -> SignedMessage {
        let unsignedMessage = message(type: type, node: node, qc: qc)
        return signing(message: unsignedMessage)
    }
    
    func sendToLeader(message: SignedMessage) {
        fatalError()
    }
    
    func waitOnMessageFromLeader(matching: (Parcel) -> Bool) -> SignedMessage {
        fatalError()
    }

}

// MARK: as Leader
public extension Replica {
    func quorumCertificate(
        signedMessages: [SignedMessage],
        parcel: Parcel
    ) throws -> QuorumCertificate {
        assert(isLeader)
        return try QuorumCertificate(signedMessages: signedMessages, for: parcel)
    }
    
    func createLeaf(
        parent: Node,
        command: ClientCommand
    ) -> Node {
        assert(isLeader)
        return .leaf(parent: parent, value: command, height: parent.height + 1)
    }
    
    func collect(
          message: MessageType,
          from replicas: [Replica],
          timeout _: TimeInterval
      ) -> [SignedMessage]{
        assert(isLeader)
        return []
      }
      
    
    func broadcastMessage(
        ofType _: MessageType,
        proposal _: Node,
        qc _: QuorumCertificate
    ) {
        assert(isLeader)
    }
}

// MARK: Utilities
internal extension Replica {
    func matching(
        message: Parcel,
        ofType messageType: MessageType,
        viewNumber: ViewNumber
    ) -> Bool {
        message.type == messageType && message.viewNumber == viewNumber
    }
    
    func matching(
        qc: QuorumCertificate,
        ofType messageType: MessageType,
        viewNumber: ViewNumber
    ) -> Bool {
        qc.type == messageType && qc.viewNumber == viewNumber
    }
    
    func safeNode(
        _ node: Node,
        qc: QuorumCertificate
    ) throws -> Bool {
        precondition(lockedQC != nil)
        
        return
            //  "safety rule"
            node.extends(node: lockedQC!.node)
            ||
            //  "liveness rule"
            qc.viewNumber > lockedQC!.viewNumber
    }

}

// MARK: Private
private extension Replica {
    func signing(message: Message) -> SignedMessage {
        .init(
            message: message,
            partialSignature: .init(signedByPublicKey: privateKey.publicKey))
    }
}
