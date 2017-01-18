import Foundation
import RequestKit

public struct OAuthConfiguration: Configuration {
    public var apiEndpoint: String
    public var accessToken: String?
    public let clientID: String
    public let redirectURI: String
    public let scope: String

    public init(_ url: String = GoogleOAuthBaseURL, clientID: String, redirectURI: String, scope: String) {
        apiEndpoint = url
        self.redirectURI = redirectURI
        self.clientID = clientID
        self.scope = scope
    }

    public func authenticate() -> URL? {
        return OAuthRouter.authorize(self).URLRequest?.url
    }

    public func authorize(_ session: RequestKitURLSession = URLSession.shared, code: String, completion: @escaping (_ config: TokenConfiguration) -> Void) {
        let request = OAuthRouter.accessToken(self, code).URLRequest
        if let request = request {
            let task = session.dataTask(with: request) { data, response, err in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        return
                    } else {
                        if let config = self.configFromData(data) {
                            completion(config)
                        }
                    }
                }
            }
            task.resume()
        }
    }

    fileprivate func configFromData(_ data: Data?) -> TokenConfiguration? {
        guard let data = data else { return nil }
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else { return nil }
            let config = TokenConfiguration(json: json)
            return config
        } catch {
            return nil
        }
    }

    public func handleOpenURL(_ url: URL, completion: @escaping (_ config: TokenConfiguration) -> Void) {
        let params = url.URLParameters()
        if let code = params["code"] {
            authorize(code: code) { config in
                completion(config)
            }
        }
    }

    public func accessTokenFromResponse(_ response: String) -> String? {
        let accessTokenParam = response.components(separatedBy: "&").first
        if let accessTokenParam = accessTokenParam {
            return accessTokenParam.components(separatedBy: "=").last
        }
        return nil
    }
}
