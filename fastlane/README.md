fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### bump_version
```
fastlane bump_version
```
Bump app version and build number
### commit_version
```
fastlane commit_version
```
Commit changed files and push to remote
### tag_version
```
fastlane tag_version
```
Create a git tag and push to remote
### build
```
fastlane build
```
Build app
### test
```
fastlane test
```
Run all tests
### release_to_testflight
```
fastlane release_to_testflight
```
Upload build to TestFlight

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
