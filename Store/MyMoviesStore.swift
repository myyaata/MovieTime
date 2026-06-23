import Foundation

final class MyMoviesStore {
    
    // MARK: - Public Properties

    static let shared = MyMoviesStore()
    
    // MARK: - Private Properties
    
    private let key = "my_movies"
    private(set) var movies: [SavedMovie] = []
    
    // MARK: - Public Methods
    
    func add(_ movie: SavedMovie) {
        guard !contains(movie.imdbID) else { return }
        movies.append(movie)
        save()
    }
    
    func remove(at index: Int) {
        guard movies.indices.contains(index) else { return }
        movies.remove(at: index)
        save()
    }
    
    func contains(_ imdbID: String) -> Bool {
        movies.contains {
            $0.imdbID == imdbID
        }
    }
    
    func setRating(_ rating: Int, forID imdbID: String) {
        guard let i = movies.firstIndex(where: { $0.imdbID == imdbID }) else { return }
        movies[i].rating = rating
        save()
    }
    
    // MARK: - Private Methods
    
    private init() {
        load()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(movies) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode([SavedMovie].self, from: data) else { return }
        movies = saved
    }
}
