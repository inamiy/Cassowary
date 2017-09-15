public func + (l: Priority, r: Priority) -> Priority
{
    switch (l, r) {
    case let (.optional(l), .optional(r)):
        return .optional(l + r)
    default:
        return .required
    }
}

public func - (l: Priority, r: Priority) -> Priority
{
    switch (l, r) {
    case let (.optional(l), .optional(r)):
        return .optional(l + r)
    default:
        return .required
    }
}
