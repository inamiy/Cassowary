# Cassowary

An incremental linear constraint-solving algorithm (Auto Layout) in Swift, originally from the paper:
[Solving Linear Arithmetic Constraints for User Interface Applications (1997)](https://constraints.cs.washington.edu/solvers/uist97.html)

This repository consists of 3 frameworks:

- [Simplex](Sources/Simplex): Simplex tableau and its common operations
- [Cassowary](Sources/Cassowary): Core constraint-solving algorithm using Simplex
- [CassowaryUI](Sources/CassowaryUI): UIKit/AppKit wrapper on top of Cassowary

## How to use

### CassowaryUI

```swift
import Cassowary
import CassowaryUI

let rootSize = CGSize(width: 320, height: 480)
var solver = CassowaryUI.Solver()

try! solver.addConstraints(view1, view2) { v1, v2 in
    return [
        // `v1` has fixed size (4:3 aspect ratio)
        v1.width == rootSize.width - 40,
        v1.height == v1.width * 3 / 4,

        // `v2` has fixed origin.x & width (flexible in vertical)
        v2.width == v1.width,
        v1.centerX == rootFrame.width / 2,
        v2.centerX == v1.centerX,

        // equal spacing (vertical)
        v1.top == 145 ~ .high,
        v2.top - v1.bottom == v1.top ~ .high,
        rootSize.height - v2.bottom == v1.top ~ .high,
    ]
}
solver.applyLayout()
```

This will result:

```
<UIView: 0x7f8f1ee018c0; frame = (0 0; 320 480); layer = <CALayer: 0x608000220800>>
   | <UIView: 0x7f8f21001010; frame = (20 40; 280 210); layer = <CALayer: 0x60c000220da0>>
   | <UIView: 0x7f8f1ec015c0; frame = (20 290; 280 150); layer = <CALayer: 0x60c000220840>>
```

## Acknowledgments

- [Solving Linear Arithmetic Constraints for User Interface Applications (1997)](https://constraints.cs.washington.edu/solvers/uist97.html) by Alan Borning, Kim Marriott, Peter Stuckey, and Yi Xiao
- [ユーザインタフェースのための線形等式・不等式制約解消系 (2002)](https://www.jstage.jst.go.jp/article/jssst/19/6/19_6_437/_article/-char/ja/) by 細部 博史
- [pybee/cassowary](https://github.com/pybee/cassowary) (Python version)
- [robb/Cartography](https://github.com/robb/Cartography) (Auto Layout DSL in Swift)

## License

[MIT](LICENSE)