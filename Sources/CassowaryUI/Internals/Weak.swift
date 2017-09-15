internal final class Weak<T: AnyObject>
{
    internal private(set) weak var value: T?

    internal init(_ value: T)
    {
        self.value = value
    }
}

extension Weak: Hashable
{
    public static func == (l: Weak, r: Weak) -> Bool
    {
        return l.value === r.value
    }

    public var hashValue: Int
    {
        return ObjectIdentifier(self).hashValue
    }
}
