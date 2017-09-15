import UIKit
import Cassowary

class ViewController: UIViewController
{
    @IBOutlet var exampleLabel: UILabel!

    private var tiles: [UIView] = []
    private var exampleManager: ExampleManager!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.tiles = (0..<5).map { _ in UIView() }
        print(self.tiles)

        for (i, tile) in self.tiles.enumerated() {
            let label = UILabel()
            label.text = "\(i)"
            label.sizeToFit()
            tile.addSubview(label)

            if i == 0 {
                tile.backgroundColor = color(at: i, isVivid: false)
                self.view.addSubview(tile)
            }
            else {
                tile.backgroundColor = color(at: i, isVivid: true)
                self.tiles[0].addSubview(tile)
            }
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.view.addGestureRecognizer(panGesture)

        self.exampleManager = ExampleManager { [weak self] example in
            self?.exampleLabel.text = example.name
        }

        self.exampleManager.setupInitialLayout(rootSize: self.view.bounds.size, views: self.tiles)
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()

        print(#function, self.view.bounds.size)

        self.exampleManager.reloadCurrentLayout(
            rootSize: self.view.bounds.size,
            views: self.tiles
        )

        UIView.animate(withDuration: 0.5, animations: {
            self.exampleManager.applyLayout()
        })
    }

    @objc
    func handleTap(_ gesture: UITapGestureRecognizer)
    {
        print(gesture)

        self.exampleManager.loadNextLayout(
            rootSize: self.view.bounds.size,
            views: self.tiles
        )

        UIView.animate(withDuration: 0.5, animations: {
            self.exampleManager.applyLayout()
        })
    }

    @objc
    func handlePan(_ gesture: UIPanGestureRecognizer)
    {
        // Dragging demo is not supported yet
    }
}

// MARK: For Debugging example0 (currently workarounded)

private var tapCount = 0

extension ViewController
{
    @objc
    func handleTap2(_ gesture: UITapGestureRecognizer)
    {
        let right = self.tiles[0].cassowary.right

        try! self.exampleManager.solver.beginEdit {
            try $0.addEditVariable(right, priority: .high)
        }

        tapCount += 1
        try! self.exampleManager.solver.suggest {
            try $0.suggestValue(tapCount % 2 == 1 ? 100 : 200, for: right)
        }

        try! self.exampleManager.solver.endEdit()
    }


    @objc
    func handlePan2(_ gesture: UIPanGestureRecognizer)
    {
        print(gesture)

        let right = self.tiles[0].cassowary.right
        let bottom = self.tiles[0].cassowary.bottom

        switch gesture.state {
        case .began:
            try! self.exampleManager.solver.beginEdit {
                try $0.addEditVariable(bottom, priority: .high + 1000)
                try $0.addEditVariable(right, priority: .high + 1000)
            }
        case .changed:
            let value = gesture.location(in: gesture.view)
            try! self.exampleManager.solver.suggest {
                try $0.suggestValue(Double(value.y), for: bottom)
                try $0.suggestValue(Double(value.x), for: right)
            }
            self.exampleManager.applyLayout()

            print("===> did suggestValue = \(value), solution = \(self.exampleManager.solver.cachedSolution)")

        case .ended, .cancelled:
            try! self.exampleManager.solver.endEdit()
        default:
            break
        }
    }
}

// MARK: Helpers

private func color(at index: Int, isVivid: Bool) -> UIColor
{
    let hue = (CGFloat(index) * 0.618033988749895).truncatingRemainder(dividingBy: 1)
    let saturation: CGFloat = isVivid ? 0.8 : 0.1
    return UIColor(hue: hue, saturation: saturation, brightness: 1, alpha: 0.8)
}
