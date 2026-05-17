import Foundation

struct BufferItem: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let timestamp: Date

    init(_ text: String) {
        self.text = text
        self.timestamp = Date()
    }
}

@MainActor
final class BufferSystem: ObservableObject {
    struct Buffer {
        let name: String
        var items: [BufferItem] = []
        /// Index of the last-read item, or `items.count` when the user has not
        /// navigated since the buffer was last appended-to or freshly visited.
        /// "Parked past the end" lets the next `olderMessage()` read the newest
        /// item instead of skipping it (the previous semantics had position
        /// already at the newest, so the first swipe-back jumped to the
        /// second-newest, stranding the user one step ahead of where they
        /// thought they were).
        var position: Int = 0
        var isMuted: Bool = false
    }

    @Published private(set) var buffers: [Buffer] = []
    @Published private(set) var currentIndex: Int = 0

    private let maxItemsPerBuffer = 500

    init() {
        buffers = [
            Buffer(name: "all"),
            Buffer(name: "table"),
            Buffer(name: "chats"),
            Buffer(name: "activity"),
            Buffer(name: "misc"),
        ]
    }

    var currentBuffer: Buffer { buffers[currentIndex] }
    var currentBufferName: String { buffers[currentIndex].name }

    func addItem(_ text: String, buffer bufferName: String) {
        guard let idx = buffers.firstIndex(where: { $0.name == bufferName }) else { return }
        let item = BufferItem(text)
        appendTo(bufferIndex: idx, item: item)

        // Also add to "all" buffer
        if bufferName != "all", let allIdx = buffers.firstIndex(where: { $0.name == "all" }) {
            appendTo(bufferIndex: allIdx, item: item)
        }
    }

    private func appendTo(bufferIndex idx: Int, item: BufferItem) {
        buffers[idx].items.append(item)
        if buffers[idx].items.count > maxItemsPerBuffer {
            buffers[idx].items.removeFirst()
        }
        // Park past the end so the next olderMessage() lands on the new item.
        buffers[idx].position = buffers[idx].items.count
    }

    func nextBuffer() -> String {
        currentIndex = (currentIndex + 1) % buffers.count
        resetPositionToParkedEnd()
        return bufferInfo()
    }

    func previousBuffer() -> String {
        currentIndex = (currentIndex - 1 + buffers.count) % buffers.count
        resetPositionToParkedEnd()
        return bufferInfo()
    }

    func firstBuffer() -> String {
        currentIndex = 0
        resetPositionToParkedEnd()
        return bufferInfo()
    }

    func lastBuffer() -> String {
        currentIndex = buffers.count - 1
        resetPositionToParkedEnd()
        return bufferInfo()
    }

    /// Switching buffers is a fresh visit, so reset the read cursor past the
    /// end. That way the next `olderMessage()` reads the newest item.
    private func resetPositionToParkedEnd() {
        buffers[currentIndex].position = buffers[currentIndex].items.count
    }

    func olderMessage() -> String? {
        guard !buffers[currentIndex].items.isEmpty else { return nil }
        let count = buffers[currentIndex].items.count
        let pos = max(0, min(buffers[currentIndex].position, count) - 1)
        buffers[currentIndex].position = pos
        return buffers[currentIndex].items[pos].text
    }

    func newerMessage() -> String? {
        guard !buffers[currentIndex].items.isEmpty else { return nil }
        let count = buffers[currentIndex].items.count
        let pos = min(count - 1, max(-1, buffers[currentIndex].position) + 1)
        buffers[currentIndex].position = pos
        return buffers[currentIndex].items[pos].text
    }

    func oldestMessage() -> String? {
        guard !buffers[currentIndex].items.isEmpty else { return nil }
        buffers[currentIndex].position = 0
        return buffers[currentIndex].items[0].text
    }

    func newestMessage() -> String? {
        guard !buffers[currentIndex].items.isEmpty else { return nil }
        let last = buffers[currentIndex].items.count - 1
        buffers[currentIndex].position = last
        return buffers[currentIndex].items[last].text
    }

    func toggleMute() -> Bool {
        buffers[currentIndex].isMuted.toggle()
        return buffers[currentIndex].isMuted
    }

    func isMuted(_ name: String) -> Bool {
        buffers.first(where: { $0.name == name })?.isMuted ?? false
    }

    func mutedBufferNames() -> [String] {
        buffers.filter(\.isMuted).map(\.name)
    }

    func restoreMuted(_ names: Set<String>) {
        for i in buffers.indices {
            buffers[i].isMuted = names.contains(buffers[i].name)
        }
    }

    private func bufferInfo() -> String {
        let b = buffers[currentIndex]
        let muted = b.isMuted ? ", muted" : ""
        if b.items.isEmpty {
            return "\(b.name)\(muted). Empty."
        }
        let count = b.items.count
        let plural = count == 1 ? "item" : "items"
        let latest = b.items.last?.text ?? ""
        return "\(b.name)\(muted). \(count) \(plural). Most recent: \(latest)"
    }
}
