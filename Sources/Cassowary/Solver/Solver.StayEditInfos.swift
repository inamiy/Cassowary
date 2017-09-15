import Simplex

extension Solver
{
    /// For removing stay-variable.
    internal struct StayInfo: MarkerInfoProtocol
    {
        internal var constraint: Constraint
        internal var markers: Markers
    }

    /// For suggesting & removing edit-variable.
    internal struct EditInfo: MarkerInfoProtocol
    {
        internal var constraint: Constraint
        internal var markers: Markers
        internal var prevEditConstant: Double
    }

    /// Pair of `StayInfo` and `EditInfo`.
    internal struct StayEditInfos
    {
        internal var stayInfos: [Variable: StayInfo] = [:]
        internal var editInfos: [Variable: EditInfo] = [:]

        internal var allInfos: [MarkerInfoProtocol]
        {
            let stayInfos: [MarkerInfoProtocol] = Array(self.stayInfos.values)
            let editInfos: [MarkerInfoProtocol] = Array(self.editInfos.values)
            return stayInfos + editInfos
        }

        internal static func += (l: inout StayEditInfos, r: StayEditInfos)
        {
            l.stayInfos.merge(r.stayInfos, uniquingKeysWith: { $1 })
            l.editInfos.merge(r.editInfos, uniquingKeysWith: { $1 })
        }
    }
}

internal protocol MarkerInfoProtocol
{
    var constraint: Constraint { get }
    var markers: Solver.Markers { get }
}
