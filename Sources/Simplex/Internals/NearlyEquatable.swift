internal protocol NearlyEquatable
{
    func isNearlyEqual(to: Self) -> Bool
}

extension Double: NearlyEquatable
{
    internal func isNearlyEqual(to: Double) -> Bool
    {
        return abs(self - to) <= 1e-8
    }
}

// MARK: Dictionary + NearlyEquatable

extension Dictionary where Value: NearlyEquatable
{
    internal func isNearlyEqual(to other: [Key: Value]) -> Bool
    {
        let l = self
        let r = other
        guard l.keys == r.keys else { return false }

        for (key, value) in l {
            if !value.isNearlyEqual(to: r[key]!) { return false }
        }

        return true
    }
}
