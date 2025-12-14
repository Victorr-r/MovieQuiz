import UIKit

// MARK: - View Protocol

protocol MovieQuizViewProtocol: AnyObject {
	func show(quiz step: QuizStepViewModel)
	func showLoadingIndicator()
	func hideLoadingIndicator()
	func setButtonsEnabled(_ isEnabled: Bool)
	func highlightImageBorder(isCorrect: Bool)
	func showFinalResults(model: AlertModel)
}

// MARK: - Lifecycle
final class MovieQuizPresenter: QuestionFactoryDelegate {
	
	// MARK: - Properties
	private var correctAnswers = 0
	private let questionsAmount: Int = 10
	private var currentQuestionIndex: Int = 0
	private var currentQuestion: QuizQuestion?
	
	weak var viewController: MovieQuizViewProtocol?
	var questionFactory: QuestionFactoryProtocol?
	var statisticService: StatisticServiceProtocol?
	
	// MARK: - Configuration & Data Loading
	func configureServices() {
		statisticService = StatisticService()
		questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
	}
	
	func loadData() {
		viewController?.showLoadingIndicator()
		questionFactory?.loadData()
	}
	
	// MARK: - QuestionFactoryDelegate Implementation (Логика получения данных)
	
	func didLoadDataFromServer() {
		viewController?.hideLoadingIndicator()
	}
	
	func didFailToLoadData(with error: Error) {
		let alertModel = AlertModel(
			title: "Ошибка",
			message: "Не удалось загрузить данные: \(error.localizedDescription)",
			buttonText: "Попробовать снова",
			completion: { [weak self] in
				self?.loadData()
			}
		)
		viewController?.showFinalResults(model: alertModel)
		viewController?.hideLoadingIndicator()
	}
	
	func didReceiveNextQuestion(question: QuizQuestion?) {
		guard let question = question else { return }
		self.currentQuestion = question
		let viewModel = convert(model: question)
		DispatchQueue.main.async { [weak self] in
			self?.viewController?.show(quiz: viewModel)
			self?.viewController?.setButtonsEnabled(true)
		}
	}
	
	// MARK: - Action Handling (Логика обработки кнопок)
	
	func noButtonClicked() {
		didAnswer(isYes: false)
	}
	
	func yesButtonClicked() {
		didAnswer(isYes: true)
	}
	
	private func didAnswer(isYes: Bool) {
		viewController?.setButtonsEnabled(false)
		guard let currentQuestion = currentQuestion else { return }
		showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
	}
	
	// MARK: - Helper Methods & Game Logic
	
	private func showAnswerResult(isCorrect: Bool) {
		if isCorrect {
			correctAnswers += 1
		}
		viewController?.highlightImageBorder(isCorrect: isCorrect)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
			guard let self = self else { return }
			
			if self.isLastQuestion {
				self.showFinalResults()
			} else {
				self.switchToNextQuestion()
				self.questionFactory?.requestNextQuestion()
			}
		}
	}
	
	// Методы управления состоянием игры
	
	private var isLastQuestion: Bool {
		currentQuestionIndex == questionsAmount - 1
	}
	
	func resetQuestionIndex() {
		currentQuestionIndex = 0
	}
	
	func switchToNextQuestion() {
		currentQuestionIndex += 1
	}
	
	func convert(model: QuizQuestion) -> QuizStepViewModel {
		return QuizStepViewModel(
			image: UIImage(data: model.image) ?? UIImage(),
			question: model.text,
			questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
		)
	}
	
	// MARK: - Final Results Logic
	
	private func showFinalResults() {
		statisticService?.store(correct: correctAnswers, total: questionsAmount)
		let alertModel = AlertModel(
			title: "Этот раунд окончен!",
			message: makeResultsMessage(),
			buttonText: "Сыграть ещё раз",
			completion: { [weak self] in
				guard let self = self else { return }
				self.correctAnswers = 0
				self.resetQuestionIndex()
				self.questionFactory?.requestNextQuestion()
			}
		)
		
		viewController?.showFinalResults(model: alertModel)
	}
	
	private func makeResultsMessage() -> String {
		guard let statisticService = statisticService else {
			return "Не удалось получить статистику."
		}
		let bestGame = statisticService.bestGame
		let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
		let dateString = dateFormatter.string(from: bestGame.date)
		
		return """
 Ваш результат: \(correctAnswers)/\(questionsAmount)
 Количество сыгранных игр: \(statisticService.gamesCount)
 Рекорд: \(bestGame.correct)/\(bestGame.total) от \(dateString)
 Средняя точность: \(accuracy)%
 """
	}
}
