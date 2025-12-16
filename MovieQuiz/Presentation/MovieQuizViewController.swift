import UIKit

// MARK: - Lifecycle

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, MovieQuizViewProtocol {
	
	// MARK: - IBOutlets
	
	@IBOutlet private weak var yesButton: UIButton!
	@IBOutlet private weak var noButton: UIButton!
	@IBOutlet private weak var counterLabel: UILabel!
	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var textLabel: UILabel!
	
	
	// MARK: - Private Properties
	
	lazy var presenter = MovieQuizPresenter(viewController: self)
	private var alertPresenter = AlertPresenter()
	
	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		configureUI()
		presenter.loadData()
		presenter.viewController = self
	}
	
	//MARK: - ACTIONS
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		setButtonsEnabled(false)
		presenter.buttonClicked(isYes: true)
	}
	
	@IBAction private func noButtonClicked(_ sender: UIButton) {
		setButtonsEnabled(false)
		presenter.buttonClicked(isYes: false)
	}
	
	
	// MARK: - QuestionFactoryDelegate
	func didLoadDataFromServer() {
		presenter.didLoadDataFromServer()
	}
	
	func didReceiveNextQuestion(question: QuizQuestion?) {
		presenter.didReceiveNextQuestion(question: question)
	}
	
	func didFailToLoadData(with error: Error) {
		presenter.didFailToLoadData(with: error)
	}
	
	// MARK: - MovieQuizViewProtocol Implementation (Реализация методов UI)
	func show(quiz step: QuizStepViewModel) {
		imageView.image = step.image
		textLabel.text = step.question
		counterLabel.text = step.questionNumber
	}
	
	func setButtonsEnabled(_ isEnabled: Bool) {
		yesButton?.isEnabled = isEnabled
		noButton?.isEnabled = isEnabled
	}
	
	func showLoadingIndicator() {
		activityIndicator.isHidden = false
		activityIndicator.startAnimating()
	}
	
	func hideLoadingIndicator() {
		activityIndicator.isHidden = true
		activityIndicator.stopAnimating()
	}
	
	func highlightImageBorder(isCorrect: Bool) {
		imageView.layer.masksToBounds = true
		imageView.layer.borderWidth = 8
		imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
		imageView.layer.cornerRadius = 20
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
			guard let self = self else { return }
			self.imageView.layer.borderColor = UIColor.clear.cgColor
		}
	}
	
	func showFinalResults(model: AlertModel) {
		alertPresenter.show(in: self, model: model)
	}
	
	//MARK: - Private Methods
	private func configureUI (){
		imageView.layer.cornerRadius = 20
	}
}
