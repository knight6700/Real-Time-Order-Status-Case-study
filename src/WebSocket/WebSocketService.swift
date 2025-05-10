import Foundation

/// A concrete implementation of a WebSocket client service that manages the lifecycle,
/// authentication, sending, and receiving of WebSocket messages.
///
/// `WebSocketService` encapsulates a `URLSessionWebSocketTask` to abstract WebSocket
/// operations such as connection management, encoding/decoding messages, and real-time
/// data streaming.
///
/// - Note: Designed to work with a defined `Environment` for flexible baseURL handling.
final class WebSocketService: WebSocketClient {
    
    // MARK: - Singleton Implementation
    static let shared = WebSocketService()
    // MARK: - Private Properties
    /// The underlying WebSocket task. When set, updates the `isConnected` state.
    private var webSocketTask: URLSessionWebSocketTask? {
        didSet {
            if let task = webSocketTask {
                switch task.state {
                case .running:
                    connectionState = .connected
                case .canceling, .completed:
                    connectionState = .disconnected
                case .suspended:
                    connectionState = .connecting
                @unknown default:
                    connectionState = .failed
                }
            } else {
                connectionState = .disconnected
            }
        }
    }

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let environment: Environment
    private(set) var connectionState: ConnectionState = .disconnected

    // MARK: - Computed Properties
    
    /// Constructs the full WebSocket URL from the base environment and path.
    var url: URL? {
        URL(string: environment.baseURL)
    }

    // MARK: - Initializer
    
    /// Initializes the WebSocket service.
    ///
    /// - Parameters:
    ///   - path: The path to append to the environment’s base URL.
    ///   - session: The URLSession to use (defaults to `.shared`).
    ///   - decoder: JSONDecoder used for incoming messages (defaults to `.default`).
    ///   - encoder: JSONEncoder used for outgoing messages (defaults to `.default`).
    ///   - environment: Provides baseURL and other environment-specific data (defaults to `.defaultEnvironment`).
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = .default,
        encoder: JSONEncoder = .default,
        environment: Environment = .defaultEnvironment
    ) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
        self.environment = environment
    }

    /// Ensures the WebSocket disconnects cleanly on deallocation.
    deinit {
        disconnect()
    }

    // MARK: - Private Methods

    /// Creates a new WebSocket task for the given URL.
    private func createWebSocketTask(for url: URL) -> URLSessionWebSocketTask {
        session.webSocketTask(with: url)
    }

    /// Establishes a new WebSocket connection if one doesn't already exist.
    ///
    /// - Throws: `WebSocketError.connectionFailed` if the connection fails.
    private func connect() throws {
        guard webSocketTask == nil, let url else { return }
        let task = createWebSocketTask(for: url)
        task.resume()
        self.webSocketTask = task

        guard task.state == .running else {
            throw WebSocketError.connectionFailed
        }
    }

    /// Connects to the WebSocket server only if not already connected.
    private func connectIfNeeded() throws {
        guard connectionState == .disconnected else { return }
        try connect()
    }

    // MARK: - Public Methods

    /// Authenticates the WebSocket session using a token.
    ///
    /// - Parameter token: The authentication token.
    /// - Throws: A WebSocket error if connection or encoding fails.
    func authenticate(token: String) async throws {
        try connectIfNeeded()
        try await send(AuthPayload(token: token))
    }

    /// Sends an encodable message over the WebSocket connection.
    ///
    /// - Parameter value: The message to send.
    /// - Throws:
    ///   - `WebSocketError.disconnected` if no connection is active.
    ///   - `WebSocketError.encodingFaild` if encoding fails.
    ///   - `WebSocketError.serverError` if data cannot be converted to string.
    func send<T: Encodable>(_ value: T) async throws {
        guard let task = webSocketTask else {
            throw WebSocketError.disconnected
        }

        do {
            let data = try encoder.encode(value)
            guard let string = String(data: data, encoding: .utf8) else {
                throw WebSocketError.serverError("Failed to encode message as UTF-8 string")
            }
            try await task.send(.string(string))
        } catch {
            throw WebSocketError.encodingFaild(error)
        }
    }

    /// Receives messages from the WebSocket and decodes them as a stream of a specified type.
    ///
    /// - Parameter type: The expected message type.
    /// - Returns: An `AsyncThrowingStream` of decoded messages.
    func receive<T: Decodable>(as type: T.Type) -> AsyncThrowingStream<T, Error> {
        guard let task = webSocketTask else {
            return AsyncThrowingStream { continuation in
                continuation.finish(throwing: WebSocketError.disconnected)
            }
        }

        return AsyncThrowingStream { continuation in
            Task {
                while true {
                    do {
                        let message = try await task.receive()
                        let data: Data

                        switch message {
                        case .string(let text):
                            guard let stringData = text.data(using: .utf8) else {
                                throw WebSocketError.invalidMessage
                            }
                            data = stringData
                        case .data(let binaryData):
                            data = binaryData
                        @unknown default:
                            throw WebSocketError.invalidMessage
                        }

                        let decoded = try decoder.decode(T.self, from: data)
                        continuation.yield(decoded)

                    } catch {
                        continuation.finish(throwing: error)
                        break
                    }
                }
            }
        }
    }

    /// disconnects from the WebSocket server.
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
}
