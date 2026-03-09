actor PrefetchManager<ID: Hashable & Sendable> {

    typealias Fetch = @Sendable ([ID]) async -> Void

    private let batchSize: Int
    private let maxConcurrent: Int
    private let fetch: Fetch

    private var queue = Set<ID>()
    private var inFlight = Set<ID>()

    private var runningTasks = 0
    private var schedulerRunning = false

    private let debouncer = Debouncer(delay: .milliseconds(60))

    init(
        batchSize: Int = 4,
        maxConcurrent: Int = 2,
        fetch: @escaping Fetch
    ) {
        self.batchSize = batchSize
        self.maxConcurrent = maxConcurrent
        self.fetch = fetch
    }

    func enqueue(_ ids: [ID]) {
        for id in ids where !inFlight.contains(id) {
            queue.insert(id)
        }

        debouncer.call { [weak self] in
            await self?.startScheduler()
        }
    }

    func cancel(_ ids: [ID]) {
        for id in ids {
            queue.remove(id)
        }
    }

    private func startScheduler() async {
        guard !schedulerRunning else { return }
        schedulerRunning = true

        Task { await schedulerLoop() }
    }

    private func schedulerLoop() async {
        while !queue.isEmpty {

            if runningTasks >= maxConcurrent {
                try? await Task.sleep(for: .milliseconds(20))
                continue
            }

            let batch = takeBatch()

            guard !batch.isEmpty else { break }

            runningTasks += 1

            Task {
                await fetch(batch)
                await self.finishBatch(batch)
            }
        }

        schedulerRunning = false
    }

    private func takeBatch() -> [ID] {
        let ids = queue.prefix(batchSize)
        queue.subtract(ids)
        inFlight.formUnion(ids)
        return Array(ids)
    }

    private func finishBatch(_ ids: [ID]) {
        inFlight.subtract(ids)
        runningTasks -= 1
    }
}
