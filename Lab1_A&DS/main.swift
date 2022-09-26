//
//  main.swift
//  Lab1_A&DS
//
//  Created by Максим on 20.09.2022.
//

import Foundation

final class Node<T> {
    // Current Value of List Container
    let currentValue: T

    // Next Value of List Container
    fileprivate(set) var nextValue: Node?

    // Previous Value of List Container
    fileprivate(set) weak var previousValue: Node?

    init(currentValue: T, nextValue: Node? = nil, previousValue: Node? = nil) {
        self.currentValue = currentValue
        self.nextValue = nextValue
        self.previousValue = previousValue
    }
}


struct LinkedList<T> {
    // Unique id for the list
    private var uniqueReference = UniqueReference() //

    // Reference to first container in the List
    fileprivate(set) var firstNode: Node<T>?

    // Reference to last container in the List
    fileprivate(set) var lastNode: Node<T>?

    var isEmpty: Bool {
        return firstNode == nil
    }

    var first: WeakReference<Node<T>>? {
        return firstNode?.weakReference
    }

    var last: WeakReference<Node<T>>? {
        return lastNode?.weakReference
    }

    // Inserting value at first position of the List
    mutating func insertAtFirst(_ value: T) {
        copyIfNeeded()

        let node = Node(currentValue: value, nextValue: firstNode)

        firstNode?.previousValue = node

        firstNode = node

        if lastNode == nil && firstNode?.nextValue?.nextValue == nil {
            lastNode = firstNode?.nextValue
        }
    }

    // Inserting value at last position of the List
    mutating func append(_ value: T) {
        copyIfNeeded()

        guard !isEmpty else {
            insertAtFirst(value)
            return
        }

        lastNode?.nextValue = Node(currentValue: value, previousValue: lastNode)
        lastNode = lastNode?.nextValue
    }

    // Inserting value after entered position
    mutating func insert(_ value: T, after referenced: WeakReference<Node<T>>) {
        copyIfNeeded()

        guard lastNode !== referenced.node else {
            append(value)
            return
        }

        let oldNextNode = referenced.node?.nextValue
        let newNode = Node(currentValue: value, nextValue: oldNextNode, previousValue: referenced.node)

        oldNextNode?.previousValue = newNode
        referenced.node?.nextValue = newNode
    }

    @discardableResult
    // Removing value at first position of the List
    mutating func removeAtFirst() -> T? {
        copyIfNeeded()

        defer {
            firstNode = firstNode?.nextValue
            firstNode?.previousValue = nil

            if isEmpty {
                lastNode = nil
            }
        }
        return firstNode?.currentValue
    }

    @discardableResult
    // Removing value at last position of the List
    mutating func removeAtLast() -> T? {
        copyIfNeeded()

        guard firstNode?.nextValue != nil else {
            removeAtFirst()
            return nil
        }

        defer {
            lastNode = lastNode?.previousValue
            lastNode?.nextValue = nil

            if isEmpty {
                lastNode = nil
            }
        }
        return lastNode?.currentValue
    }

    @discardableResult
    // Removing value after entered position
    mutating func remove(after referenced: WeakReference<Node<T>>) -> T? {
        copyIfNeeded()

        defer {
            if referenced.node?.nextValue === lastNode {
                lastNode = referenced.node
                lastNode?.nextValue = nil
            }

            let newNext = referenced.node?.nextValue?.nextValue
            referenced.node?.nextValue = newNext
            newNext?.previousValue = referenced.node
        }

        return referenced.node?.nextValue?.currentValue
    }
}

// Protocol for copy-on-write realisation
protocol WeakReferenceProtocol: AnyObject {
    associatedtype T

    var weakReference: WeakReference<Node<T>> {get}
}

// Class for holding weak-reference for container
final class WeakReference<T: AnyObject> {
    private(set) weak var node: T?

    init(node: T?) {
        self.node = node
    }
}

// Extension for copy-on-write realisation
extension Node: WeakReferenceProtocol {
    var weakReference: WeakReference<Node<T>> {
        return WeakReference(node: self)
    }
}


extension LinkedList: BidirectionalCollection {
    // Structure for optimization and for showing index
    struct Index: Comparable {
        // Index holding Container
        var node: Node<T>?

        static func < (lhs: LinkedList<T>.Index, rhs: LinkedList<T>.Index) -> Bool {
            guard lhs != rhs else { return false }
            let nodes = sequence(first: lhs.node) { $0?.nextValue }

            return nodes.contains { $0 === rhs.node }
        }

        static func == (lhs: LinkedList<T>.Index, rhs: LinkedList<T>.Index) -> Bool {
            switch (lhs.node, rhs.node) {
            case let (left, right):
                return left === right
            }
        }
    }

    // Returning value of first-index container
    var startIndex: LinkedList<T>.Index {
        return Index(node: firstNode)
    }

    // Returning value of last-index container
    var endIndex: LinkedList<T>.Index {
        return Index(node: lastNode)
    }

    // Returning value of next-index container
    func index(after i: LinkedList<T>.Index) -> LinkedList<T>.Index {
        return Index(node: i.node?.nextValue)
    }

    // Returning value of previous-index container
    func index(before i: LinkedList<T>.Index) -> LinkedList<T>.Index {
        return Index(node: i.node?.previousValue)
    }

    subscript(position: Index) -> T? {
        return position.node?.currentValue
    }
}

extension LinkedList {
    // Class for avoidance of weak-references
    private class UniqueReference {}

    // Making copy of the list if smth changes
    private mutating func copyIfNeeded() {
        // Making copies only if there is more than 1 strong reference
        guard !isKnownUniquelyReferenced(&uniqueReference),
              // Saving first container of entire list
              var previous = firstNode else { return }
        // new first container
        firstNode = Node(currentValue: previous.currentValue)
        // iterator for new list
        var current = firstNode

        while let next = previous.nextValue {
            current?.nextValue = Node(currentValue: next.currentValue, previousValue: current)
            current = current?.nextValue
            previous = next
        }

        lastNode = current
        // new unique identifier
        uniqueReference = UniqueReference()
    }
}

//test
