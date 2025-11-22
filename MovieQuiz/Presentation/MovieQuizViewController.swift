import UIKit



final class MovieQuizViewController: UIViewController , QuestionFactoryDelegate {
	// MARK: - Lifecycle
	
	@IBOutlet private weak var yesButton: UIButton!
	@IBOutlet private weak var noButton: UIButton!
  
final class MovieQuizViewController: UIViewController {
	// MARK: - Lifecycle
	
	private var questions: [QuizQuestion] = [
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
	
	@IBOutlet private weak var counterLabel: UILabel!
	
	@IBOutlet private weak var imageView: UIImageView!
	
	@IBOutlet private weak var textLabel: UILabel!
	
	private var currentQuestionIndex = 0
	private var correctAnswers = 0
	private let questionsAmount: Int = 10
	private var questionFactory: QuestionFactoryProtocol?
	private var currentQuestion: QuizQuestion?
	private var alertPresenter = AlertPresenter()
	private var statisticService: StatisticServiceProtocol?
	
	//MARK: - ACTIONS
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		setButtonsEnabled(false)
		guard let currentQuestion = currentQuestion else {
			return
		}

	
	//MARK: - ACTIONS
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		
		let currentQuestion = questions[currentQuestionIndex]

		
		let givenAnswer = true
		
		showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
	}
	@IBAction private func noButtonClicked(_ sender: UIButton) {

		setButtonsEnabled(false)
		guard let currentQuestion = currentQuestion else {
			return
		}

		
		let currentQuestion = questions[currentQuestionIndex]

		
		let givenAnswer = false
		
		showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
	}
	
	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		statisticService = StatisticService()
		imageView.layer.cornerRadius = 20
		let questionFactory = QuestionFactory()
		questionFactory.delegate = self
		self.questionFactory = questionFactory
		
		questionFactory.requestNextQuestion()
	}
	
	// MARK: - QuestionFactoryDelegate
	func didReceiveNextQuestion(question: QuizQuestion?) {
		guard let question = question else {
			return
		}
		
		currentQuestion = question
		let viewModel = convert(model: question)
		
		DispatchQueue.main.async { [weak self] in
			self?.show(quiz: viewModel)
			self?.setButtonsEnabled(true)
		}
	}
	
	//MARK: - Private Methods
	
	private func setButtonsEnabled(_ isEnabled: Bool) {
		yesButton?.isEnabled = isEnabled
		noButton?.isEnabled = isEnabled
	}
	

		imageView.layer.cornerRadius = 20
		let currentQuestion = questions[currentQuestionIndex]
		show(quiz: convert(model: currentQuestion))
	}
	
	//MARK: - Structs
	private struct QuizStepViewModel {
		let image: UIImage
		let question: String
		let questionNumber: String
	}
	
	private struct QuizQuestion {
		let image: String
		let text: String
		let correctAnswer: Bool
	}
	
	private struct QuizResultsViewModel {
		let title: String
		let text: String
		let buttonText: String
	}
	
	//MARK: - Private Methods

	private func convert(model: QuizQuestion) -> QuizStepViewModel {
		let questionStep = QuizStepViewModel(
			image: UIImage(named: model.image) ?? UIImage(),
			question: model.text,

			questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")

			questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")

		return questionStep
	}
	
	private func show(quiz step: QuizStepViewModel) {
		imageView.image = step.image
		textLabel.text = step.question
		counterLabel.text = step.questionNumber
	}
  
	private func showNextQuestionOrResults() {
		setButtonsEnabled(true)
		imageView.layer.borderWidth = 0
		imageView.layer.borderColor = UIColor.clear.cgColor
		if currentQuestionIndex + 1 < questionsAmount {
			currentQuestionIndex += 1
			self.questionFactory?.requestNextQuestion()
		}
	}
	
	func showAnswerResult(isCorrect: Bool) {
	private func showAnswerResult(isCorrect: Bool) {
    if isCorrect {
			correctAnswers += 1
		}
		imageView.layer.masksToBounds = true
		imageView.layer.borderWidth = 8
		imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
		imageView.layer.cornerRadius = 20
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
			guard let self = self else { return }
			self.imageView.layer.borderColor = UIColor.clear.cgColor
			if self.currentQuestionIndex + 1 >= self.questionsAmount {
				self.showFinalResults()
			} else {
				self.showNextQuestionOrResults()
			}
		}
	}
	
	private func showFinalResults() {
		
		statisticService?.store(correct: correctAnswers, total: questionsAmount)
		
		guard let statisticService = statisticService else { return }
		let bestGame = statisticService.bestGame
		let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
		let dateString = dateFormatter.string(from: bestGame.date)
		
		let message = """
  Ваш результат: \(correctAnswers)/\(questionsAmount)
  Количество сыгранных игр: \(statisticService.gamesCount)
  Рекорд: \(bestGame.correct)/\(bestGame.total) от \(dateString)
  Средняя точность: \(accuracy)%
  """
		let alertModel = AlertModel(
			title: "Этот раунд окончен!",
			message: message,
			buttonText: "Сыграть ещё раз",
			completion: { [weak self] in
				guard let self = self else { return }
				
				self.correctAnswers = 0
				self.currentQuestionIndex = 0
				
				(self.questionFactory as? QuestionFactory)?.resetQuestionIndex()
				self.questionFactory?.requestNextQuestion()
			}
		)
		
		
		alertPresenter.show(in: self, model: alertModel)
	}
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			self.imageView.layer.borderColor = UIColor.clear.cgColor
			self.showNextQuestionOrResults()
		}
	}
	
	private func show(quiz result: QuizResultsViewModel) {
		let alert = UIAlertController(
			title: result.title,
			message: result.text,
			preferredStyle: .alert)
		
		let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
			self.currentQuestionIndex = 0
			self.correctAnswers = 0
			
			let firstQuestion = self.questions[self.currentQuestionIndex]
			let viewModel = self.convert(model: firstQuestion)
			self.show(quiz: viewModel)
		}
		alert.addAction(action)
		
		self.present(alert, animated: true, completion: nil)
	}
	
	private func showNextQuestionOrResults() {
		imageView.layer.borderWidth = 0
		imageView.layer.borderColor = UIColor.clear.cgColor
		if currentQuestionIndex == questions.count - 1 {
			let text = "Ваш результат: \(correctAnswers)/10"
			let viewModel = QuizResultsViewModel(
				title: "Этот раунд окончен!",
				text: text,
				buttonText: "Сыграть ещё раз")
			show(quiz: viewModel)
		} else {
			currentQuestionIndex += 1
			let nextQuestion = questions[currentQuestionIndex]
			let viewModel = convert(model: nextQuestion)
			
			show(quiz: viewModel)
		}
	}
}
