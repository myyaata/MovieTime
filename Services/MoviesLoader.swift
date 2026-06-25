import Foundation

protocol MoviesLoading {
    func loadMovies(query: String, page: Int, handler: @escaping (Result<[Movie], Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {

    private let networkClient = NetworkClient()
    
    private let apiKey = Secrets.omdbAPIKey
    
    private func searchURL(query: String, page: Int) -> URL {
        var components = URLComponents(string: "https://www.omdbapi.com/")!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "s", value: query),     // строка поиска (обязательна у OMDb)
            URLQueryItem(name: "type", value: "movie"),
            URLQueryItem(name: "page", value: String(page))
        ]
        guard let url = components.url else {
            preconditionFailure("Не удалось собрать URL запроса OMDb")
        }
        return url
    }
    
    func loadMovies(query: String, page: Int = 1, handler: @escaping (Result<[Movie], Error>) -> Void) {
    
           let url = searchURL(query: query, page: page)
    
           networkClient.fetch(url: url) { result in
               switch result {
               case .success(let data):
                   do {
                       let response = try JSONDecoder().decode(OMDbSearchResponse.self, from: data)
                       if response.response == "True" {
                           handler(.success(response.search))
                       } else {
                           // OMDb отдаёт 200, но кладёт ошибку в тело: "Movie not found!",
                           // "Request limit reached!", "Invalid API key!" и т.п.
                           let message = response.error ?? "Неизвестная ошибка OMDb"
                           handler(.failure(NSError(
                               domain: "OMDb",
                               code: -1,
                               userInfo: [NSLocalizedDescriptionKey: message]
                           )))
                       }
                   } catch {
                       handler(.failure(error))
                   }
               case .failure(let error):
                   handler(.failure(error))
               }
           }
    }
    
    func loadDetail(imdbID: String, handler: @escaping (Result<MovieDetail, Error>) -> Void) {
        var components = URLComponents(string: "https://www.omdbapi.com/")!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "i", value: imdbID),
            URLQueryItem(name: "plot", value: "short")
        ]
        guard let url = components.url else { return }
        networkClient.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let detail = try JSONDecoder().decode(MovieDetail.self, from: data)
                    handler(.success(detail))
                } catch { handler(.failure(error)) }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
        
    
   }
    
