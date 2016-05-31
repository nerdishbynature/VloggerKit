import RequestKit
import Foundation

public extension VloggerKit {
    public func refreshToken(session: RequestKitURLSession = NSURLSession.sharedSession(), oauthConfig: OAuthConfiguration, refreshToken: String, completion: (response: Response<TokenConfiguration>) -> Void) {
        let request = TokenRouter.RefreshToken(oauthConfig, refreshToken).URLRequest
        if let request = request {
            let task = session.dataTaskWithRequest(request) { data, response, err in
                guard let response = response as? NSHTTPURLResponse else { return }
                guard let data = data else { return }
                do {
                    let responseJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                    if let responseJSON = responseJSON as? [String: AnyObject] {
                        if response.statusCode != 200 {
                            let errorDescription = responseJSON["error_description"] as? String ?? ""
                            let error = NSError(domain: VloggerKitErrorDomain, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])
                            completion(response: Response.Failure(error))
                        } else {
                            let tokenConfig = TokenConfiguration(json: responseJSON)
                            completion(response: Response.Success(tokenConfig))
                        }
                    }
                }
            }
            task.resume()
        }
    }
}

public enum TokenRouter: Router {
    case RefreshToken(OAuthConfiguration, String)

    public var configuration: Configuration {
        switch self {
        case .RefreshToken(let config, _): return config
        }
    }

    public var method: HTTPMethod {
        return .POST
    }

    public var encoding: HTTPEncoding {
        return .FORM
    }

    public var params: [String: String] {
        switch self {
        case .RefreshToken(let config, let token):
            return ["refresh_token": token, "grant_type": "refresh_token", "client_id": config.clientID]
        }
    }

    public var path: String {
        switch self {
        case .RefreshToken(_, _):
            return "token"
        }
    }

    public var URLRequest: NSURLRequest? {
        switch self {
        case .RefreshToken(let config, _):
            let URLString = config.apiEndpoint.stringByAppendingURLPath(path)
            return request(URLString, parameters: params)
        }
    }
}

