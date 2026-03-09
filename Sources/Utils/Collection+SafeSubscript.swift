//
//  Collection+SafeSubscript.swift
//  Swift Foundations
//
//  Safe index access for collections.
//  Prevents out-of-bounds crashes.
//

import Foundation

public extension Collection {

    /// Returns the element at the specified index if it is within bounds,
    /// otherwise returns `nil`.
    ///
    /// - Parameter index: The position of the element to access.
    /// - Returns: The element at `index` if it exists; otherwise `nil`.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
