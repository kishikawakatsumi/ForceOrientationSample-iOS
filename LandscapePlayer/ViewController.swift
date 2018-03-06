//
//  ViewController.swift
//  LandscapePlayer
//
//  Created by Kishikawa Katsumi on 2018/02/12.
//  Copyright © 2018 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class ViewController : UIViewController, UIViewControllerTransitioningDelegate {
    @IBOutlet weak var playerView: UIView!
    let transition = TransitionAnimator()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerView.isHidden = false
    }

    @IBAction func toFullScreen(_ sender: UIButton) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: String(describing: PlayerViewController.self)) {
            viewController.transitioningDelegate = self
            present(viewController, animated: true, completion: nil)
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let playerViewSnapshot = playerView.snapshotView(afterScreenUpdates: false)
        playerViewSnapshot?.frame = playerView.frame

        transition.presenting = true
        transition.playerViewSnapshot = playerViewSnapshot!

        playerView.isHidden = true

        return transition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}

class PlayerViewController : UIViewController {
    @IBOutlet weak var dismissButton: UIButton!

    @IBAction func dismiss(_ sender: UIButton) {
        dismissButton.isHidden = true
        dismiss(animated: true, completion: nil)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }


    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    override var shouldAutorotate: Bool {
        return false
    }
}

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.3
    var presenting = true

    var playerViewSnapshot = UIView()

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!

        let toViewController = transitionContext.viewController(forKey: .to)!

        let finalFrame = transitionContext.finalFrame(for: toViewController)
        let targetTransform = transitionContext.targetTransform

        let snapshotView = playerViewSnapshot.snapshotView(afterScreenUpdates: true)!
        snapshotView.frame = playerViewSnapshot.frame

        let backgroundView = UIView(frame: containerView.frame)
        backgroundView.backgroundColor = .white
        containerView.insertSubview(backgroundView, belowSubview: fromView)

        toView.isHidden = true
        toView.transform = targetTransform
        toView.frame = finalFrame
        containerView.addSubview(toView)

        if presenting {
            snapshotView.transform = fromView.transform
            snapshotView.frame.origin.x = playerViewSnapshot.frame.origin.y
            snapshotView.frame.origin.y = playerViewSnapshot.frame.origin.x
            containerView.insertSubview(snapshotView, belowSubview: toView)

            UIView.animate(withDuration: duration, animations: {
                snapshotView.transform = targetTransform
                snapshotView.frame = finalFrame
            }) { _ in
                snapshotView.removeFromSuperview()
                toView.isHidden = false
                transitionContext.completeTransition(true)
            }
        } else {
            UIView.animate(withDuration: duration, animations: {
                fromView.transform = snapshotView.transform
                fromView.frame = snapshotView.frame
            }) { _ in
                toView.isHidden = false
                transitionContext.completeTransition(true)
            }
        }
    }
}
