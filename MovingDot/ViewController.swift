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
        view.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        view.layer.cornerRadius = 15
        return view
    }()

    // MARK: - Properties

    var isAnimating = false
    var currentAnimation: UIViewPropertyAnimator?

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        self.view.addSubview(greenDot)
        greenDot.center = self.view.center

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }

}

// MARK: - Private methods

private extension ViewController {

    @objc 
    func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.view)

        if let animation = currentAnimation, animation.isRunning {
            animation.stopAnimation(true)
            greenDot.layer.removeAllAnimations()
        }
        animateDotPositionWithKeyFrames(to: tapLocation)

        // Добавить на движение изменение scale точки (ув-ся на 150% и в конце вернуться в 100%)
        // Менять цвет (менять % в зависимости от прогресса)
        // Все должно быть одновременно
        // При прерывании возвращаемся в исходный размер, но плавно
        // Кнопка cancel, пока без прерывания

        // Если получится, то перегнать все это в группы анимации, CABasicAnimation (CAAnimationGroup). Есть еще какой-то делегат.
        // CATransaction (это аналоги completion)

        // Посмотри LayerAnimator в BurgerKing (но лучше погуглить на чистой анимации)
    }

    func animateDotPosition(to position: CGPoint) {
        currentAnimation = UIViewPropertyAnimator(duration: 1.0, curve: .easeInOut, animations: {
            self.greenDot.center = position
            self.greenDot.frame.size = .init(width: 30, height: 30)
        })
        currentAnimation?.startAnimation()
    }

    // Починить прерывание в keyframe (почему так, если оно не работает) - DONE
    func animateDotPositionWithKeyFrames(to position: CGPoint) {
        stopAnimationAndMoveDot()

        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.duration = 1.0
        
        let path = UIBezierPath()
        path.move(to: greenDot.center)
        path.addLine(to: position)

        animation.path = path.cgPath
        greenDot.layer.add(animation, forKey: "moveDot")
        greenDot.center = position
    }

    func stopAnimationAndMoveDot() {
        if let presentationLayer = greenDot.layer.presentation() {
            greenDot.layer.removeAllAnimations()
            greenDot.center = presentationLayer.position
        }
    }

}

