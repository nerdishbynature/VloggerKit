import RequestKit

extension VloggerKit {
    public func insertVideo(_ dictionary: [String: AnyObject], videoURL: URL, completion: @escaping (_ response: Response<[String: AnyObject]>) -> Void) {
        let router = VideoRouter.insertVideo(configuration, dictionary)
        guard let request = router.request() else {
            let error = NSError(domain: "com.nerdishbynature.vloggerkit", code: 404, userInfo: nil)
            completion(Response.failure(error))
            return
        }
        let task = URLSession.shared.uploadTask(with: request, fromFile: videoURL) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if !response.wasSuccessful {
                    var userInfo = [String: AnyObject]()
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] {
                        userInfo["json"] = json as AnyObject?
                    }
                    let error = NSError(domain: "com.nerdishbynature.vloggerkit", code: response.statusCode, userInfo: userInfo)
                    completion(Response.failure(error))
                    return
                }
            }

            if let error = error {
                completion(Response.failure(error))
            } else {
                if let data = data {
                    do {
                        let JSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]
                        completion(Response.success(JSON!))
                    } catch {
                        completion(Response.failure(error))
                    }
                }
            }
        }
        task.resume()
    }
}

public enum VideoRouter: JSONPostRouter {
    case insertVideo(TokenConfiguration, [String: AnyObject])

    public var method: HTTPMethod {
        switch self {
        case .insertVideo:
            return .POST
        }
    }

    public var encoding: HTTPEncoding {
        switch self {
        case .insertVideo:
            return .json
        }
    }

    public var configuration: Configuration {
        switch self {
        case .insertVideo(let config, _): return config
        }
    }

    public var params: [String: Any] {
        switch self {
        case .insertVideo(_, let dict):
            return ["part": dict.keys.joined(separator: ",")]
        }
    }

    public var path: String {
        switch self {
        case .insertVideo:
            return "upload/youtube/v3/videos"
        }
    }

    public func request(_ urlString: String, parameters: [String: Any]) -> URLRequest? {
        switch self {
        case .insertVideo(let config, let snippet):
            let url = URL(string: path, relativeTo: URL(string: config.apiEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            var mutableURLRequest = request(components!, parameters: parameters)
            let data = try? JSONSerialization.data(withJSONObject: snippet, options: JSONSerialization.WritingOptions())
            mutableURLRequest?.httpBody = data
            mutableURLRequest?.setValue("Bearer \(configuration.accessToken ?? "")", forHTTPHeaderField: "Authorization")
            mutableURLRequest?.setValue("video/*", forHTTPHeaderField: "content-type")
            mutableURLRequest?.httpMethod = method.rawValue
            return mutableURLRequest
        }
    }
}
