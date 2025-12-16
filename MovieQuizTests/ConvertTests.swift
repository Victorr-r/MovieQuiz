import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewProtocol {
	func show(quiz step: QuizStepViewModel) {}
	func setButtonsEnabled(_ isEnable: Bool){}
	func highlightImageBorder(isCorrect: Bool) {}
	func showLoadingIndicator() {}
	func hideLoadingIndicator() {}
	func showFinalResults(model: AlertModel) {}
}

final class MovieQuizPresenterTests: XCTestCase {
	func testPresenterConvertModel() throws {
		let viewControllerMock = MovieQuizViewControllerMock()
		let sut = MovieQuizPresenter(viewController: viewControllerMock)
		
		let emptyData = Data()
		let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
		let viewModel = sut.convert(model: question)
		
		 XCTAssertNotNil(viewModel.image)
		XCTAssertEqual(viewModel.question, "Question Text")
		XCTAssertEqual(viewModel.questionNumber, "1/10")
	}
}
