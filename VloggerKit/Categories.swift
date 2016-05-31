import RequestKit

@objc public class YouTubeCategory: NSObject {
    public let id: String
    public var etag: String?
    public var kind: String?
    public var snippet: CategorySnippet?

    public init(_ json: [String: AnyObject]) {
        if let id = json["id"] as? String {
            self.id = id
            etag = json["etag"] as? String
            kind = json["kind"] as? String
            if let snippetJSON = json["snippet"] as? [String: AnyObject] {
                snippet = CategorySnippet(snippetJSON)
            }
        } else {
            id = "-1"
        }
    }
}

@objc public class CategorySnippet: NSObject {
    public let channelID: String?
    public let title: String?
    public let assignable: Bool?

    public init(_ json: [String: AnyObject]) {
        self.channelID = json["channelId"] as? String
        self.title = json["title"] as? String
        self.assignable = json["assignable"] as? Bool
    }
}

public extension VloggerKit {
    public func categories(session: RequestKitURLSession = NSURLSession.sharedSession(), regionCode: String = "us", completion: (response: Response<[YouTubeCategory]>) -> Void) {
        let router = CategoriesRouter.GetCategories(configuration, regionCode)
        router.loadJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(response: Response.Failure(error))
            } else {
                if let json = json, items = json["items"] as? [[String: AnyObject]] {
                    let categories = items.map({ YouTubeCategory($0) })
                    completion(response: Response.Success(categories))
                }
            }
        }
    }
}

public enum CategoriesRouter: Router {
    case GetCategories(TokenConfiguration, String)

    public var configuration: Configuration {
        switch self {
        case .GetCategories(let configuration, _):
            return configuration
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .GetCategories:
            return .GET
        }
    }

    public var encoding: HTTPEncoding {
        switch self {
        case .GetCategories:
            return .URL
        }
    }

    public var path: String {
        switch self {
        case .GetCategories:
            return "/youtube/v3/videoCategories"
        }
    }

    public var params: [String: String] {
        switch self {
        case .GetCategories(_, let regionCode):
            return ["part": "snippet", "regionCode": regionCode]
        }
    }
}

