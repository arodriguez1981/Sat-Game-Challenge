////
////  GameService.swift
////  Sat Game Challenge
////
////  Created by Alex on 3/19/25.
////
import Foundation
import Combine
import FirebaseDatabase

class GameService: NSObject, ObservableObject {
    internal var dbRef: DatabaseReference = Database.database().reference()
    internal var playerHost: String = ""
    internal var currentRoundIndex: Int = 0
    internal var timer: AnyCancellable?
    internal var notificationService: NotificationService
    
    // Public vars
    @Published var gameStatus: GameStatus = .uncreated
    @Published var localPlayer: String = ""
    @Published var currentTurn: String?
    @Published var answerOptions: [String] = []
    @Published var correctAnswer: String?
    @Published var scores: [String: Int] = [:]
    @Published var availableGames: [(id: String, name: String)] = []
    @Published var playerInvited: String = ""
    @Published var roundResult = RoundResult(winner: nil, playerResponses: [])
    @Published var allRoundResults: [RoundResult] = []
    @Published var currentQuestion: String?
    @Published var turnStarted: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var gameId: String?
    
    init(notificationService: NotificationService = NotificationService()) {
        self.notificationService = notificationService
        super.init()
        self.notificationService.requestNotificationPermission()
    }
    
    // MARK: - Game Creation and Joining
    @MainActor
    func createGame() async {
        let gameRef = dbRef.child("games").childByAutoId()
        let gameName = "Game \(Int.random(in: 1...9999))"
        
        let gameData: [String: Any] = [
            "name": gameName,
            "players": [:],
            "rounds": [generateRandomQuestion()],
            "currentRound": 0
        ]
        
        do {
            gameStatus = .created
            gameId = gameRef.key
            try await gameRef.setValue(gameData)
            await addPlayerHost(to: gameRef)
        } catch {
            print("Error creating game: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func joinGame(gameId: String) async {
        self.gameId = gameId
        let gameRef = dbRef.child("games").child(gameId)
        await addPlayerInvited(to: gameRef)
    }
    
    private func addPlayerHost(to gameRef: DatabaseReference) async {
        let playerId = UUID().uuidString
        do {
            try await gameRef.child("playerHost").setValue(playerId)
            try await gameRef.child("turn").setValue(playerId)
            
            await MainActor.run {
                UserDefaults.standard.set(playerId, forKey: "player")
                self.localPlayer = playerId
                self.listenForUpdates()
            }
        } catch {
            print("Error setting player host: \(error.localizedDescription)")
        }
    }
    
    private func addPlayerInvited(to gameRef: DatabaseReference) async {
        let playerId = UUID().uuidString
        do {
            try await gameRef.child("playerInvited").setValue(playerId)
            
            await MainActor.run {
                UserDefaults.standard.set(playerId, forKey: "player")
                self.localPlayer = playerId
                self.listenForUpdates()
            }
        } catch {
            print("Error adding player invited: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Game Management
    func exitGame() {
        if let gameId = gameId {
            deleteGame(gameId: gameId)
        }
    }
    
    func closeGame() {
        Task { @MainActor in
            self.playerInvited = ""
            self.gameStatus = .uncreated
            self.localPlayer = ""
            self.playerHost = ""
            self.currentRoundIndex = 0
        }
    }
    
    func deleteGame(gameId: String) {
        let gameRef = dbRef.child("games").child(gameId)
        gameRef.removeValue { error, _ in
            if let error = error {
                print("Error deleting game: \(error.localizedDescription)")
            } else {
                self.closeGame()
            }
        }
    }
    
    // MARK: - Fetch Available Games
    @MainActor
    func fetchAvailableGames() async {
        do {
            let snapshot = try await dbRef.child("games").getData()
            var gamesList: [(id: String, name: String)] = []
            
            for child in snapshot.children {
                if let gameSnapshot = child as? DataSnapshot,
                   let gameData = gameSnapshot.value as? [String: Any],
                   let gameName = gameData["name"] as? String,
                   let playerHost = gameSnapshot.childSnapshot(forPath: "playerHost").value as? String,
                   playerHost.isEmpty == false,
                   playerHost != self.localPlayer,
                   gameSnapshot.childSnapshot(forPath: "playerInvited").value as? String == nil {
                    gamesList.append((id: gameSnapshot.key, name: gameName))
                }
            }
            self.availableGames = gamesList
        } catch {
            print("Error fetching available games: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Game Updates
    func startGame() {
        Task { @MainActor in
            self.gameStatus = .started
            self.listenForUpdates()
            self.turnStarted = true
            self.startTimer()
        }
    }
    
    func startTurn() {
        self.turnStarted = true
        self.currentRoundIndex += 1
        self.startTimer()
    }
    
    // MARK: - Answer Submission
    func submitAnswer(answer: String) {
        guard let gameId = gameId, let correctAnswer = correctAnswer else { return }
        let isCorrect = answer == correctAnswer
        self.turnStarted = false
        let timetaken = elapsedTimeInMilliseconds()
        stopTimer()
        let gameRef = dbRef.child("games").child(gameId)
        gameRef.child("roundResults").childByAutoId().setValue([
            "player": localPlayer,
            "answer": answer,
            "correct": isCorrect,
            "round": self.currentRoundIndex,
            "time": timetaken
        ])
        DispatchQueue.main.async {
            self.checkAnswersAndUpdateScores(gameId: gameId)
        }
    }
    
    private func checkAnswersAndUpdateScores(gameId: String) {
        let gameRef = dbRef.child("games").child(gameId)
        
        gameRef.child("currentRound").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self,
                  let currentRound = snapshot.value as? Int else { return }
            self.fetchRoundAnswers(gameRef: gameRef, currentRound: currentRound) { roundAnswers in
                if self.bothPlayersHaveAnswered(roundAnswers: roundAnswers) {
                    self.updateScoresAndProceed(gameRef: gameRef, currentRound: currentRound, roundAnswers: roundAnswers)
                } else {
                    self.proceedWithNextPlayerTurn(gameRef: gameRef, currentRound: currentRound)
                }
            }
        }
    }
    
    private func fetchRoundAnswers(gameRef: DatabaseReference, currentRound: Int, completion: @escaping ([String: (answer: String, time: Int)]) -> Void) {
        gameRef.child("roundResults").observeSingleEvent(of: .value) { snapshot in
            var roundAnswers: [String: (answer: String, time: Int)] = [:]
            for child in snapshot.children {
                if let roundSnapshot = child as? DataSnapshot,
                   let roundData = roundSnapshot.value as? [String: Any],
                   let playerId = roundData["player"] as? String,
                   let answer = roundData["answer"] as? String,
                   let round = roundData["round"] as? Int,
                   let time = roundData["time"] as? Int,
                   round == currentRound {
                    roundAnswers[playerId] = (answer, time)
                }
            }
            completion(roundAnswers)
        }
    }
    
    private func bothPlayersHaveAnswered(roundAnswers: [String: (answer: String, time: Int)]) -> Bool {
        return roundAnswers[self.playerHost] != nil && roundAnswers[self.playerInvited] != nil
    }
    
    private func updateScoresAndProceed(gameRef: DatabaseReference, currentRound: Int, roundAnswers: [String: (answer: String, time: Int)]) {
        gameRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self,
                  var gameData = snapshot.value as? [String: Any] else { return }
            let currentTurn = gameData["turn"] as? String ?? ""
            self.updateScores(gameData: &gameData, playerHostData: roundAnswers[self.playerHost]!, playerInvitedData: roundAnswers[self.playerInvited]!)
            let nextTurn = currentTurn == self.playerHost ? self.playerHost : self.playerInvited
            gameData["turn"] = nextTurn
            gameData["currentRound"] = currentRound + 1
            let nextRoundQuestion = self.generateRandomQuestion()
            var rounds = gameData["rounds"] as? [[String: Any]] ?? []
            rounds.append(nextRoundQuestion)
            gameData["rounds"] = rounds
            gameRef.setValue(gameData)
            self.listenForUpdates()
        }
    }
    
    private func proceedWithNextPlayerTurn(gameRef: DatabaseReference, currentRound: Int) {
        gameRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self,
                  var gameData = snapshot.value as? [String: Any] else { return }
            let currentTurn = gameData["turn"] as? String ?? ""
            let nextTurn = currentTurn == self.playerHost ? self.playerInvited : self.playerHost
            gameData["turn"] = nextTurn
            gameRef.setValue(gameData)
            self.listenForUpdates()
        }
    }
    
    private func updateScores(gameData: inout [String: Any], playerHostData: (answer: String, time: Int), playerInvitedData: (answer: String, time: Int)) {
        var scores = gameData["scores"] as? [String: Int] ?? [:]
        let isPlayerHostCorrect = playerHostData.answer == self.correctAnswer
        let isPlayerInvitedCorrect = playerInvitedData.answer == self.correctAnswer
        if isPlayerHostCorrect && isPlayerInvitedCorrect {
            if playerHostData.time < playerInvitedData.time {
                scores[self.playerHost, default: 0] += 1
            } else {
                scores[self.playerInvited, default: 0] += 1
            }
        } else if isPlayerHostCorrect {
            scores[self.playerHost, default: 0] += 1
        } else if isPlayerInvitedCorrect {
            scores[self.playerInvited, default: 0] += 1
        }
        if scores[self.playerHost, default: 0] >= 3 {
            gameData["winner"] = self.playerHost
        } else if scores[self.playerInvited, default: 0] >= 3 {
            gameData["winner"] = self.playerInvited
        }
        gameData["scores"] = scores
    }
    
    // MARK: - Question Generation
    private func generateRandomQuestion() -> [String: Any] {
        let num1 = Int.random(in: 0...20)
        let num2 = Int.random(in: 0...20)
        let operation = Int.random(in: 1...3)
        let (question, correctAnswer) = createMathQuestion(num1: num1, num2: num2, operation: operation)
        let options = generateAnswerOptions(correctAnswer: correctAnswer)
        return ["question": question, "options": options, "correctAnswer": "\(correctAnswer)"]
    }
    
    private func createMathQuestion(num1: Int, num2: Int, operation: Int) -> (String, Int) {
        switch operation {
        case 1:
            return ("What is \(num1) + \(num2)?", num1 + num2)
        case 2:
            return ("What is \(num1) - \(num2)?", num1 - num2)
        default:
            return ("What is \(num1) × \(num2)?", num1 * num2)
        }
    }
    
    private func generateAnswerOptions(correctAnswer: Int) -> [String] {
        var options: [String] = ["\(correctAnswer)"]
        var wrongAnswers: Set<Int> = []
        let errorMargin = max(1, abs(correctAnswer) / 10)
        while wrongAnswers.count < 2 {
            let deviation = Int.random(in: -errorMargin...errorMargin)
            let wrongAnswer = correctAnswer + deviation
            if wrongAnswer != correctAnswer {
                wrongAnswers.insert(wrongAnswer)
            }
        }
        options.append(contentsOf: wrongAnswers.map { "\($0)" })
        options.shuffle()
        return options
    }
    
    // MARK: - Player Info
    func getOpponent() -> String {
        return localPlayer == playerHost ? playerInvited : playerHost
    }
    
    func getPlayerScore(_ player: String) -> Int {
        return scores[player] ?? 0
    }
    
    func getWinner() -> String {
        if gameStatus == .over {
            if getPlayerScore(playerHost) == 3 {
                return playerHost
            } else if getPlayerScore(playerInvited) == 3 {
                return playerInvited
            }
        }
        return playerHost
    }
}
