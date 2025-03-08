//
//  File.swift
//  FlopocalypseMisdEaler
//
//  Created by FlopocalypseMisdEaler on 2025/3/8.
//


import GameKit

extension GKTurnBasedMatch {
  
  var isLocalPlayersTurn: Bool {
    return currentParticipant?.player == GKLocalPlayer.local
  }
  
  var others: [GKTurnBasedParticipant] {
    return participants.filter {
      return $0.player != GKLocalPlayer.local
    }
  }
  
}
