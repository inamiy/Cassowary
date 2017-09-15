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

internal final class _Identity {}
