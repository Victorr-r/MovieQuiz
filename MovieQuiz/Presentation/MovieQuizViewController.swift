import UIKit


// MARK: - Lifecycle



final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate  {
	
	// MARK: - IBOutlets
	
	@IBOutlet private weak var yesButton: UIButton!
	@IBOutlet private weak var noButton: UIButton!
	@IBOutlet private weak var counterLabel: UILabel!
	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var textLabel: UILabel!
	
	
	// MARK: - Private Properties
	
	private let presenter = MovieQuizPresenter()
	private var correctAnswers = 0
	private var questionFactory: QuestionFactoryProtocol?
	private var alertPresenter = AlertPresenter()
	private var statisticService: StatisticServiceProtocol?
	
	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		configureUI()
		configureServices()
		loadData()
		presenter.viewController = self
	}
	
	//MARK: - ACTIONS
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		setButtonsEnabled(false)
		presenter.yesButtonClicked()
	 }
	
	@IBAction private func noButtonClicked(_ sender: UIButton) {
		setButtonsEnabled(false)
		presenter.noButtonClicked()
}
			
	
	// MARK: - QuestionFactoryDelegate
	func didLoadDataFromServer() {
		hideLoadingIndicator()
		questionFactory?.requestNextQuestion()
	}
	
	func didFailToLoadData(with error: Error) {
		showNetworkError(message: error.localizedDescription)
	}
	
	func didReceiveNextQuestion(question: QuizQuestion?) {
		guard let question = question else {
			return
		}
		presenter.currentQuestion = question
		let viewModel = presenter.convert(model: question)
		DispatchQueue.main.async { [weak self] in
			self?.show(quiz: viewModel)
			self?.setButtonsEnabled(true)
		}
	}
	
	//MARK: - Private Methods
	
	private func configureUI (){
		imageView.layer.cornerRadius = 20
	}
	private func configureServices(){
		statisticService = StatisticService()
		questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
	}
	private func loadData(){
		showLoadingIndicator()
		questionFactory?.loadData()
	}
	
	private func setButtonsEnabled(_ isEnabled: Bool) {
		yesButton?.isEnabled = isEnabled
		noButton?.isEnabled = isEnabled
	}
	private func showLoadingIndicator() {
		activityIndicator.isHidden = false
		activityIndicator.startAnimating()
	}
	private func hideLoadingIndicator() {
		activityIndicator.isHidden = true
		activityIndicator.stopAnimating()
	}
	private func showNetworkError(message: String) {
		hideLoadingIndicator()
		
		let model = AlertModel(title: "Ошибка",
							   message: message,
							   buttonText: "Попробовать еще раз") { [weak self] in
			guard let self = self else { return }
			
			self.correctAnswers = 0
			
			self.presenter.resetQuestionIndex()
			
			self.questionFactory?.requestNextQuestion()
		}
		
		alertPresenter.show(in: self, model: model)
	}
	func showAnswerResult(isCorrect: Bool) {
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
			
			if self.presenter.isLastQuestion() {
				self.showFinalResults()
			} else {
				self.showNextQuestionOrResults()
			}
		}
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
		presenter.switchToNextQuestion()
		self.questionFactory?.requestNextQuestion()
	}

	private func showFinalResults() {
		
		statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
		
		guard let statisticService = statisticService else { return }
		let bestGame = statisticService.bestGame
		let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
		let dateString = dateFormatter.string(from: bestGame.date)
		
		let message = """
  Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
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
				self.presenter.resetQuestionIndex()
				self.questionFactory?.requestNextQuestion()
			}
		)
		
		
		alertPresenter.show(in: self, model: alertModel)
	}
}


