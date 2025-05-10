import Foundation

enum Environment {
    case dev, qa, prod

    var baseURL: String {
        switch self {
        case .dev: return  "wss://dev.example.com/ws"
        case .qa: return "wss://qa.example.com/ws"
        case .prod: return "wss://prod.example.com/ws"
        }
    }
}

extension Environment {
   static var defaultEnvironment: Environment {
        #if DEBUG
        return .dev
        #elseif TESTING
        return .qa
        #else
        return .prod
        #endif
    }
}
