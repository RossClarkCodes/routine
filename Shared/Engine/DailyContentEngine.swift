import Foundation

struct Quote: Codable, Equatable {
    let text: String
    let author: String?
}

struct DailyContent: Equatable {
    let affirmation: String
    let quote: Quote
}

final class DailyContentEngine {
    private lazy var quotes: [Quote] = loadQuotes()
    private lazy var affirmations: [String] = loadAffirmations()

    func content(for dayKey: String) -> DailyContent {
        let quoteIndex = index(for: dayKey, count: max(quotes.count, 1))
        let affirmationIndex = index(for: "affirmation-\(dayKey)", count: max(affirmations.count, 1))
        let quote = quotes.indices.contains(quoteIndex) ? quotes[quoteIndex] : Quote(text: "Make today count.", author: nil)
        let affirmation = affirmations.indices.contains(affirmationIndex) ? affirmations[affirmationIndex] : "I show up with calm focus."
        return DailyContent(affirmation: affirmation, quote: quote)
    }

    private func index(for key: String, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return stableHash(key) % count
    }

    private func stableHash(_ value: String) -> Int {
        value.unicodeScalars.reduce(0) { ($0 &* 31) &+ Int($1.value) }
    }

    private func loadQuotes() -> [Quote] {
        load([Quote].self, resource: "quotes")
    }

    private func loadAffirmations() -> [String] {
        load([String].self, resource: "affirmations")
    }

    private func load<T: Decodable>(_ type: T.Type, resource: String) -> T {
        let bundle = Bundle(for: RoutineBundleLocator.self)
        guard let url = bundle.url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(type, from: data) else {
            return fallback(for: type)
        }
        return decoded
    }

    private func fallback<T: Decodable>(for type: T.Type) -> T {
        if type == [Quote].self {
            return [Quote(text: "Small steps, repeated daily, make the difference.", author: "Routine") ] as! T
        }
        if type == [String].self {
            return ["I act with intention and calm."] as! T
        }
        fatalError("Unsupported fallback type")
    }
}
