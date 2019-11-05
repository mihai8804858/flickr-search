# FlickrSearch
An image searching and displaying app based on Flickr API. All code was written by hand, without external dependencies.

### Requirements
* Xcode 11.2
* Swift 5.1

### Overview
* In order to separate API business logic from app business logic, I created a separate target for API and I'm importing the framework into the app where I need it. I'm exposing only the needed interfaces and models from API. Also, the unit tests for API are in a separate test bundle.
* For architecture I used VIP. Each screen has a separate builder that build the components (view, interactor, presenter) given needed inputs. If a screen needs to present other screens, I added a router for it. I also added unit tests for interactors, presenters and some common services (like image caching, image loading etc.).
* Although it's convenient to have global variables and access them from wherever I need, I used dependency injection in order to inject only needed services. This was also convenient for adding unit tests.
* In order to make work with UI more convenient, I implemented protocols like `StaticIdentifiable`, `StoryboardInstantiable` that instantiates a view controller from storyboard and some convenience methods to `UICollectionView` for cell and supplementary views registration and dequeuing.
* For thread-safe variables I implemented `Atomic`, which uses an `NSLock` to synchronize reading, writing and mutating.
*  Since I didn't use any external dependencies, I had to write my own `Debouncer` that debounces an action given a `TimeInterval`. Usually, I would have done this using `RxSwift`'s `debounce()` operator.
* For image caching I decided to write the images in files in documents directory. I also added an intermediate `NSCache` to minimize write/reads to/from files.
* To make unit testing more convenient, I implemented `FuncCheck` class, that I use to test if a method / closure was called. I also use it to asynchronously test method calls.
* While implementing and testing the app, I felt the necessity to view the images in full screen, so I took my time to implement this screen. Now when you tap on an image, a new screen will open with that image in full screen.

### Nice to have
* Would be nice to be able to zoom the image when it's opened in full screen. I wanted to implement this but it would have take me more time.
* While starting implementing image caching, I was thinking to add an index file where I would keep the images and urls that are cached on disk, read it on app launch, update it in memory and in the end write it back to disk. This way we wouldn't have to always check if file exists on disk. Since the index file can differ with the real files, it would have took me much more time to properly implement how we synchronize the index from disk with the index file from memory and with the images from disk.
* Would be nice to have a proper collection layout for images since we have different size ratios.
* An animated dummy state for cells would be nice. Because of time constraints I went with just adding a placeholder image.
