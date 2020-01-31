//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2020-01-31.
//

import Foundation

public struct ViewNumber: ExpressibleByIntegerLiteral, Comparable, Hashable {

    public let value: IntegerLiteralType
    public init(_ value: IntegerLiteralType) {
        self.value = value
    }
}

public extension ViewNumber {
    typealias IntegerLiteralType = UInt64
    init(integerLiteral value: UInt64) {
        self.init(value)
    }
    
    static func < (lhs: ViewNumber, rhs: ViewNumber) -> Bool {
        lhs.value < rhs.value
    }
}
