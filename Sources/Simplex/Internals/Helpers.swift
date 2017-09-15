import Foundation

/// Combine hashValues.
internal func _hash<H1: Hashable, H2: Hashable>(_ h1: H1, _ h2: H2) -> Int
{
    let prime = 31
    var hash = 17
    hash = hash &* prime &+ h1.hashValue
    hash = hash &* prime &+ h2.hashValue
    return hash
}

internal func _shortHashString<H: Hashable>(_ h: H) -> String
{
    return String(String(UInt(bitPattern: h.hashValue), radix: 36, uppercase: false).prefix(3))
}

/// - SeeAlso: https://github.com/coryalder/SwiftLeftpad/blob/master/Sources/SwiftLeftpad.swift
internal func _leftPad(_ string: String, length: Int, character: Character = " ") -> String
{
    var outString: String = string
    let extraLength = length - outString.characters.count

    var i = 0
    while i < extraLength {
        outString.insert(character, at: outString.startIndex)
        i += 1
    }

    return outString
}

internal func _shortString(_ double: Double) -> String
{
    return String(format: "%g", double)
}
