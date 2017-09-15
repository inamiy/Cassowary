#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
import Darwin
#else
import Glibc
#endif

/// Strength of the constraint.
public enum Priority
{
    case required

    /// Non-required constraint priority with Cocoa-like Int strength
    /// (i.e. `high = 750` and `low = 250` with range between 0-1000).
    ///
    /// - Note: Unlike Cocoa, Int associated value may exceed beyond 1000, but not below 0.
    case optional(Int)

    public static let high = Priority(750)      // weight = 1_000_000
    public static let medium = Priority(500)    // weight = 1_000
    public static let low = Priority(250)       // weight = 1

    public init(_ value: Int)
    {
        self.init(rawValue: value)
    }

    /// Priority weight used for constructing objective function
    /// to find a weighted-sum-better solution.
    ///
    /// - Note: Example of `(rawValue, weight)` pair will be `(250, 1), (500, 10e3), (750, 10e6)`.
    /// - Note: Returns `nil` if `.required`.
    public var weight: Double?
    {
        switch self {
        case .required: return nil
        case .optional: return pow(10, 3 * (Double(self.rawValue) / 250 - 1))
        }
    }
}

extension Priority: RawRepresentable
{
    public init(rawValue: Int)
    {
        if rawValue >= 0 {
            self = .optional(rawValue)
        }
        else {
            self = .required
        }
    }

    public var rawValue: Int
    {
        switch self {
        case .required: return -1
        case let .optional(value): return value
        }
    }
}

extension Priority: ExpressibleByIntegerLiteral
{
    public init(integerLiteral value: Int)
    {
        self.init(rawValue: value)
    }
}
