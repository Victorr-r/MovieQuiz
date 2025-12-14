

import XCTest

final class MovieQuizUITests: XCTestCase {
	var app: XCUIApplication!
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		app = XCUIApplication()
		app.launch()
		
		continueAfterFailure = false
	}
	
	override func tearDownWithError() throws {
		try super.tearDownWithError()
		
		app.terminate()
		app = nil
	}
	func testYesButton() {
		sleep(15)
		
		let firstPoster = app.images["Poster"]
		let firstPosterData = firstPoster.screenshot().pngRepresentation
		
		app.buttons["Yes"].tap()
		sleep(15)
		
		let secondPoster = app.images["Poster"]
		let secondPosterData = secondPoster.screenshot().pngRepresentation
		let indexLabel = app.staticTexts["Index"]
		
		XCTAssertNotEqual(firstPosterData, secondPosterData)
		XCTAssertEqual(indexLabel.label, "2/10")
		
	}
	func testNoButton() {
		sleep(5)
		
		let firstPoster = app.images["Poster"]
		let firstPosterData = firstPoster.screenshot().pngRepresentation
		
		app.buttons["No"].tap()
		sleep(15)
		
		let secondPoster = app.images["Poster"]
		let secondPosterData = secondPoster.screenshot().pngRepresentation
		let indexLabel = app.staticTexts["Index"]
		
		XCTAssertNotEqual(firstPosterData, secondPosterData)
		XCTAssertEqual(indexLabel.label, "2/10")
	}
	func testGameFinish() {
		sleep(2)
		for _ in 1...10 {
			app.buttons["No"].tap()
			sleep(2)
		}
		
		let alert = app.alerts["Этот раунд окончен!"]
		
		XCTAssertTrue(alert.waitForExistence(timeout: 10.0))
		XCTAssertTrue(alert.label == "Этот раунд окончен!")
		XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
	}
	
	func testAlertDismiss() {
		sleep(10)
		for _ in 1...10 {
			app.buttons["No"].tap()
			sleep(2)
		}
		
		let alert = app.alerts["Этот раунд окончен!"]
		XCTAssertTrue(alert.waitForExistence(timeout: 5.0))
		
		let playAgainButton = alert.buttons["Сыграть ещё раз"]
		XCTAssertTrue(playAgainButton.waitForExistence(timeout: 2.0))
		
		playAgainButton.tap()
		
		sleep(10)
		
		let indexLabel = app.staticTexts["Index"]
		
		XCTAssertFalse(alert.exists)
		XCTAssertTrue(indexLabel.label == "1/10")
	}
}
