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

    public func authenticate() -> NSURL? {
        return OAuthRouter.Authorize(self).URLRequest?.URL
    }

    public func authorize(session: RequestKitURLSession = NSURLSession.sharedSession(), code: String, completion: (config: TokenConfiguration) -> Void) {
        let request = OAuthRouter.AccessToken(self, code).URLRequest
        if let request = request {
            let task = session.dataTaskWithRequest(request) { data, response, err in
                if let response = response as? NSHTTPURLResponse {
                    if response.statusCode != 200 {
                        return
                    } else {
                        if let config = self.configFromData(data) {
                            completion(config: config)
                        }
                    }
                }
            }
            task.resume()
        }
    }

    private func configFromData(data: NSData?) -> TokenConfiguration? {
        guard let data = data else { return nil }
        do {
            guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] else { return nil }
            let config = TokenConfiguration(json: json)
            return config
        } catch {
            return nil
        }
    }

    public func handleOpenURL(url: NSURL, completion: (config: TokenConfiguration) -> Void) {
        let params = url.URLParameters()
        if let code = params["code"] {
            authorize(code: code) { config in
                completion(config: config)
            }
        }
    }

    public func accessTokenFromResponse(response: String) -> String? {
        let accessTokenParam = response.componentsSeparatedByString("&").first
        if let accessTokenParam = accessTokenParam {
            return accessTokenParam.componentsSeparatedByString("=").last
        }
        return nil
    }
}
