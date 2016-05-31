import RequestKit

public enum OAuthRouter: Router {
    case Authorize(OAuthConfiguration)
    case AccessToken(OAuthConfiguration, String)

    public var configuration: Configuration {
        switch self {
        case .Authorize(let config): return config
        case .AccessToken(let config, _): return config
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .Authorize:
            return .GET
        case .AccessToken:
            return .POST
        }
    }

    public var encoding: HTTPEncoding {
        switch self {
        case .Authorize:
            return .URL
        case .AccessToken:
            return .FORM
        }
    }

    public var path: String {
        switch self {
        case .Authorize:
            return "auth"
        case .AccessToken:
            return "token"
        }
    }

    public var params: [String: String] {
        switch self {
        case .Authorize(let config):
            return ["client_id": config.clientID, "redirect_uri": config.redirectURI, "response_type": "code", "scope": config.scope]
        case .AccessToken(let config, let code):
            return ["code": code, "grant_type": "authorization_code", "client_id": config.clientID, "redirect_uri": config.redirectURI]
        }
    }

    public var URLRequest: NSURLRequest? {
        switch self {
        case .Authorize(let config):
            let URLString = config.apiEndpoint.stringByAppendingURLPath(path)
            return request(URLString, parameters: params)
        case .AccessToken(let config, _):
            let URLString = config.apiEndpoint.stringByAppendingURLPath(path)
            return request(URLString, parameters: params)
        }
    }
}

