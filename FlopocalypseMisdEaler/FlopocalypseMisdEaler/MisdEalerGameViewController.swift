//
//  GameViewController.swift
//  FlopocalypseMisdEaler
//
//  Created by FlopocalypseMisdEaler on 2025/3/8.
//


import UIKit
import SpriteKit

final class MisdEalerGameViewController: UIViewController {
    private let transition = SKTransition.push(with: .up, duration: 0.3)

  private var skView: SKView {
    return view as! SKView
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .landscape
  }
  
  override var shouldAutorotate: Bool {
    return false
  }
  
  override func loadView() {
    view = SKView()
  }
  
    

  override func viewDidLoad() {
    super.viewDidLoad()
      skView.presentScene(MisdEalerGameScene(model: MisdEalerGameModel()), transition: self.transition)
    //skView.presentScene(MenuScene())
    
    MisdEalerGameCenterHelper.helper.viewController = self
  }
  
}
