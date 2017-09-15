import CoreGraphics
import Simplex

extension CGFloat: DoubleConvertible
{
    public var double: Double
    {
        return Double(self)
    }
}
