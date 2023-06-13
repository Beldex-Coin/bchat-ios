# Building

We typically develop against the latest stable version of Xcode.

As of this writing, that's Xcode 12.4

## Prerequistes

Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html).

## 1. Clone

Clone the repo to a working directory:

```
git clone https://github.com/beldex-coin/bchat-ios.git
```

**Recommendation:**

We recommend you fork the repo on GitHub, then clone your fork:

```
git clone https://github.com/<USERNAME>/bchat-ios.git
```

You can then add the Bchat repo to sync with upstream changes:

```
git remote add upstream https://github.com/beldex-coin/bchat-ios
```

## 2. Pods

To build and configure the libraries Bchat uses, just run:

```
pod install
```

## 3. Xcode

Open the `Bchat.xcworkspace` in Xcode.

```
open Bchat.xcworkspace
```

In the TARGETS area of the General tab, change the Team dropdown to
your own. You will need to do that for all the listed targets, e.g.
Bchat, BchatShareExtension, and BchatNotificationServiceExtension. You
will need an Apple Developer account for this.

On the Capabilities tab, turn off Push Notifications and Data Protection,
while keeping Background Modes on. The App Groups capability will need to
remain on in order to access the shared data storage.

Build and Run and you are ready to go!

## Known issues

### Push Notifications
Features related to push notifications are known to be not working for
third-party contributors since Apple's Push Notification service pushes
will only work with the Bchat production code signing
certificate.
