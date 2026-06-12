import UIKit

final class ShowBillController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var movies: [Movie] = []
    private let moviesLoader = MoviesLoader()
    
    private let query = "marvel"
    private var currentPage = 1
    private var isLoading = false
    private var canLoadMore = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadNextPage()
    }
    
    private func loadNextPage() {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
 
        moviesLoader.loadMovies(query: query, page: currentPage) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let newMovies):
                    guard !newMovies.isEmpty else {
                        self.canLoadMore = false
                        return
                    }
                    self.movies.append(contentsOf: newMovies)
                    self.currentPage += 1
                    self.tableView.reloadData()
                case .failure(let error):
                    self.canLoadMore = false
                    print("Ошибка загрузки: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func configCell(for cell: ShowBillCell, with indexPath: IndexPath) {
        cell.configure(with: movies[indexPath.row])
    }
    
}

extension ShowBillController: UITableViewDelegate {
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        600
//    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= movies.count - 3 {
            loadNextPage()
        }
    }
}

extension ShowBillController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ShowBillCell.reuseIdentifier, for: indexPath)
        
        guard let showBillCell = cell as? ShowBillCell else {
            return UITableViewCell()
        }
        configCell(for: showBillCell, with: indexPath)
        return showBillCell
    }
}
