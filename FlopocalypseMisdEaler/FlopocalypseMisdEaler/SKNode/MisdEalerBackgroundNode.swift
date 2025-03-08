//
//  BackgroundNode.swift
//  FlopocalypseMisdEaler
//
//  Created by FlopocalypseMisdEaler on 2025/3/8.
//


import Foundation
import SpriteKit

class MisdEalerBackgroundNode: SKSpriteNode {
  
  enum Kind {
    case pill
    case recessed
  }
  
  init(kind: Kind, size: CGSize, color: UIColor? = nil) {
    let texture: SKTexture
    
    switch kind {
    case .pill:
      texture = SKTexture.pillBackgroundTexture(of: size, color: color)
    default:
      texture = SKTexture.recessedBackgroundTexture(of: size)
    }
    
    super.init(texture: texture, color: .clear, size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
