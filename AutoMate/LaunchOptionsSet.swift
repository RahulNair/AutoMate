//
//  LaunchOptionsSet.swift
//  AutoMate
//
//  Created by Joanna Bednarz on 30/05/16.
//  Copyright © 2016 PGS Software. All rights reserved.
//

import Foundation

public struct LaunchOptionsSet {
    private var options: [LaunchOption]

    public init() {
        options = []
    }
}

// MARK: SetAlgebraType
extension LaunchOptionsSet: SetAlgebraType {
    public typealias Element = LaunchOption

    public func contains(member: LaunchOption) -> Bool {
        return options.contains { $0.uniqueIdentifier == member.uniqueIdentifier }
    }

    public mutating func insert(member: LaunchOption) {
        if !contains(member) {
            options.append(member)
        }
    }

    public func exclusiveOr(other: LaunchOptionsSet) -> LaunchOptionsSet {
        var copy = self
        copy.exclusiveOrInPlace(other)
        return copy
    }

    public mutating func exclusiveOrInPlace(other: LaunchOptionsSet) {
        var diff = options.filter { return !other.contains($0) }
        diff += other.filter { return !contains($0) }
        options = diff
    }

    public mutating func remove(member: LaunchOption) -> LaunchOption? {
        guard let index = options.indexOf({ member.uniqueIdentifier == $0.uniqueIdentifier }) else { return nil }
        return options.removeAtIndex(index)
    }

    public func intersect(other: LaunchOptionsSet) -> LaunchOptionsSet {
        var copy = self
        copy.intersectInPlace(other)
        return copy
    }

    public mutating func intersectInPlace(other: LaunchOptionsSet) {
        options = options.filter { return other.contains($0) }
    }

    public func union(other: LaunchOptionsSet) -> LaunchOptionsSet {
        var copy = self
        copy.unionInPlace(other)
        return copy
    }

    public mutating func unionInPlace(other: LaunchOptionsSet) {
        other.forEach({
            insert($0)
        })
    }
}

// MARK: SequenceType
extension LaunchOptionsSet: SequenceType {
    public typealias Generator = IndexingGenerator<[LaunchOption]>

    public func generate() -> Generator {
        return options.generate()
    }
}

// MARK: Equatable
public func == (lhs: LaunchOptionsSet, rhs: LaunchOptionsSet) -> Bool {
    return lhs.elementsEqual(rhs, isEquivalent: { $0.0.uniqueIdentifier == $0.1.uniqueIdentifier })
}
