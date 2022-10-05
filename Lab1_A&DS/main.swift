//
//  main.swift
//  Lab1_A&DS
//
//  Created by Максим on 20.09.2022.
//

import Foundation

// MARK: LinkedList class
class LinkdedList <T: Equatable> {
    var head: Node<T>? = nil
    var tail: Node<T>? = nil
    var size: Int = 0
}

// MARK: Node of LinkedList
class Node<T: Equatable>: Equatable {
    static func == (lhs: Node<T>,
                    rhs: Node<T>) -> Bool {
        return rhs.value == lhs.value
    }

    var value: T
    var next: Node<T>? = nil
    var prev: Node<T>? = nil

    init (value: T) {
        self.value = value
    }
}

// MARK: - Extension for methods realization
extension LinkdedList {

    // Checking list emptiness
    func isEmpty() -> Bool {
        if self.size == 0 {
            return true
        } else {
            return false
        }
    }

    // Appending new value at the end of the list
    func append (value: T) {
        let newNode = Node(value: value)
        guard self.head != nil else {
            self.head = newNode
            self.tail = newNode
            self.size += 1
            return
        }

        self.tail?.next = newNode
        newNode.prev = self.tail
        self.tail = newNode
        self.size += 1
    }

    // Appending new value at first position of the list
    func insertAtFirst (value: T) {
        let newNode = Node(value: value)

        guard self.head != nil else {
            self.head = newNode
            self.tail = newNode
            self.size += 1
            return
        }

        self.head?.prev = newNode
        newNode.next = self.head
        self.head = newNode

        self.size += 1
    }

    // Inserting new value at Index-position of the list
    func insertAtIndex (value: T,
                        atIndex: Int) {
        guard atIndex >= 0, atIndex <= self.size else {
            print("Error. undefined value")
            return
        }

        if atIndex == 0 {
            self.insertAtFirst(value: value)
        } else if atIndex == self.size {
            self.append(value: value)
        } else {
            let newNode = Node(value: value)
            var current = self.head
            for _ in 0..<atIndex {
                current = current?.next
            }
            current?.prev?.next = newNode
            newNode.prev = current?.prev
            current?.prev = newNode
            newNode.next = current
            self.size += 1
        }
    }

    // Getting value of Node at Index-position
    func valueAtIndex(index: Int) -> T? {
        guard index >= 0 && index <= self.size else {
            print("Error. undefinded value")
            return nil
        }

        var current = self.head
        for _ in 0..<index {
            current = current?.next
        }

        return current?.value
    }

    // Changing value of Node at Index-position
    func changeValueAtIndex(index: Int,
                            newValue: T) {
        guard index >= 0 && index <= self.size else {
            print("Error. undefinded value")
            return
        }

        var current = self.head
        for _ in 0..<index {
            current = current?.next
        }

        current?.value = newValue
    }

    // Removing last Node of the list
    func removeLast() {
        guard self.size != 0 else {
            print("Error. List is empty.")
            return }

        if self.size == 1 {
            self.head = nil
            self.size -= 1
            return
        }

        self.tail = self.tail?.prev
        self.tail?.next = nil
        self.size -= 1
    }

    // Removing first Node of the list
    func removeFirst() {
        guard self.size != 0 else {
            print("Error. List is empty.")
            return }

        self.head = self.head?.next
        self.head?.prev = nil
        self.size -= 1
    }

    // Removing Node at Index-position of the list
    func removeAtIndex (value: T,
                        atIndex: Int) {
        guard atIndex >= 0, atIndex <= self.size else {
            print("Error. undefined value")
            return
        }

        if atIndex == 0 {
            self.removeFirst()
            self.size -= 1
        } else if atIndex == self.size {
            self.size -= 1
        } else {
            var current = self.head
            for _ in 0..<atIndex {
                current = current?.next
            }
            current?.prev?.next = current?.next.self
            current?.next?.prev = current?.prev.self
            self.size -= 1
        }
    }

    // Removing all Nodes of the list
    func removeAll() {
        guard self.size != 0 else {
            print("Error. List is empty.")
            return }

        self.head = nil
        self.tail = nil
        self.size = 0
    }

    // Checking first occurance of second list in main list
    func checkingOccurance(newList: LinkdedList<T>) {
        if self.isEmpty(), newList.isEmpty() {
            print("Both lists are empty.")
        }

        var mainListCurrent = self.head
        for i in 0..<self.size {
            var counter = 0
            if mainListCurrent?.value == newList.head?.value {
                var tempI = i
                for j in 0..<newList.size {
                    if self.valueAtIndex(index: tempI) == newList.valueAtIndex(index: j) {
                        counter += 1
                        if counter == newList.size {
                            print("First occurance is at " + String(i) + " index.")
                            return
                        }
                        tempI += 1
                    }
                }
            }
            mainListCurrent = mainListCurrent?.next
        }
    }


}

var list = LinkdedList<String>()
var newList = LinkdedList<String>()
list.append(value: "SomeString")
list.append(value: "SomeString2")
list.append(value: "SomeString3")
list.append(value: "SomeString3")
list.append(value: "SomeString4")
list.append(value: "SomeString3")
list.append(value: "SomeString4")
newList.append(value: "SomeString3")
newList.append(value: "SomeString4")
print(list.checkingOccurance(newList: newList))
