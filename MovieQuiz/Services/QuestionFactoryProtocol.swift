
import UIKit

protocol QuestionFactoryProtocol: AnyObject {
	func requestNextQuestion()
	func loadData()
	func resetQuestionIndex()
	}

