import UIKit
import PlaygroundSupport
import Cassowary
import CassowaryUI

let rootSize = CGSize(width: 320, height: 480)
var solver = CassowaryUI.Solver()

let rootView = UIView(frame: CGRect(origin: .zero, size: rootSize))

let view1 = UIView()
view1.backgroundColor = .orange
rootView.addSubview(view1)

let view2 = UIView()
view2.backgroundColor = .green
rootView.addSubview(view2)

do {
    try solver.addConstraints(view1, view2) { v1, v2 in
        return [
            // `v1` has fixed size (4:3 aspect ratio)
            v1.width == rootSize.width - 40 ~ .required,
            v1.height == v1.width * 3 / 4 ~ .required,

            // `v2` has fixed origin.x & width (flexible in vertical)
            v2.width == v1.width ~ .required,
            v1.centerX == rootSize.width / 2 ~ .required,
            v2.centerX == v1.centerX ~ .required,

            // equal spacing (vertical)
            v1.top == 40.0 ~ .high,
            v2.top - v1.bottom == v1.top ~ .high,
            rootSize.height - v2.bottom == v1.top ~ .high,
        ]
    }
}
catch {
    print(error)
}

solver.applyLayout()

rootView.backgroundColor = .white
PlaygroundPage.current.liveView = rootView

print(rootView.perform(Selector(("recursiveDescription"))).takeUnretainedValue())
