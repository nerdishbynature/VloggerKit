import RequestKit

extension VloggerKit {
    public func insertVideo(dictionary: [String: AnyObject], videoURL: NSURL, completion: (response: Response<[String: AnyObject]>) -> Void) {
        let router = VideoRouter.InsertVideo(configuration, dictionary)
        guard let request = router.request() else {
            let error = NSError(domain: "com.nerdishbynature.vloggerkit", code: 404, userInfo: nil)
            completion(response: Response.Failure(error))
            return
        }
        let task = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromFile: videoURL) { data, response, error in
            if let response = response as? NSHTTPURLResponse {
                if !response.wasSuccessful {
                    var userInfo = [String: AnyObject]()
                    if let data = data, json = try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String: AnyObject] {
                        userInfo["json"] = json
                    }
                    let error = NSError(domain: "com.nerdishbynature.vloggerkit", code: response.statusCode, userInfo: userInfo)
                    completion(response: Response.Failure(error))
                    return
                }
            }

            if let error = error {
                completion(response: Response.Failure(error))
            } else {
                if let data = data {
                    do {
                        let JSON = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String: AnyObject]
                        completion(response: Response.Success(JSON!))
                    } catch {
                        completion(response: Response.Failure(error))
                    }
                }
            }
        }
        task.resume()
    }
}

public enum VideoRouter: JSONPostRouter {
    case InsertVideo(TokenConfiguration, [String: AnyObject])

    public var method: HTTPMethod {
        switch self {
        case .InsertVideo:
            return .POST
        }
    }

    public var encoding: HTTPEncoding {
        switch self {
        case .InsertVideo:
            return .JSON
        }
    }

    public var configuration: Configuration {
        switch self {
        case .InsertVideo(let config, _): return config
        }
    }

    public var params: [String: String] {
        switch self {
        case .InsertVideo(_, let dict):
            return ["part": dict.keys.joinWithSeparator(",")]
        }
    }

    public var path: String {
        switch self {
        case .InsertVideo:
            return "upload/youtube/v3/videos"
        }
    }

    public func request(urlString: String, parameters: [String: String]) -> NSURLRequest? {
        switch self {
        case .InsertVideo(_, let snippet):
            let URLString = [urlString, urlQuery(params) ?? ""].joinWithSeparator("?")
            if let URL = NSURL(string: URLString) {
                let mutableURLRequest = NSMutableURLRequest(URL: URL)
                let data = try? NSJSONSerialization.dataWithJSONObject(snippet, options: NSJSONWritingOptions())
                mutableURLRequest.HTTPBody = data
                mutableURLRequest.setValue("Bearer \(configuration.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                mutableURLRequest.setValue("video/*", forHTTPHeaderField: "content-type")
                mutableURLRequest.HTTPMethod = method.rawValue
                return mutableURLRequest
            }
            return nil
        }
    }
}
