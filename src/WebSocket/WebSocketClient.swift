protocol WebSocketClient {
    func authenticate(token: String) async throws
    func send<T: Encodable>(_ value: T) async throws
    func receive<T: Decodable>(as type: T.Type) -> AsyncThrowingStream<T, Error>
    func disconnect()
}
