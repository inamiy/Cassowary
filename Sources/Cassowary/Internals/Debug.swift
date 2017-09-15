import Simplex

internal enum Debug
{
    internal static func print(separator: String = " ", terminator: String = "\n")
    {
        #if DEBUG
            Swift.print(separator: separator, terminator: terminator)
        #endif
    }

    internal static func print(_ msg: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n")
    {
        #if DEBUG
            Swift.print(msg(), separator: separator, terminator: terminator)
        #endif
    }

    internal static func printTableau(_ tableau: Tableau, _ msg: @autoclosure () -> Any, functionName: String = #function)
    {
        #if DEBUG
            Swift.print("//--------------------------------------")
            Swift.print("*** \(msg()) ***")
            Swift.print()
            Swift.print(tableau)
            Swift.print("--------------------------------------//")
        #endif
    }
}
