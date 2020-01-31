//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2020-01-31.
//

import Foundation

public typealias Node = GraphNode<ClientCommand>

public enum GraphNode<Value> {
    case root(value: Value, height: UInt)
    indirect case leaf(parent: GraphNode, value: Value, height: UInt)
}

public extension GraphNode {
    var value: Value {
        switch self {
        case .root(let value, _): return value
        case .leaf(_, let value, _): return value
        }
    }
    
    var height: UInt {
        switch self {
        case .root(_, let height): return height
        case .leaf(_, _, let height): return height
        }
    }

    var parent: Self? {
        switch self {
        case .root: return nil
        case .leaf(let parent, _, _): return parent
        }
    }
}

extension GraphNode: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.height == rhs.height && lhs.value == rhs.value
    }
    
    func extends(node: Self) -> Bool {
          guard let parent = parent else { return false }
          return node == parent
      }
}
