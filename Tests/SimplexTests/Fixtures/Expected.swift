import Simplex

enum Expected<Err: Swift.Error>
{
    case solution(Solution)
    case partialSolution([Variable: Double])
    case error(Err)
}
