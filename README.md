# VloggerKit

[![Build Status](https://travis-ci.org/nerdishbynature/VloggerKit.svg?branch=master)](https://travis-ci.org/nerdishbynature/VloggerKit)
[![codecov.io](https://codecov.io/github/nerdishbynature/VloggerKit/coverage.svg?branch=master)](https://codecov.io/github/nerdishbynature/VloggerKit?branch=master)

## Authentication

Authentication is handled using Configurations.

There are two types of Configurations, `TokenConfiguration` and `OAuthConfiguration`.

### TokenConfiguration

`TokenConfiguration` is used if you are using Access Token based Authentication which was obtained through
the OAuth Flow

You can initialize a new config as follows:

```swift
let config = TokenConfiguration(token: "12345")
```

After you got your token you can use it with `Octokit`

```swift
VloggerKit(config).categories() { response in
  switch response {
  case .Success(let categories):
    println(categories)
  case .Failure(let error):
    println(error)
  }
}
```

### OAuthConfiguration

`OAuthConfiguration` is meant to be used, if you don't have an access token already and the
user has to login to your application. This also handles the OAuth flow.

You can authenticate an user:

```swift
let config = OAuthConfiguration(token: "<Your Client ID>", redirectURI: "<Your redirect uri>", scope: "<Your scope>")
config.authenticate()

```

After you got your config you can authenticate the user:

```swift
// AppDelegate.swift

config.authenticate()

func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
  config.handleOpenURL(url) { config in
    // do something
  }
  return false
}

```

Please note that you will be given a `TokenConfiguration` back from the OAuth flow.
You have to store the `accessToken` yourself. If you want to make further requests it is not
necessary to do the OAuth Flow again. You can just use a `TokenConfiguration`.

```swift
let token = // get your token from your keychain, user defaults (not recommended) etc.
let config = TokenConfiguration(token)
VloggerKit(config).categories() { response in
  switch response {
  case .Success(let categories):
    println(categories)
  case .Failure(let error):
    println(error)
  }
}
```
