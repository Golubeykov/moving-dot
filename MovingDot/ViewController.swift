//
//  ViewController.swift
//  MovingDot
//
//  Created by Антон Голубейков on 07.10.2024.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Subviews

    let greenDot: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.cornerRadius = 15
        view.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return view
    }()

    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.addTarget(self, action: #selector(startAnimation), for: .touchUpInside)
        return button
    }()

    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelAnimation), for: .touchUpInside)
        return button
    }()


    // MARK: - Properties

    lazy var initialDotCenter: CGPoint = .init(x: view.bounds.midX, y: 100)
    var initialDotSize: CGSize = .init(width: 30, height: 30)

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(greenDot)

        greenDot.center = CGPoint(x: view.bounds.midX, y: 100)
        initialDotCenter = greenDot.center
        initialDotSize = greenDot.bounds.size

        view.addSubview(startButton)
        view.addSubview(cancelButton)

        startButton.frame = CGRect(x: view.bounds.midX - 100, y: view.bounds.height - 100, width: 80, height: 40)
        cancelButton.frame = CGRect(x: view.bounds.midX + 20, y: view.bounds.height - 100, width: 80, height: 40)
    }

}

// MARK: - Private methods

private extension ViewController {

    @objc 
    func startAnimation() {
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.values = [
            NSValue(cgPoint: CGPoint(x: self.view.bounds.midX, y: 100)),
            NSValue(cgPoint: CGPoint(x: self.view.bounds.midX, y: self.view.bounds.maxY - 150))
        ]
        positionAnimation.keyTimes = [0, 1]
        positionAnimation.duration = 1.0

        let sizeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        sizeAnimation.values = [1.0, 1.5, 1.0]
        sizeAnimation.keyTimes = [0, 0.5, 1.0]
        sizeAnimation.duration = 1.0

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [positionAnimation, sizeAnimation]
        animationGroup.duration = 1.0

        greenDot.layer.add(animationGroup, forKey: "moveAndResize")

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.greenDot.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.maxY - 150)
            self.greenDot.transform = .identity
        }
        CATransaction.commit()
    }

    @objc
    func cancelAnimation() {
        let currentScale = greenDot.layer.presentation()?.value(forKeyPath: "transform.scale") as? CGFloat ?? 1.0
        let currentPosition = greenDot.layer.presentation()?.position ?? initialDotCenter

        let intermediateScaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        if currentScale < 1.5 {
            intermediateScaleAnimation.fromValue = currentScale
            intermediateScaleAnimation.toValue = 1.5
            intermediateScaleAnimation.duration = 0.5
        } else {
            intermediateScaleAnimation.duration = 0.0
        }

        let sizeResetAnimation = CABasicAnimation(keyPath: "transform.scale")
        sizeResetAnimation.fromValue = 1.5
        sizeResetAnimation.toValue = 1.0
        sizeResetAnimation.beginTime = intermediateScaleAnimation.duration
        sizeResetAnimation.duration = 0.5

        let positionResetAnimation = CABasicAnimation(keyPath: "position")
        positionResetAnimation.fromValue = NSValue(cgPoint: currentPosition)
        positionResetAnimation.toValue = NSValue(cgPoint: initialDotCenter)
        positionResetAnimation.duration = 1.0

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [intermediateScaleAnimation, sizeResetAnimation, positionResetAnimation]
        animationGroup.duration = intermediateScaleAnimation.duration + sizeResetAnimation.duration

        greenDot.layer.add(animationGroup, forKey: "resetSizeAndPosition")

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.greenDot.transform = .identity
            self.greenDot.center = self.initialDotCenter
        }
        CATransaction.commit()
    }
    
}
