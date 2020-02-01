//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2020-01-31.
//

import Foundation


// MARK: Basic Hotstuff
public enum BasicHotStuff {
    // Name space provider
}

//private func wait(
//    for expectedNonByzantineMessageCount: UInt,
//    timeout: TimeInterval,
//    onTimeout didTimeout: @escaping () -> Void
//) {
//    Timer.scheduledTimer(
//        withTimeInterval: timeout,
//        repeats: false,
//        block: { _ in didTimeout() }
//    )
//}
////public let 𝚫: TimeInterval = 3
//func nextView(viewNumber: ViewNumber) -> TimeInterval {
//    fatalError()
//}

public struct View {
    public let number: ViewNumber
    public let command: ClientCommand
    
    // should this be here?
    public let leader: Replica
    
    // should this exist?
    public let phase: Phase
    
    enum Phase {
        case prepare
        case preCommit(prepareQC: QuorumCertificate)
        case commit(preCommitQC: QuorumCertificate)
        case decide(commitQC: QuorumCertificate)
    }
}

extension Replica {
    func basicHotStuffMainLoop() {
        
    }
}

// MARK: Main loop
public extension BasicHotStuff {
    static func doConsensus(
        for replica: Replica,
        command: ClientCommand,
        viewNumber: ViewNumber
    ) {
        Self.preparePhase(for: replica, command: command)
    }
}

// MARK: Prepare Phase
public extension BasicHotStuff {
    static func preparePhase(
        for replica: Replica,
        command: ClientCommand
    ) {
        replica.preparePhaseAsReplica(command: command)

        if replica.isLeader {
            replica.preparePhaseAsLeader(command: command, replicas: [])
        }
    }
}

// MARK: Replica + BasicHotStuff
private extension Replica {
    func preparePhaseAsLeader(
        command: ClientCommand,
        replicas: [Replica]
    ) {
        let newViewMessages = collect(
            message: .newView,
            from: replicas,
            timeout: .delta
        )
        
        let highQC = newViewMessages.map({ $0.quorumCertificate! }).max()!
        
        let currentProposal = createLeaf(parent: highQC.node, command: command)
        
        broadcastMessage(
            ofType: .prepare,
            proposal: currentProposal,
            qc: highQC
        )
    }
    
    func preparePhaseAsReplica(
        command: ClientCommand
    ) {
        let messageFromLeader = waitOnMessageFromLeader {
            self.matching(
                message: $0,
                ofType: .prepare,
                viewNumber: currentViewNumber
            )
        }
   
        let node = messageFromLeader.node
        
        guard let justification = messageFromLeader.message.justify,
            case .byReplicaHighestPrepareQC(let justify) = justification else {
                fatalError("should have highQc as justify")
        }
         
        if try! node.extends(node: justify.node) && safeNode(node, qc: justify)
        {
            self.sendToLeader(
                message: self.voteMessage(type: .prepare, node: node, qc: nil)
            )
        }
    }
}

extension TimeInterval {
    static var delta: Self { 1 }
}
