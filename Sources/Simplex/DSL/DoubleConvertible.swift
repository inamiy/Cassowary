/// Workaround for non-generic `Double.init`.
public protocol DoubleConvertible
{
    var double: Double { get }
}

extension Double: DoubleConvertible
{
    public var double: Double
    {
        return self
    }
}

extension Int: DoubleConvertible
{
    public var double: Double
    {
        return Double(self)
    }
}
