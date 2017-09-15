import Cassowary
import Simplex

#if os(iOS) || os(tvOS)
import UIKit
public typealias View = UIView
#elseif os(macOS)
import AppKit
public typealias View = NSView // TODO: not implemented yet
#endif

private let pair2Key = AssociationKey<Pair2?>()

extension View: CassowaryExtensionProvider {}

extension CassowaryExtension where Base == View
{
    public var left: Variable
    {
        return self.base._pair2._pairs.x._variables._1
    }

    public var right: Variable
    {
        return self.base._pair2._pairs.x._variables._2
    }

    public var top: Variable
    {
        return self.base._pair2._pairs.y._variables._1
    }

    public var bottom: Variable
    {
        return self.base._pair2._pairs.y._variables._2
    }
}

extension View
{
    internal var _pair2: Pair2
    {
        if let value = self.associations.value(forKey: pair2Key) {
            return value
        }
        let pair2 = Pair2("\(self.hashValue)")
        self.associations.setValue(pair2, forKey: pair2Key)

        return self.associations.value(forKey: pair2Key)!
    }
}
