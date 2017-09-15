import Foundation
import CoreGraphics
import Cassowary
import CassowaryUI

/// Setup `vs[0]` (parent of all other `vs[i]`s).
private func setupView0(rootSize: CGSize, pairs vs: [Pair2]) -> [Constraint]
{
    var constraints = [Constraint]()

    // Setup `vs[0]` (set `.high - 100` priority for editing).
    let vs0Priority: Priority = .high - 100
    constraints.append(contentsOf: [
        vs[0].top == 40 ~ vs0Priority,
        vs[0].left == 20 ~ vs0Priority,
        vs[0].right == rootSize.width - 20 ~ vs0Priority,
        vs[0].bottom == rootSize.height - 40 ~ vs0Priority
    ])

    // `vs[i]` (i > 0) must be inside `vs[0]`.
    for (i, v) in vs.enumerated() where i > 0 {
        constraints.append(contentsOf: [
            v.top >= vs[0].top ~ .required,
            v.left >= vs[0].left ~ .required,
            v.right <= vs[0].right ~ .required,
            v.bottom <= vs[0].bottom ~ .required
        ])
    }

    return constraints
}

// Future TODO.
let example0 = Example("0. Inner tile for future dragging example (not used)", setup: .removeAll) { rootSize in
    return { vs in
        var constraints = setupView0(rootSize: rootSize, pairs: [vs[0], vs[1]])
        constraints.append(contentsOf: [
            vs[1].left == vs[0].left + 20 ~ .required,
            vs[1].right == vs[0].right - 20 ~ .required,
            vs[1].top == vs[0].top + 20 ~ .required,
            vs[1].bottom == vs[0].bottom - 20 ~ .required
        ])
        return constraints
    }
}

let example1 = Example("1. Initial", setup: .removeAll) { rootSize in
    return { vs in
        var constraints = setupView0(rootSize: rootSize, pairs: vs)

        constraints.append(contentsOf: [
            // Aspect ratio
            vs[1].width == vs[1].height ~ .required,
            vs[2].width == vs[2].height * 0.75 ~ .required,
            vs[3].width == vs[3].height * 1.25 ~ .required,
            vs[4].width == vs[4].height ~ .required,

            // Width (set priority below `vs0Priority` to not expand superview size)
            vs[1].width == 150 ~ .medium,
            vs[2].width == vs[1].width * 0.5 ~ .medium,
            vs[3].width == vs[1].width * 1.25 ~ .medium,
            vs[4].width == vs[1].width * 0.75 ~ .medium,

            // Padding
            vs[1].left == 40 ~ .low,
            vs[1].top == 40 ~ .low,
            vs[2].right == 310 ~ .low,
            vs[2].top == 220 ~ .low,
            vs[3].right == 120 ~ .low,
            vs[3].top == 340 ~ .low,
            vs[4].right == 330 ~ .low,
            vs[4].top == 420 ~ .low,
        ])

        return constraints
    }
}

let example2 = Example("2. Incremental Add", setup: .none) { rootSize in
    return { vs in
        return [
            vs[1].width <= 50 ~ .high,
            vs[1].top >= 180 ~ .high,
            vs[1].left >= 180 ~ .high,
        ]
    }
}

let example3 = Example("3. Equal spacing", setup: .removeAll) { rootSize in
    return { vs in
        var constraints = setupView0(rootSize: rootSize, pairs: vs)

        constraints.append(contentsOf: [
            // Width
            vs[1].width >= vs[0].width / 4 ~ .high,
            vs[2].width >= vs[0].width / 4 ~ .high,
            vs[3].width >= vs[0].width / 4 ~ .high,
            vs[4].width >= vs[0].width / 4 ~ .high,

            // Height
            vs[1].height >= vs[0].height / 4 ~ .high,
            vs[2].height >= vs[0].height / 4 ~ .high,
            vs[3].height >= vs[0].height / 4 ~ .high,
            vs[4].height >= vs[0].height / 4 ~ .high,

            // x-axis equal distribution
            vs[1].left - vs[0].left == vs[2].left - vs[1].right ~ .required,
            vs[1].left - vs[0].left == vs[0].right - vs[2].right ~ .required,
            vs[1].top == vs[2].top ~ .required,
            vs[1].bottom == vs[2].bottom ~ .required,
            vs[1].left >= vs[0].left + 20 ~ .required,

            // y-axis equal distribution
            vs[1].top - vs[0].top == vs[3].top - vs[1].bottom ~ .required,
            vs[1].top - vs[0].top == vs[0].bottom - vs[3].bottom ~ .required,
            vs[1].left == vs[3].left ~ .required,
            vs[1].right == vs[3].right ~ .required,
            vs[1].top >= vs[0].top + 20 ~ .required,

            // `vs[4]`
            vs[4].left == vs[2].left ~ .required,
            vs[4].right == vs[2].right ~ .required,
            vs[4].top == vs[3].top ~ .required,
            vs[4].bottom == vs[3].bottom ~ .required,
        ])

        return constraints
    }
}

let example4 = Example("4. Equal spacing + Square", setup: .none) { rootSize in
    return { vs in
        return [
            vs[1].width == vs[1].height ~ .required,
            vs[2].width == vs[2].height ~ .required,
            vs[3].width == vs[3].height ~ .required,
            vs[4].width == vs[4].height ~ .required,
        ]
    }
}
