# WebSocket Client Documentation

## Overview
This documentation covers the complete WebSocket client implementation for handling real-time Orders in a Swift application, including the core `WebSocketService` implementation.

## Table of Contents
1. [Core Components](#core-components)
2. [Models](#models)
3. [WebSocket Services](#websocket-services)
4. [Error Handling](#error-handling)
5. [Environment Configuration](#environment-configuration)
6. [Mock Services](#mock-services)
7. [Usage Examples](#usage-examples)

---

## Core Components

### WebSocketService
```swift
final class WebSocketService: WebSocketClient
```
The main WebSocket implementation that handles:
- Connection lifecycle management
- Authentication
- Message sending/receiving
- Error handling

**Key Features:**
- Thread-safe connection state management
- Automatic reconnection capability
- Type-safe message encoding/decoding
- Clean resource disposal

**Initialization:**
```swift
init(
    session: URLSession = .shared,
    decoder: JSONDecoder = .default,
    encoder: JSONEncoder = .default,
    environment: Environment = .defaultEnvironment
)
```

**Lifecycle Methods:**
| Method | Description |
|--------|-------------|
| `authenticate(token:)` | Establishes connection and authenticates |
| `send(_:)` | Sends encodable messages |
| `receive(as:)` | Streams decoded messages |
| `disconnect()` | Cleanly closes connection |

---

## Models

### AuthPayload
```swift
struct AuthPayload: Encodable
```
- Authentication structure with:
  - Required `token` string
  - Hardcoded `action: "authenticate"`

### WebSocketMessage
```swift
struct WebSocketMessage<T: Codable>: Codable
```
- Generic message wrapper with:
  - `type`: Message identifier
  - `payload`: Generic content
  - `meta`: Optional timestamp metadata

### OrderDTO
```swift
struct OrderDTO: Decodable
```
- Order data model containing:
  - `id`, `title`, `location`
  - `startTime`/`endTime` dates
  - `orderStatus` enum

### OrderStatus
```swift
enum OrderStatus: String, Decodable
```
- Status cases with display extensions:
  - `.submitted`, `.routed`, etc.
  - `title`: User-friendly strings
  - `color`: Status-specific colors

---

## WebSocket Services

### Protocol
```swift
protocol WebSocketClient
```
Standard interface for:
- Authentication
- Message sending/receiving
- Connection management

### Implementation
```swift
final class WebSocketService: WebSocketClient
```
**Key Implementation Details:**
- Uses `URLSessionWebSocketTask` internally
- Manages connection state automatically
- Provides type-safe message handling
- Includes proper resource cleanup

### Mock Service
```swift
final class MockWebSocketClient: WebSocketClient
```
- Testing/preview implementation
- Configurable mock responses
- Simulated network delays

---

## Error Handling

### WebSocketError
```swift
enum WebSocketError: Error
```
Comprehensive error cases:
- Connection failures
- Message processing errors
- Server communication issues
- Encoding/decoding failures
### 🔌 `ConnectionState` Enum

The `ConnectionState` enum represents the lifecycle state of a WebSocket connection.

```swift
enum ConnectionState: Equatable {
    case connected
    case disconnected
    case connecting
    case failed
}
```
#### States:

* `connected`:
  Indicates that the WebSocket is successfully connected and ready to send/receive messages.

* `disconnected`:
  Represents a clean or unexpected disconnection. No active WebSocket task is running.

* `connecting`:
  The WebSocket is in the process of establishing a connection. Typically mapped to `.suspended` task state.

* `failed`:
  Indicates a failure occurred while trying to connect or during active communication (e.g. due to network issues or server-side error).

#### Usage:

This enum is used to monitor and react to connection state changes in the `WebSocketService`, enabling components to display appropriate UI or retry logic based on the real-time WebSocket status.

```swift
switch webSocketService.shared.connectionState {
case .connected:
    print("Connected to WebSocket.")
case .disconnected:
    print("WebSocket is disconnected.")
case .connecting:
    print("Trying to connect...")
case .failed:
    print("Connection failed.")
}
```

## Environment Configuration

### Environment
```swift
enum Environment
```
- Manages deployment environments (dev/qa/prod)
- Provides environment-specific WebSocket URLs
- Automatic environment selection:
  - Debug → dev
  - Testing → qa
  - Release → prod

### JSON Coding
```swift
extension JSONDecoder/Encoder
```
Preconfigured with:
- ISO8601 date handling
- Snake case conversion
- Standardized configuration

---

## Usage Examples

### Basic Setup
```swift
let service = WebSocketService()
```

### Authentication
```swift
try await service.authenticate(token: "user_token")
```

### Sending Messages
```swift
let request = OrderRequest(action: "subscribe", orderId: "123")
try await service.send(request)
```

### Receiving Updates
```swift
let stream = service.receive(as: WebSocketMessage<OrderDTO>.self)
for try await message in stream {
    handleOrder(message.payload)
}
```

### Clean Disconnection
```swift
service.disconnect()
```

### Mock Usage
```swift
let mock = MockWebSocketClient(mockUpdates: [testOrder])
```

---

## Best Practices

1. **Connection Management**
   - Always call `disconnect()` when done
   - Check `isConnected` before operations
   - Handle authentication errors gracefully

2. **Message Handling**
   - Use strong types for messages
   - Implement proper error handling
   - Consider message validation

3. **Testing**
   - Use mock service for unit tests
   - Test different network conditions
   - Verify error recovery

4. **Performance**
   - Reuse WebSocketService instances
   - Minimize message size
   - Consider compression for large payloads

---
Here’s your **cleaned-up and properly indented README-style** Markdown section for the Design Pattern using a Singleton WebSocket:

---

## **Design Pattern**

We use the **Singleton** pattern for managing the WebSocket connection:

### 1. **Single Connection Management** 🎯

* **Network Efficiency**: WebSocket connections are expensive to establish (TCP handshake + WebSocket upgrade).
* **Prevents Duplicate Connections**: Singleton ensures all app components reuse the same connection.

```swift
// ❌ Without Singleton:
let client1 = WebSocketClient()  // New connection
let client2 = WebSocketClient()  // Another connection (wasteful)
```

### 2. **Centralized State Control** 🔄

* **Consistent State**: All parts of the app see the same connection status (connected/disconnected).
* **Synchronized Reconnects**: No competing reconnection attempts from multiple instances.

```swift
// ✅ With Singleton:
orderView.observe(WebSocketClient.shared.connectionState)
tradeView.observe(WebSocketClient.shared.connectionState)
```
### Full Feature Scale:
- Implement a Dependency Container to manage and inject a shared instance of `WebSocketClient`, ensuring centralized control, improved testability, and better resource management across the app.

---

## Dependencies
- Foundation
- SwiftUI (for status display extensions)
- Combine (for reactive streams)

---

## Troubleshooting Guide

| Symptom | Possible Cause | Solution |
|---------|---------------|----------|
| Connection fails | Invalid URL/Network issues | Verify environment URL |
| Authentication fails | Invalid token | Check auth token |
| Message decoding fails | Type mismatch | Verify payload structure |
| Unexpected disconnects | Network instability | Implement reconnection logic |
## Diagram
# Class diagram
![Class Diagram](./diagram/ClassDiagram.png)
