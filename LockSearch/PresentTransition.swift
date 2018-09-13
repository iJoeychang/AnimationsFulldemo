//
//  PresentTransition.swift.swift
//  Widgets
//
//  Created by chang on 2018/9/11.
//  Copyright © 2018年 Underplot ltd. All rights reserved.
//

import UIKit

class PresentTransition: UIPercentDrivenInteractiveTransition,UIViewControllerAnimatedTransitioning {
  
    var auxAnimations: (()-> Void)?
    var auxAnimationsCancel: (()-> Void)?
  
    var context: UIViewControllerContextTransitioning?
    var animator: UIViewPropertyAnimator?
  
    func transitionDuration(using transitionContext:
          UIViewControllerContextTransitioning?) -> TimeInterval {
         return 0.75
    }
  
    func animateTransition(using transitionContext:
         UIViewControllerContextTransitioning) {
      
      transitionAnimator(using: transitionContext).startAnimation()
      
    }
  
    func transitionAnimator(using transitionContext:
         UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
      
      let duration = transitionDuration(using: transitionContext)
      let container = transitionContext.containerView
      let to = transitionContext.view(forKey: .to)!
      container.addSubview(to)
      to.transform = CGAffineTransform(scaleX: 1.33, y:1.33) .concatenating(CGAffineTransform(translationX: 0.0, y: 200))
      to.alpha = 0
      
      let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut)
      
      animator.addAnimations({
        to.transform = CGAffineTransform(translationX: 0.0, y: 100)
      }, delayFactor: 0.15)
      
      animator.addAnimations({
        to.alpha = 1.0
      }, delayFactor: 0.5)
      
      animator.addCompletion { _ in
        transitionContext.completeTransition( !transitionContext.transitionWasCancelled )
      }
      
      if let auxAnimations = auxAnimations {
        animator.addAnimations(auxAnimations)
      }
      
      animator.addCompletion { position in
        
        switch position {
          case .end:
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
          default:
            self.auxAnimationsCancel?()
            transitionContext.completeTransition(false)
        }
      }
      
      self.animator = animator
      self.context = transitionContext
      
      animator.addCompletion { [unowned self] _ in
        self.animator = nil
        self.context = nil
      }
      // make sure the transition animation is interactive so that the user can continue interacting with the screen after they’ve paused it.
      animator.isUserInteractionEnabled = true
      
      return animator
  }
  
  func interruptibleAnimator(using transitionContext:
       UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
    
    return transitionAnimator(using: transitionContext)
    
  }
  
  func interruptTransition() {
    guard let context = context else {
      return
    }
    context.pauseInteractiveTransition()
    pause()
  }
}
