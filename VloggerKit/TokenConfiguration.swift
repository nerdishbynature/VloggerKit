import RequestKit

public struct TokenConfiguration: Configuration {
    public var apiEndpoint = YouTubeBaseURL
    public var accessToken: String?
    public var refreshToken: String?
    public var expirationDate: NSDate?

    public init(json: [String: AnyObject]) {
        accessToken = json["access_token"] as? String
        refreshToken = json["refresh_token"] as? String
        let expiresIn = json["expires_in"] as? Int
        let currentDate = NSDate()
        expirationDate = currentDate.dateByAddingTimeInterval(NSTimeInterval(expiresIn ?? 0))
    }

    public init(_ token: String? = nil, refreshToken: String? = nil, expirationDate: NSDate? = nil) {
        accessToken = token
        self.expirationDate = expirationDate
        self.refreshToken = refreshToken
    }
}
