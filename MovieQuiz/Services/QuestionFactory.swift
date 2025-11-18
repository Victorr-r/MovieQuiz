import Foundation


class QuestionFactory: QuestionFactoryProtocol {
	weak var delegate: QuestionFactoryDelegate?
	var questions: [QuizQuestion] = [
		QuizQuestion(
			image: "The Godfather",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: true),
		QuizQuestion(
			image: "The Dark Knight",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: true),
		QuizQuestion(
			image: "Kill Bill",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: true),
		QuizQuestion(
			image: "The Avengers",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: true),
		QuizQuestion(
			image: "Deadpool",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: true),
		QuizQuestion(
			image: "The Green Knight",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: true),
		QuizQuestion(
			image: "Old",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: false),
		QuizQuestion(
			image: "The Ice Age Adventures of Buck Wild",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: false),
		QuizQuestion(
			image: "Tesla",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: false),
		QuizQuestion(
			image: "Vivarium",
			text: "Рейтинг этого фильма больше чем 6?",
			correctAnswer: false) ]
	
	private var currentQuestionIndex = 0
	
	func requestNextQuestion() {
		if currentQuestionIndex >= questions.count {
			delegate?.didReceiveNextQuestion(question: nil)
			return
		}
		let question = questions[currentQuestionIndex]
		
		currentQuestionIndex += 1
		
		
		DispatchQueue.main.async { [weak self] in
			self?.delegate?.didReceiveNextQuestion(question: question)
		}
	}
	func resetQuestionIndex() {
		currentQuestionIndex = 0
	}
}

