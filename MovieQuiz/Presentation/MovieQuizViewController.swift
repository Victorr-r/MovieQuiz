import UIKit


// MARK: - Lifecycle



final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate  {
	
	// MARK: - IBOutlets
	
	@IBOutlet private weak var yesButton: UIButton!
	@IBOutlet private weak var noButton: UIButton!
	@IBOutlet private weak var counterLabel: UILabel!
	
	@IBOutlet private weak var imageView: UIImageView!
	
	@IBOutlet private weak var textLabel: UILabel!
	
	// MARK: - Private Properties
	
	private var currentQuestionIndex = 0
	private var correctAnswers = 0
	private let questionsAmount: Int = 10
	private var questionFactory: QuestionFactoryProtocol?
	private var currentQuestion: QuizQuestion?
	private var alertPresenter = AlertPresenter()
	private var statisticService: StatisticServiceProtocol?
	
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
	
	//MARK: - ACTIONS
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		setButtonsEnabled(false)
		guard let currentQuestion = currentQuestion else {
			return
		}
		showAnswerResult(isCorrect: true == currentQuestion.correctAnswer)
	}
	@IBAction private func noButtonClicked(_ sender: UIButton) {
		
		setButtonsEnabled(false)
		guard let currentQuestion = currentQuestion else {
			return
		}
		showAnswerResult(isCorrect: false == currentQuestion.correctAnswer)
	}
	
	// MARK: - QuestionFactoryDelegate
	func didFailToLoadData(with error: Error) {
		let alertModel = AlertModel(
			title: "Ошибка",
			message: "Не удалось загрузить данные: \(error.localizedDescription)",
			buttonText: "Попробовать снова",
			completion: { [weak self] in
				self?.questionFactory?.requestNextQuestion()
			}
		)
		alertPresenter.show(in: self, model: alertModel)
	}
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
	private func showAnswerResult(isCorrect: Bool) {
		if isCorrect {
			correctAnswers += 1
		}
		
		imageView.layer.masksToBounds = true
		imageView.layer.borderWidth = 8
		// Используйте ваши цвета, если они определены как UIColor.ypGreen/ypRed
		imageView.layer.borderColor = isCorrect ? UIColor.green.cgColor : UIColor.red.cgColor
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
	
	
	private func convert(model: QuizQuestion) -> QuizStepViewModel {
		let questionStep = QuizStepViewModel(
			image: UIImage(named: model.image) ?? UIImage(),
			question: model.text,
			
			questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
		
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
}


