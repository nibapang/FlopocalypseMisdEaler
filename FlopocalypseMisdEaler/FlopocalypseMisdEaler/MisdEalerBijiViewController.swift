//
//  BijiViewController.swift
//  FlopocalypseMisdEaler
//
//  Created by FlopocalypseMisdEaler on 2025/3/8.
//


import UIKit

class MisdEalerBijiViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var boardView: UIView!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var player1ScoreLabel: UILabel!
    @IBOutlet weak var player2ScoreLabel: UILabel!
    
    // Game board properties
    private let columns = 7
    private let rows = 6
    private var board: [[Int]] = []
    private var currentPlayer = 1 
    private var player1Score = 0
    private var player2Score = 0
    
    // UI Elements
    private var slots: [[UIButton]] = []
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
    }
    
    // MARK: - IBActions
    @IBAction func newGameButtonTapped(_ sender: UIButton) {
        setupGame()
    }
    
    private func setupGame() {
        // Initialize empty board
        board = Array(repeating: Array(repeating: 0, count: rows), count: columns)
        currentPlayer = 1
        turnLabel.text = "Current Player: ♥️"
        updateScoreLabels()
        setupBoardUI()
    }
    
    private func setupBoardUI() {
        // Clear existing slots
        slots.forEach { column in
            column.forEach { $0.removeFromSuperview() }
        }
        slots.removeAll()
        
        
        // Calculate slot size based on the smaller of width/height to maintain square slots
        let boardWidth = boardView.bounds.width
        let boardHeight = boardView.bounds.height
        let slotSize = min(boardWidth / CGFloat(columns), boardHeight / CGFloat(rows))
        
        // Calculate padding to center the board
        let horizontalPadding = (boardWidth - (CGFloat(columns) * slotSize)) / 2
        let verticalPadding = (boardHeight - (CGFloat(rows) * slotSize)) / 2
        
        for column in 0..<columns {
            var columnButtons: [UIButton] = []
            
            for row in 0..<rows {
                let button = UIButton()
                button.backgroundColor = .white
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.systemBlue.cgColor
                button.translatesAutoresizingMaskIntoConstraints = false
                boardView.addSubview(button)
                
                // Make the button circular
                button.layer.cornerRadius = (slotSize - 4) / 2
                button.clipsToBounds = true
                
                NSLayoutConstraint.activate([
                    button.widthAnchor.constraint(equalToConstant: slotSize - 4),
                    button.heightAnchor.constraint(equalToConstant: slotSize - 4),
                    button.leftAnchor.constraint(equalTo: boardView.leftAnchor, constant: horizontalPadding + CGFloat(column) * slotSize + 4),
                    button.bottomAnchor.constraint(equalTo: boardView.bottomAnchor, constant: -verticalPadding - CGFloat(row) * slotSize - 4)
                ])
                
                columnButtons.append(button)
            }
            slots.append(columnButtons)
            
            // Add column tap button
            let columnTap = UIButton()
            columnTap.tag = column
            columnTap.backgroundColor = .clear
            columnTap.translatesAutoresizingMaskIntoConstraints = false
            columnTap.addTarget(self, action: #selector(columnTapped(_:)), for: .touchUpInside)
            boardView.addSubview(columnTap)
            
            NSLayoutConstraint.activate([
                columnTap.topAnchor.constraint(equalTo: boardView.topAnchor, constant: verticalPadding),
                columnTap.bottomAnchor.constraint(equalTo: boardView.bottomAnchor, constant: -verticalPadding),
                columnTap.widthAnchor.constraint(equalToConstant: slotSize),
                columnTap.leftAnchor.constraint(equalTo: boardView.leftAnchor, constant: horizontalPadding + CGFloat(column) * slotSize)
            ])
        }
    }
    
    @objc private func columnTapped(_ sender: UIButton) {
        let column = sender.tag
        print("Column tapped: \(column)") // Debug print

        if let row = findHighestEmptyRow(in: column) { // Find the highest empty row
            print("Placing token at row: \(row)") // Debug print
            animateTokenDrop(in: column, at: row)
        }
    }


    private func findHighestEmptyRow(in column: Int) -> Int? {
        for row in 0..<rows { // Start from the TOP row moving downward
            if board[column][row] == 0 {
                return row
            }
        }
        return nil
    }


    private func placeToken(in column: Int, at row: Int) {
        let button = slots[column][row]
        button.setTitle(currentPlayer == 1 ? "♥️" : "♠️", for: .normal)
        button.backgroundColor = .white // Keep background white
        button.titleLabel?.font = .systemFont(ofSize: 24) // Adjust size as needed
        board[column][row] = currentPlayer
        
        if checkWinCondition(at: column, row: row) {
            showWinAlert()
        } else {
            currentPlayer = currentPlayer == 1 ? 2 : 1
            turnLabel.text = "Current Player: \(currentPlayer == 1 ? "♥️" : "♠️")"
        }
    }
    
    
    private func animateTokenDrop(in column: Int, at row: Int) {
        let button = slots[column][row]
        let tokenSize = button.bounds.width

        // Create a label for the suit symbol
        let tokenLabel = UILabel(frame: CGRect(
            x: button.frame.origin.x,
            y: -tokenSize,
            width: tokenSize,
            height: tokenSize
        ))
        tokenLabel.text = currentPlayer == 1 ? "♥️" : "♠️"
        tokenLabel.font = .systemFont(ofSize: 24)
        tokenLabel.textAlignment = .center
        tokenLabel.backgroundColor = .white
        tokenLabel.layer.cornerRadius = tokenSize / 2
        tokenLabel.clipsToBounds = true
        boardView.addSubview(tokenLabel)

        let finalY = button.frame.origin.y

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {
            tokenLabel.frame.origin.y = finalY
        } completion: { [weak self] _ in
            guard let self = self else { return }
            tokenLabel.removeFromSuperview()
            self.placeToken(in: column, at: row)
        }
    }

    
    private func checkWinCondition(at column: Int, row: Int) -> Bool {
        let directions: [(dx: Int, dy: Int)] = [
            (1, 0),   // horizontal
            (0, 1),   // vertical
            (1, 1),   // diagonal right
            (1, -1)   // diagonal left
        ]
        
        for (dx, dy) in directions {
            var count = 1
            
            // Check in positive direction
            var c = column + dx
            var r = row + dy
            while c >= 0 && c < columns && r >= 0 && r < rows && board[c][r] == currentPlayer {
                count += 1
                if count >= 4 { return true }
                c += dx
                r += dy
            }
            
            // Check in negative direction
            c = column - dx
            r = row - dy
            while c >= 0 && c < columns && r >= 0 && r < rows && board[c][r] == currentPlayer {
                count += 1
                if count >= 4 { return true }
                c -= dx
                r -= dy
            }
        }
        
        return false
    }
    
    private func updateScoreLabels() {
        player1ScoreLabel.text = "♥️: \(player1Score)"
        player2ScoreLabel.text = "♠️: \(player2Score)"
    }
    
    private func showWinAlert() {
        let winner = currentPlayer == 1 ? "♥️" : "♠️"
        
        // Update scores
        if currentPlayer == 1 {
            player1Score += 1
        } else {
            player2Score += 1
        }
        updateScoreLabels()
        
        let alert = UIAlertController(
            title: "Game Over!",
            message: "\(winner) wins!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "New Game", style: .default) { [weak self] _ in
            self?.setupGame()
        })
        present(alert, animated: true)
    }
 
    @IBAction func back(_ sender :UIButton)
    {
        navigationController?.popViewController(animated: true)
    }

}
