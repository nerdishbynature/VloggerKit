import Foundation
import RequestKit

let GoogleOAuthBaseURL = "https://accounts.google.com/o/oauth2"
let YouTubeBaseURL = "https://www.googleapis.com"
let VloggerKitErrorDomain = "com.nerdishbynature.vloggerkit.error"

public struct VloggerKit {
    public let configuration: TokenConfiguration

    public init(_ config: TokenConfiguration = TokenConfiguration()) {
        configuration = config
    }
}

internal extension Router {
    internal var URLRequest: NSURLRequest? {
        return request()
    }
}

