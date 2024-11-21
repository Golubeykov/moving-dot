//
//  ViewController.swift
//  MovingDot
//
//  Created by Антон Голубейков on 07.10.2024.
//

import UIKit

final class ViewController: UIViewController {

    // MARK: - Subviews

    private let movingDot: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.cornerRadius = 15
        view.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return view
    }()

    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.addTarget(self, action: #selector(startAnimation), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelAnimation), for: .touchUpInside)
        return button
    }()


    // MARK: - Properties

    private let initialDotY: CGFloat = 100
    private let finalDotY: CGFloat = 700
    private lazy var initialDotCenter: CGPoint = .init(x: view.bounds.midX, y: initialDotY)
    private let initialDotSize: CGSize = .init(width: 30, height: 30)

    private let animationDuration: CGFloat = 2.0

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(movingDot)
        movingDot.center = initialDotCenter

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
            NSValue(cgPoint: CGPoint(x: self.view.bounds.midX, y: initialDotY)),
            NSValue(cgPoint: CGPoint(x: self.view.bounds.midX, y: finalDotY))
        ]
        positionAnimation.keyTimes = [0, 1]
        positionAnimation.duration = animationDuration

        let sizeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        sizeAnimation.values = [1.0, 1.5, 1.0]
        sizeAnimation.keyTimes = [0, 0.5, 1.0]
        sizeAnimation.duration = animationDuration

        let colorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        colorAnimation.fromValue = UIColor.green.cgColor
        colorAnimation.toValue = UIColor.blue.cgColor
        colorAnimation.duration = animationDuration

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [positionAnimation, sizeAnimation, colorAnimation]
        animationGroup.duration = animationDuration

        movingDot.layer.add(animationGroup, forKey: "moveResizeAndChangeColor")

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.movingDot.center = CGPoint(x: self.view.bounds.midX, y: self.finalDotY)
            self.movingDot.transform = .identity
            self.movingDot.backgroundColor = .blue
        }
        CATransaction.commit()
    }

    @objc
    func cancelAnimation() {
        movingDot.layer.removeAllAnimations()

        let currentScale = movingDot.layer.presentation()?.value(forKeyPath: "transform.scale") as? CGFloat ?? 1.0
        let currentPosition = movingDot.layer.presentation()?.position ?? initialDotCenter
        let currentColor = movingDot.layer.presentation()?.value(forKeyPath: "backgroundColor") ?? UIColor.green.cgColor

        let intermediateScaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        let relativeYPosition = currentPosition.y - 100
        let isPassedHalfOfWay: Bool = relativeYPosition > (finalDotY - initialDotY) / 2
        let passedPercentage: CGFloat = relativeYPosition / (finalDotY - initialDotY)

        if isPassedHalfOfWay {
            intermediateScaleAnimation.fromValue = currentScale
            intermediateScaleAnimation.toValue = 1.5
            intermediateScaleAnimation.duration = (passedPercentage - 0.5) * animationDuration

        } else {
            intermediateScaleAnimation.duration = 0.0
        }

        let sizeResetAnimation = CABasicAnimation(keyPath: "transform.scale")
        sizeResetAnimation.fromValue = isPassedHalfOfWay ? 1.5 : currentScale
        sizeResetAnimation.toValue = 1.0
        sizeResetAnimation.beginTime = intermediateScaleAnimation.duration
        sizeResetAnimation.duration = isPassedHalfOfWay ? 0.5 * animationDuration : passedPercentage * animationDuration

        let positionResetAnimation = CABasicAnimation(keyPath: "position")
        positionResetAnimation.fromValue = NSValue(cgPoint: currentPosition)
        positionResetAnimation.toValue = NSValue(cgPoint: initialDotCenter)
        positionResetAnimation.duration = passedPercentage * animationDuration

        let colorResetAnimation = CABasicAnimation(keyPath: "backgroundColor")
        colorResetAnimation.fromValue = currentColor
        colorResetAnimation.toValue = UIColor.green.cgColor
        colorResetAnimation.duration = passedPercentage * animationDuration

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [intermediateScaleAnimation, sizeResetAnimation, positionResetAnimation, colorResetAnimation]
        animationGroup.duration = passedPercentage * animationDuration

        movingDot.layer.add(animationGroup, forKey: "resetAnimations")

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.movingDot.transform = .identity
            self.movingDot.center = self.initialDotCenter
            self.movingDot.backgroundColor = .green
        }
        CATransaction.commit()
    }
    
}
