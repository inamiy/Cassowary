// From https://github.com/ReactiveCocoa/ReactiveSwift/blob/2.0.1/Sources/Reactive.swift

// MARK: CassowaryExtensionProvider

public protocol CassowaryExtensionProvider: class {}

extension CassowaryExtensionProvider {
    /// A proxy which hosts cassowary extensions for `self`.
    public var cassowary: CassowaryExtension<Self> {
        return CassowaryExtension(self)
    }

    /// A proxy which hosts static cassowary extensions for the type of `self`.
    public static var cassowary: CassowaryExtension<Self>.Type {
        return CassowaryExtension<Self>.self
    }
}

// MARK: CassowaryExtension

/// A proxy which hosts cassowary extensions of `Base`.
public struct CassowaryExtension<Base> {
    /// The `Base` instance the extensions would be invoked with.
    public let base: Base

    /// Construct a proxy
    ///
    /// - parameters:
    ///   - base: The object to be proxied.
    fileprivate init(_ base: Base) {
        self.base = base
    }
}
