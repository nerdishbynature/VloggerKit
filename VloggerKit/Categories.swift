import RequestKit

@objc open class YouTubeCategory: NSObject {
    open let id: String
    open var etag: String?
    open var kind: String?
    open var snippet: CategorySnippet?

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

@objc open class CategorySnippet: NSObject {
    open let channelID: String?
    open let title: String?
    open let assignable: Bool?

    public init(_ json: [String: AnyObject]) {
        self.channelID = json["channelId"] as? String
        self.title = json["title"] as? String
        self.assignable = json["assignable"] as? Bool
    }
}

public extension VloggerKit {
    public func categories(_ session: RequestKitURLSession = URLSession.shared, regionCode: String = "us", completion: @escaping (_ response: Response<[YouTubeCategory]>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = CategoriesRouter.getCategories(configuration, regionCode)
        return router.loadJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            } else {
                if let json = json, let items = json["items"] as? [[String: AnyObject]] {
                    let categories = items.map({ YouTubeCategory($0) })
                    completion(Response.success(categories))
                }
            }
        }
    }
}

public enum CategoriesRouter: Router {
    case getCategories(TokenConfiguration, String)

    public var configuration: Configuration {
        switch self {
        case .getCategories(let configuration, _):
            return configuration
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .getCategories:
            return .GET
        }
    }

    public var encoding: HTTPEncoding {
        switch self {
        case .getCategories:
            return .url
        }
    }

    public var path: String {
        switch self {
        case .getCategories:
            return "/youtube/v3/videoCategories"
        }
    }

    public var params: [String: Any] {
        switch self {
        case .getCategories(_, let regionCode):
            return ["part": "snippet", "regionCode": regionCode]
        }
    }
}

