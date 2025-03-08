//
//  GameScene.swift
//  FlopocalypseMisdEaler
//
//  Created by FlopocalypseMisdEaler on 2025/3/8.
//


import SpriteKit

final class MisdEalerGameScene: SKScene {
  
  // MARK: - Enums
  
    private enum NodeLayer: CGFloat {
      case background = 100
      case board = 101
      case token = 102
      case ui = 1000
    }
  
  // MARK: - Properties
    var backButtonTappedAction: (() -> Void)?

    private var model: MisdEalerGameModel
    
    private var boardNode: MisdEalerBoardNode!
    private var messageNode: MisdEalerInformationNode!
    private var selectedTokenNode: MisdEalerTokenNode?
    
    private var highlightedTokens = [SKNode]()
    private var removableNodes = [MisdEalerTokenNode]()
    
    private var isSendingTurn = false
    
    private let successGenerator = UINotificationFeedbackGenerator()
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
  
  // MARK: Computed
  
    private var viewWidth: CGFloat {
      return view?.frame.size.width ?? 0
    }
    
    private var viewHeight: CGFloat {
      return view?.frame.size.height ?? 0
    }
  
  // MARK: - Init
  
    init(model: MisdEalerGameModel) {
       self.model = model
       
       super.init(size: .zero)
       
       scaleMode = .resizeFill
     }
  
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

  
    override func didMove(to view: SKView) {
      super.didMove(to: view)
      
      successGenerator.prepare()
      feedbackGenerator.prepare()
      
      setUpScene(in: view)
    }
  
    override func didChangeSize(_ oldSize: CGSize) {
       removeAllChildren()
       setUpScene(in: view)
     }
  
  // MARK: - Setup
  
    private func setUpScene(in view: SKView?) {
       guard viewWidth > 0 else {
         return
       }
       
       backgroundColor = .background

        // Add background image with aspect fill
        let backgroundImage = SKSpriteNode(imageNamed: "ic_bg")
        backgroundImage.position = CGPoint(x: viewWidth / 2, y: viewHeight / 2)
        
        // Calculate aspect fill scaling
        let textureSize = backgroundImage.texture?.size() ?? CGSize(width: 1, height: 1)
        let scaleX = viewWidth / textureSize.width
        let scaleY = viewHeight / textureSize.height
        let scale = max(scaleX, scaleY) // Pick the larger scale to ensure it fills the screen
        
        backgroundImage.setScale(scale)
        backgroundImage.zPosition = NodeLayer.background.rawValue
        
        addChild(backgroundImage)
        
        let backButton = SKSpriteNode(imageNamed: "ic_back")
        backButton.name = "backButton"
        backButton.size = CGSize(width: 44, height: 44)
        let heightScreen = UIScreen.main.bounds.height
        backButton.position = CGPoint(x: 72, y: heightScreen - 44)
        backButton.zPosition = NodeLayer.ui.rawValue + 1
        addChild(backButton)
        
     
        
       let padding: CGFloat = 40
       let boardSideLength = min(viewWidth, viewHeight) - (padding * 2)
       boardNode = MisdEalerBoardNode(sideLength: boardSideLength)
       boardNode.zPosition = NodeLayer.board.rawValue
       boardNode.position = CGPoint(
        x: viewWidth / 1.5,
         y: viewHeight / 2
       )
       
       addChild(boardNode)
       
       if !MisdEalerGameCenterHelper.helper.canTakeTurnForCurrentMatch {
         let coverSize = CGSize(
           width: boardSideLength + 50,
           height: boardSideLength + 50
         )
         let coverNode = SKSpriteNode(color: .background, size: coverSize)
         coverNode.zPosition = NodeLayer.ui.rawValue + 1
         coverNode.position = boardNode.position
         coverNode.alpha = 0.6
         addChild(coverNode)
       }
       
       let messageSize = CGSize(width: viewWidth / 3, height: 60)
       messageNode = MisdEalerInformationNode(model.messageToDisplay, size: messageSize)
       messageNode.zPosition = NodeLayer.ui.rawValue
       messageNode.position = CGPoint(
         x: 60,
         y: 44
       )
       addChild(messageNode)
       

       
       loadTokens()
     }
  
  // MARK: - Touches
    @objc private func backButtonTapped() {
        print("Back tapped")
        
        if let navigationController = self.view?.window?.rootViewController as? UINavigationController {
            // If inside a navigation stack, pop it
            navigationController.popViewController(animated: true)
        } else {
            // If presented modally, dismiss it
            self.view?.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            handleTouch(touch)
        }
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        if let backButton = childNode(withName: "backButton"), backButton.contains(touchLocation) {
            backButtonTapped()
        }
    }
    

  
  private func handleTouch(_ touch: UITouch) {
    guard !isSendingTurn && MisdEalerGameCenterHelper.helper.canTakeTurnForCurrentMatch else {
      return
    }
    
    guard model.winner == nil else {
      return
    }
    
    let location = touch.location(in: self)
    
    if model.isCapturingPiece {
      handleRemoval(at: location)
      return
    }
    
    switch model.state {
    case .placement:
      handlePlacement(at: location)
      
    case .movement:
      handleMovement(at: location)
    }
  }
  
  // MARK: - Spawning
  
  private func loadTokens() {
    for token in model.tokens {
      guard let boardPointNode = boardNode.node(at: token.coord, named: MisdEalerBoardNode.boardPointNodeName) else {
        return
      }
      
      spawnToken(at: boardPointNode.position, for: token.player)
    }
  }
  
  private func spawnToken(at point: CGPoint, for player: MisdEalerGameModel.Player) {
    let tokenNode = MisdEalerTokenNode(type: player)
    
    tokenNode.zPosition = NodeLayer.token.rawValue
    tokenNode.position = point
    
    boardNode.addChild(tokenNode)
  }
  
  // MARK: - Helpers
  

  
  private func handlePlacement(at location: CGPoint) {
    let node = atPoint(location)
    
    guard node.name == MisdEalerBoardNode.boardPointNodeName else {
      return
    }
    
    guard let coord = boardNode.gridCoordinate(for: node) else {
      return
    }
    
    spawnToken(at: node.position, for: model.currentPlayer)
    model.placeToken(at: coord)
    
    processGameUpdate()
  }
  
  private func handleMovement(at location: CGPoint) {
    let node = atPoint(location)
    
    if let selected = selectedTokenNode {
      if highlightedTokens.contains(node) {
        let selectedSceneLocation = convert(selected.position, from: boardNode)
        
        guard let fromCoord = gridCoordinate(at: selectedSceneLocation), let toCoord = boardNode.gridCoordinate(for: node) else {
          return
        }
        
        model.move(from: fromCoord, to: toCoord)
        processGameUpdate()
        
        selected.run(SKAction.move(to: node.position, duration: 0.175))
      }
      
      deselectCurrentToken()
    } else {
      guard let token = node as? MisdEalerTokenNode, token.type == model.currentPlayer else {
        return
      }
      
      selectedTokenNode = token
      
      if model.tokenCount(for: model.currentPlayer) == 3 {
        highlightTokens(at: model.emptyCoordinates)
        return
      }
      
      guard let coord = gridCoordinate(at: location) else {
        return
      }
      
      highlightTokens(at: model.neighbors(at: coord))
        updateGameState(model)
    }
  }
  
  private func handleRemoval(at location: CGPoint) {
    let node = atPoint(location)
    
    guard let tokenNode = node as? MisdEalerTokenNode, tokenNode.type == model.currentOpponent else {
      return
    }
    
    guard let coord = gridCoordinate(at: location) else {
      return
    }
    
    guard model.removeToken(at: coord) else {
      return
    }
    
    tokenNode.remove()
    removableNodes.forEach { node in
      node.isIndicated = false
    }
    
    processGameUpdate()
      updateGameState(model)
  }
  
    
    func updateGameState(_ gameModel: MisdEalerGameModel) {
        // Update the UI with the message to display
       // gameMessageLabel.text = gameModel.messageToDisplay
        
        // Check if there is a winner, and pop the view controller
        if let winner = gameModel.winner {
            if let navigationController = self.view?.window?.rootViewController as? UINavigationController {
                // If inside a navigation stack, pop it
                navigationController.popViewController(animated: true)
            } else {
                // If presented modally, dismiss it
                self.view?.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
  private func gridCoordinate(at location: CGPoint) -> MisdEalerGameModel.GridCoordinate? {
    guard let boardPointNode = nodes(at: location).first(where: { $0.name == MisdEalerBoardNode.boardPointNodeName }) else {
      return nil
    }
    
    return boardNode.gridCoordinate(for: boardPointNode)
  }
  
  private func highlightTokens(at coords: [MisdEalerGameModel.GridCoordinate]) {
    let tokensFromCoords = coords.compactMap { coord in
      return self.boardNode.node(at: coord, named: MisdEalerBoardNode.boardPointNodeName)
    }
    
    highlightedTokens = tokensFromCoords
    
    for neighborNode in highlightedTokens {
      neighborNode.run(SKAction.scale(to: 1.25, duration: 0.15))
    }
  }
  
  private func deselectCurrentToken() {
    selectedTokenNode = nil
    
    guard !highlightedTokens.isEmpty else {
      return
    }
    
    highlightedTokens.forEach { node in
      node.run(SKAction.scale(to: 1, duration: 0.15))
    }
    
    highlightedTokens.removeAll()
  }
  
  private func processGameUpdate() {
    messageNode.text = model.messageToDisplay
    
    if model.isCapturingPiece {
      successGenerator.notificationOccurred(.success)
      successGenerator.prepare()
      
      let tokens = model.removableTokens(for: model.currentOpponent)
      
      if tokens.isEmpty {
        model.advance()
        processGameUpdate()
        return
      }
      
      let nodes = tokens.compactMap { token in
        boardNode.node(at: token.coord, named: MisdEalerTokenNode.tokenNodeName) as? MisdEalerTokenNode
      }
      
      removableNodes = nodes
      
      nodes.forEach { node in
        node.isIndicated = true
      }
    } else {
      feedbackGenerator.impactOccurred()
      feedbackGenerator.prepare()
      
      if model.winner != nil {
        MisdEalerGameCenterHelper.helper.win { error in
          if let e = error {
            print("Error winning match: \(e.localizedDescription)")
            return
          }
          
         
        }
      } else {
        MisdEalerGameCenterHelper.helper.endTurn(model) { error in
          if let e = error {
            print("Error ending turn: \(e.localizedDescription)")
            return
          }
          
          
        }
      }
    }
  }
}
