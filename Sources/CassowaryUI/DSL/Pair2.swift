import Foundation
import Simplex

/// 2-dimentional pairs.
/// - Note: Has internal `Identity`.
public struct Pair2
{
    public let name: String

    internal let _pairs: (x: Pair, y: Pair)
    private let _identity: _Identity

    public init(_ name: String = "")
    {
        let identity = _Identity()
        self.name = name.isEmpty ? "\(ObjectIdentifier(identity).hashValue % 100)" : name
        self._pairs = (Pair("\(self.name)_x"), Pair("\(self.name)_y"))
        self._identity = identity
    }
}

extension Pair2
{
    // MARK: x-axis

    public var left: Expression
    {
        return self._pairs.x.left
    }

    public var right: Expression
    {
        return self._pairs.x.right
    }

    public var leading: Expression
    {
        return self._pairs.x.left
    }

    public var trailing: Expression
    {
        return self._pairs.x.right
    }

    public var centerX: Expression
    {
        return self._pairs.x.center
    }

    public var width: Expression
    {
        return self._pairs.x.width
    }

    // MARK: y-axis

    public var top: Expression
    {
        return self._pairs.y.left
    }

    public var bottom: Expression
    {
        return self._pairs.y.right
    }

    public var centerY: Expression
    {
        return self._pairs.y.center
    }

    public var height: Expression
    {
        return self._pairs.y.width
    }
}

extension Pair2: Hashable
{
    public var hashValue: Int
    {
        return ObjectIdentifier(self._identity).hashValue
    }

    public static func == (l: Pair2, r: Pair2) -> Bool
    {
        return l._identity === r._identity
    }
}

extension Pair2: CustomStringConvertible
{
    public var description: String
    {
        return self.name.isEmpty ? _shortHashString(self) : self.name
    }
}

extension Pair2: CustomDebugStringConvertible
{
    public var debugDescription: String
    {
        return "Pair2(\(self.description))"
    }
}

extension Pair2: HasPairs
{
    public var pairs: [Pair]
    {
        return [self._pairs.x, self._pairs.y]
    }
}
