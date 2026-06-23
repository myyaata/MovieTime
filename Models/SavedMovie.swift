
nonisolated struct SavedMovie: Codable, Hashable {
    let imdbID: String
    let title: String
    let posterURLString: String?
    var rating: Int
}
