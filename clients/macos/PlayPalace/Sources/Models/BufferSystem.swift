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
        var position: Int = -1
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
        buffers[idx].items.append(item)
        buffers[idx].position = buffers[idx].items.count - 1
        if buffers[idx].items.count > maxItemsPerBuffer {
            buffers[idx].items.removeFirst()
            buffers[idx].position = buffers[idx].items.count - 1
        }

        // Also add to "all" buffer
        if bufferName != "all" {
            if let allIdx = buffers.firstIndex(where: { $0.name == "all" }) {
                buffers[allIdx].items.append(item)
                buffers[allIdx].position = buffers[allIdx].items.count - 1
                if buffers[allIdx].items.count > maxItemsPerBuffer {
                    buffers[allIdx].items.removeFirst()
                    buffers[allIdx].position = buffers[allIdx].items.count - 1
                }
            }
        }
    }

    func nextBuffer() -> String {
        currentIndex = (currentIndex + 1) % buffers.count
        return bufferInfo()
    }

    func previousBuffer() -> String {
        currentIndex = (currentIndex - 1 + buffers.count) % buffers.count
        return bufferInfo()
    }

    func firstBuffer() -> String {
        currentIndex = 0
        return bufferInfo()
    }

    func lastBuffer() -> String {
        currentIndex = buffers.count - 1
        return bufferInfo()
    }

    func olderMessage() -> String? {
        guard !buffers[currentIndex].items.isEmpty else { return nil }
        let pos = max(0, buffers[currentIndex].position - 1)
        buffers[currentIndex].position = pos
        return buffers[currentIndex].items[pos].text
    }

    func newerMessage() -> String? {
        guard !buffers[currentIndex].items.isEmpty else { return nil }
        let pos = min(buffers[currentIndex].items.count - 1, buffers[currentIndex].position + 1)
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
        return "\(b.name)\(muted). \(b.items.count) items"
    }
}
