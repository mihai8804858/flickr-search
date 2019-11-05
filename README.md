# FlickrSearch
An image searching and displaying app based on Flickr API. All code was written by hand, without external dependencies.

### Requirements
* Xcode 11.2
* Swift 5.1

### Overview
* In order to separate API business logic from app business logic, a separate target was created for API. The framework is imported in the app where it's needed. Only the needed interfaces and models are exposed from API. Also, the unit tests for API are in a separate test bundle.
* For architecture was used VIP. Each screen has a separate builder that builds the components (view, interactor, presenter) given needed inputs. If a screen needs to present other screens, a router was added for it. Unit tests for interactors, presenters and some common services (like image caching, image loading etc.) were also added.
* Although it's convenient to have global variables and access them from wherever needed, dependency injection was used in order to inject only needed services. This was also useful for adding unit tests.
* In order to make work with UI more robust, some protocols like `StaticIdentifiable` and `StoryboardInstantiable` were implemented that are responsible for instantiating a view controller from storyboard and some convenience methods to `UICollectionView` were added for cell and supplementary views registration and dequeuing.
* `Atomic` was implemented for thread-safe variables, which uses an `NSLock` to synchronize reading, writing and mutating.
*  Since no external dependencies were used, it was needed to write a `Debouncer` that debounces an action given a `TimeInterval`. Usually, this would have been done using `RxSwift`'s `debounce()` operator.
* For image caching it was decided to write the images in files in documents directory. An intermediate `NSCache` was added to minimize write/reads to/from files.
* To make unit testing more comfortable, a class names `FuncCheck` was implemented, which is used to test if a method / closure was called. It's also used to test asynchronous method calls.
* While implementing and testing the app, I felt the necessity to view the images in full screen, so I took my time to implement this screen. Now when you tap on an image, a new screen will open with that image in full screen.

### Nice to have
* Would be nice to be able to zoom the image when it's opened in full screen, but it would have taken more time to implement this.
* While starting implementing image caching, it was thought to add an index file which would would keep the images and urls that are cached on disk, read it on app launch, update it in memory and in the end write it back to disk. This way we wouldn't have to always check if file exists on disk. Since the index file can differ with the real files, it would have taken much more time to properly implement how we synchronize the index from disk with the index file from memory and with the images from disk.
* Would be nice to have a proper collection layout for images since we have different size ratios.
* An animated dummy state for cells would be nice. Because of time constraints only a placeholder image was added.
