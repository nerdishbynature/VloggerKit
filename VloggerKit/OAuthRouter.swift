import RequestKit

public enum OAuthRouter: Router {
    case authorize(OAuthConfiguration)
    case accessToken(OAuthConfiguration, String)

    public var configuration: Configuration {
        switch self {
        case .authorize(let config): return config
        case .accessToken(let config, _): return config
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .authorize:
            return .GET
        case .accessToken:
            return .POST
        }
    }

    public var encoding: HTTPEncoding {
        switch self {
        case .authorize:
            return .url
        case .accessToken:
            return .form
        }
    }

    public var path: String {
        switch self {
        case .authorize:
            return "auth"
        case .accessToken:
            return "token"
        }
    }

    public var params: [String: Any] {
        switch self {
        case .authorize(let config):
            return ["client_id": config.clientID, "redirect_uri": config.redirectURI, "response_type": "code", "scope": config.scope]
        case .accessToken(let config, let code):
            return ["code": code, "grant_type": "authorization_code", "client_id": config.clientID, "redirect_uri": config.redirectURI]
        }
    }

    public var URLRequest: Foundation.URLRequest? {
        switch self {
        case .authorize(let config):
            let url = URL(string: path, relativeTo: URL(string: config.apiEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        case .accessToken(let config, _):
            let url = URL(string: path, relativeTo: URL(string: config.apiEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        }
    }
}

