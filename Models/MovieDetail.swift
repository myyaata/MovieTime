import Foundation

struct MovieDetail: Decodable {
    let title: String
    let year: String
    let plot: String        // описание
    let director: String    // режиссёры (строкой через запятую)
    let actors: String      // актёры (строкой через запятую)
    let imdbRating: String  // рейтинг, например "7.5" или "N/A"
    let genre: String = ""
    let poster: String
    let response: String
    let error: String?

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case plot = "Plot"
        case director = "Director"
        case actors = "Actors"
        case imdbRating
        case genre = "Genre"
        case poster = "Poster"
        case response = "Response"
        case error = "Error"
    }

    var posterURL: URL? { poster == "N/A" ? nil : URL(string: poster) }

    var genreList: [String] {
        genre.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
}
