import Foundation

struct OMDbSearchResponse: Decodable {
    let search: [Movie]
    let totalResults: String?
    let response: String        // "True" / "False"
    let error: String?          // текст ошибки, если Response == "False"
 
    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
        case error = "Error"
    }
}
 
struct Movie: Decodable {
    let title: String
    let year: String
    let imdbID: String
    let poster: String          // важно: может быть "N/A", поэтому String, а не URL
 
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case poster = "Poster"
    }
 
    // Безопасное превращение в URL: "N/A" -> nil, иначе ячейка падала бы при декодировании
    var posterURL: URL? {
        poster == "N/A" ? nil : URL(string: poster)
    }
}
