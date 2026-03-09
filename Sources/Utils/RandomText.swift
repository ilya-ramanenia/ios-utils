enum RandomText {

    private static let vowels = ["a","e","i","o","u"]
    private static let consonants = [
        "b","c","d","f","g","h","j","k","l","m",
        "n","p","r","s","t","v","z"
    ]

    static func words(_ count: Int) -> String {
        (0..<count)
            .map { _ in word() }
            .joined(separator: " ")
    }

    private static func word() -> String {
        let length = Int.random(in: 3...6)

        return (0..<length)
            .map { $0.isMultiple(of: 2)
                ? consonants.randomElement()!
                : vowels.randomElement()!
            }
            .joined()
    }
}
