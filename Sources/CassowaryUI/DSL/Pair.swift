import Foundation
import Simplex

/// Protocol that has N-dimentional `pairs`.
public protocol HasPairs: Hashable
{
    var pairs: [Pair] { get }
}

/// 1-dimentional `left` & `right` pair.
/// - Note: Has internal `_Identity`.
public struct Pair
{
    public let name: String

    internal let _variables: (_1: Variable, _2: Variable)
    private let _identity: _Identity

    public init(_ name: String = "")
    {
        let identity = _Identity()
        self.name = name.isEmpty ? "\(ObjectIdentifier(identity).hashValue % 100)" : name
        self._variables = (Variable("\(self.name)_1"), Variable("\(self.name)_2"))
        self._identity = identity
    }

    public var left: Expression
    {
        return .variable(self._variables._1)
    }

    public var right: Expression
    {
        return .variable(self._variables._2)
    }

    public var center: Expression
    {
        return (self.left + self.right) * 0.5
    }

    public var width: Expression
    {
        return self.right - self.left
    }
}

extension Pair: Hashable
{
    public static func == (l: Pair, r: Pair) -> Bool
    {
        return l._identity === r._identity
    }

    public var hashValue: Int
    {
        return ObjectIdentifier(self._identity).hashValue
    }
}

extension Pair: HasPairs
{
    public var pairs: [Pair]
    {
        return [self]
    }
}
