import Foundation
// USE for Preview Swiftui and Testing
final class MockWebSocketClient: WebSocketClient {
    
    private var isConnected = false
    private var mockUpdates: [Any] = []
    private let delay: Duration

    init(
        mockUpdates: [Any] = [],
        delay: Duration = .seconds(1)
    ) {
        self.mockUpdates = mockUpdates
        self.delay = delay
    }

    private func connect() throws {
        isConnected = true
    }
    
    func authenticate(token: String) async throws {
        try connect()
        guard isConnected else {
            throw WebSocketError.disconnected
        }
        
        let auth = AuthPayload(token: token)
        
        // Simulate sending the auth message
        print("Mock authenticate with token: \(auth.token)")
        
        // Optional: Simulate network delay
        try? await Task.sleep(for: delay)
    }

    func send<T: Encodable>(_ value: T) async throws {
        // No-op or optionally log for debugging
        print("Mock send: \(value)")
    }

    func receive<T: Decodable>(as type: T.Type) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream { continuation in
            guard isConnected else {
                continuation.finish(throwing: WebSocketError.disconnected)
                return
            }

            Task {
                for update in mockUpdates {
                    try? await Task.sleep(for: delay)
                    if let typed = update as? T {
                        continuation.yield(typed)
                    } else {
                        continuation.finish(throwing: WebSocketError.invalidMessage)
                        return
                    }
                }
                continuation.finish()
            }
        }
    }

    func disconnect() {
        isConnected = false
    }
}
