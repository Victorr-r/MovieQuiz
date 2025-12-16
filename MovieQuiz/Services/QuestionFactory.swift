import Foundation


final class QuestionFactory: QuestionFactoryProtocol {
	private let moviesLoader: MoviesLoading
	private weak var delegate: QuestionFactoryDelegate?
	
	init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?){
		self.moviesLoader = moviesLoader
		self.delegate = delegate
	}
	func loadData() {
		moviesLoader.loadMovies { [weak self] result in
			DispatchQueue.main.async {
				guard let self = self else { return }
				switch result {
				case .success(let mostPopularMovies):
					self.movies = mostPopularMovies.items
					self.delegate?.didLoadDataFromServer() 
					self.requestNextQuestion()
				case .failure(let error):
					self.delegate?.didFailToLoadData(with: error)
				}
			}
		}
	}
	
	private var movies: [MostPopularMovie] = []
	
	func requestNextQuestion() {
		guard !movies.isEmpty else { return }
		
		let index = (0..<self.movies.count).randomElement() ?? 0
		let movie = self.movies[index]
		let task = URLSession.shared.dataTask(with: movie.resizedImageURL) { [weak self] (data, response, error) in
			guard let self = self else { return }
			
			if let error = error {
				print("Failed to load image: \(error.localizedDescription)")
				return
			}
			
			guard let imageData = data else {
				print("Image data is missing")
				return
			}
			
			let rating = Float(movie.rating) ?? 0
			let text = "Рейтинг этого фильма больше чем 7?"
			let correctAnswer = rating > 7
			
			let question = QuizQuestion(image: imageData,
										text: text,
										correctAnswer: correctAnswer)
			
			DispatchQueue.main.async {
				self.delegate?.didReceiveNextQuestion(question: question)
			}
		}
		task.resume()
	}
	func resetQuestionIndex() {
	}
}
