import RequestKit

public struct TokenConfiguration: Configuration {
    public var apiEndpoint = YouTubeBaseURL
    public var accessToken: String?
    public var refreshToken: String?
    public var expirationDate: Date?

    public init(json: [String: AnyObject]) {
        accessToken = json["access_token"] as? String
        refreshToken = json["refresh_token"] as? String
        let expiresIn = json["expires_in"] as? Int
        let currentDate = Date()
        expirationDate = currentDate.addingTimeInterval(TimeInterval(expiresIn ?? 0))
    }

    public init(_ token: String? = nil, refreshToken: String? = nil, expirationDate: Date? = nil) {
        accessToken = token
        self.expirationDate = expirationDate
        self.refreshToken = refreshToken
    }
}
