extension Solver
{
    /// Marker variables used to detect target constraint in mixed-up simplex tableau.
    internal struct Markers
    {
        internal let mainMarker: Column
        internal let subMarker: Column?

        internal init(main: Column, sub: Column?)
        {
            self.mainMarker = main
            self.subMarker = sub
        }

        internal var columns: [Column]
        {
            if let subMarker = subMarker {
                return [mainMarker, subMarker]
            }
            else {
                return [mainMarker]
            }
        }
    }
}
