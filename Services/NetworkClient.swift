import Foundation

struct NetworkClient {
    
    private enum NetworkError: Error {
        case codeError(Int)
        case noData
    }

    func fetch(url: URL,
               handler: @escaping (Result<Data, Error>) -> Void) {
 
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                handler(.failure(error))
                return
            }
 
            if let response = response as? HTTPURLResponse,
               !(200..<300).contains(response.statusCode) {
                handler(.failure(NetworkError.codeError(response.statusCode)))
                return
            }
 
            guard let data else {
                handler(.failure(NetworkError.noData)) // раньше тут был молчаливый return
                return
            }
 
            handler(.success(data))
        }
        task.resume()
    }
}
