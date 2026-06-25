import Foundation

final class AwardsStore {
    
    var lastUnlockedID: Int? {
        unlockedIDs.last
    }

    static let shared = AwardsStore()

    let allAwards: [Award] = [
        Award(id: 0, title: "Первый шаг",    description: "Оцените первый фильм",                  imageName: "award_1", number: "1"),
        Award(id: 1, title: "Киноман",       description: "Оцените 5 фильмов",                     imageName: "award_2", number: "2"),
        Award(id: 2, title: "Знаток жанров", description: "Оцените фильмы из 3 разных жанров",     imageName: "award_3", number: "3"),
        Award(id: 3, title: "Марафонец",     description: "Оцените 10 фильмов",                    imageName: "award_4", number: "4"),
        Award(id: 4, title: "Коллекционер",  description: "Добавьте 10 фильмов в список",          imageName: "award_5", number: "5")
    ]

    private let key = "unlocked_awards"
    private var unlockedIDs: [Int] = []

    private init() {
        load()
        _ = checkAndUnlock()
    }

    func isUnlocked(id: Int) -> Bool {
        unlockedIDs.contains(id)
    }

    @discardableResult
    func checkAndUnlock() -> [Award] {
        let movies = MyMoviesStore.shared.movies
        let ratedCount = movies.filter { $0.rating >= 1 }.count
        let ratedGenreCount = Set(movies.filter { $0.rating >= 1 }.flatMap(\.genres)).count
        let totalCount = movies.count

        let conditions: [(Int, Bool)] = [
            (0, ratedCount >= 1),
            (1, ratedCount >= 5),
            (2, ratedGenreCount >= 3),
            (3, ratedCount >= 10),
            (4, totalCount >= 10)
        ]

        var newlyUnlocked: [Award] = []
        for (id, met) in conditions where met && !isUnlocked(id: id) {
            unlock(id: id)
            if let award = allAwards.first(where: { $0.id == id }) {
                newlyUnlocked.append(award)
            }
        }

        return newlyUnlocked
    }

    private func unlock(id: Int) {
        guard !unlockedIDs.contains(id) else { return }  // не добавляем дважды
        unlockedIDs.append(id)                            // новый — в конец
        save()
    }

    private func save() {
        UserDefaults.standard.set(unlockedIDs, forKey: key)
    }

    private func load() {
        guard let ids = UserDefaults.standard.array(forKey: key) as? [Int] else { return }
        unlockedIDs = ids
    }
}
