import Foundation
import UIKit

struct AlertModel {
	var title: String
	var message: String
	var buttonText: String
	var completion: () -> Void
}

final class AlertPresenter {
	func show(in vc: UIViewController, model: AlertModel) {
		let alert = UIAlertController(
			title: model.title,
			message: model.message,
			preferredStyle: .alert)
		
		let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
			model.completion()
		}
		alert.addAction(action)
		
		vc.present(alert, animated: true)
		
	}
}
