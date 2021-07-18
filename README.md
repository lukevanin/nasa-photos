# NASA Photos Browser

Displays photos from NASA's images API. This is a small educational example that 
demonstrates some useful concepts:

- Basic Model-View-Controller architecture
- UI and Unit testing
- Separation of concerns: user interface, domain, and networking 
- Using Codable objects
- Building reactive applications using Combine Publisher


## Project


### Code Style

Code is formatted to fit to a 80 character margin. 
Default Xcode settings are used for indentation and formatting - lines are indented using 4 spaces.


## Requirements


### Application ###

1. Support iPhone and iPad vertical and horizontal orientations.
2. Use localizable strings for text.
3. Support right-to-left layouts: Use leading/trailing vs left/right.
4. Support dynamic font sizing for text.
5. Support dark and light mode: Use system colour names.


### Photos List Screen ###

Display a list of photos from NASA's images API. 
Display an activity indicator while the list of photos is loading. Pull down to reload the list of photos. 
Display an error alert if the photos cannot be loaded. 
For each item, display the image thumbnail, title, photographer, and date.
Tap on an item in the list to display the photo details. 
Load additional images when the last item appears in the list.


### Photo Detail Screen ###

Display a higher resolution version of the photo with the title, photographer, date, and information about the photo.


## Design Considerations ##

### Testing  ###

Some unit tests have been implemented, but the test suite has not yet reached full (or even adequate) test coverage.
Most notibly absent are User Interface and Integration tests.
Compared to unit tests, these tests are typically more labour intensive to implement, and are often less robuts (more prone to flakiness).
The return on investment is comparatively low for the effort required for a decent implementation.
More tests may be added in future as more time is spent on this project. 

### User Interface ###

The original requirements called for using Storyboards. 
This project uses source code to define the user interface, for the following reasons:

1. Storyboards are problematic when marging changes using source control such as Git. Merging or rebasing can often change storyboard source files in ways that make it impossible to edit the storyboard in Xcode. In these situations, the file needs to be manually edited to fix changes. Manually editing storyboard source files can be time consuming and error-prone.
2. The Storyboard editor is broken in some versions of Xcode. The extent to which the editor is broken varies between versions, ranging from annoying bugs, to being completely unusable. 
3. Not all user interface functionality can be edited using the storyboard editor. Some functionality can only be defined in code.
4. ...

The approach taken in this project is to use auto-layout to define the user interface components and layout.
Helper extensions are used to reduce the boilerplate needed to create user interfaces, reducing large uncertainty and complicated layouts to a few lines.
Below is an example the code used to create the layout for the photo detail screen (seen in `PhotoViewController.loadView`). 
While the code is different to standard auto-layout, it is arguably still recognizable to anyone familiar with auto-layout, while also significantly reducing the amount of boilerplate usually needed.

```
view = UIScrollView(
    axis: .vertical,
    contentView: UIStackView( 
        axis: .vertical,
        arrangedSubviews: [
            photoImageView
                .with(aspectRatioEqualTo: 375.0 / 230),
            UIStackView(
                axis: .vertical,
                spacing: 24,
                arrangedSubviews: [
                    infoView,
                    bodyLabel,
                ]
            )
            .padding(UIEdgeInsets(horizontal: 16, vertical: 24))
        ]
    )
)
.with(backgroundColor: .systemBackground)
```

### Model Architecture ###

Models in this project are simple, mostly standalone, data stores. 
An application with more intricate or demanding requirements may benefit from a more robust, versatile, or scalable solution, such as a database, or reduce model.


### API ###

This app uses the NASA images API to retrieve images to display. Consult the 
documentation below for furthe details.

Endpoint: from https://images-api.nasa.gov/search?q=%22%22
Document: https://images.nasa.gov/docs/images.nasa.gov_api_docs.pdf
Search results use Collection+JSON format: https://github.com/collection-json/spec

The following data types are used by the application:
```
Link<T> {
    "href": URL, // "https://images-assets.nasa.gov/image/as11-40-5874/as11-40-5874~thumb.jpg
    "rel": String, // e.g. "preview", "next"
    "render": String?, // e.g. image"
    "prompt: String?, // e.g. Next
}

MediaType {
    "image"
    "audio"
}

Data {
  "center": String, // e.g. JSC
  "date_created": Date, // e.g. 1969-07-21T00:00:00Z
  "description": String, // e.g. Buzz Aldron on the moon ....
  "keywords": [String], // e.g. ["APOLLO 11 FLIGHT"]
  "media_type": MediaType, // e.g. "image"
  "nasa_id": String, // e.g. as11-40-5874
  "title": String, // e.g. Apollo 11 Mission image - Astronaut Edwin Aldrin
}

Item {
    "data": [Data], // data about the image
    "href": URI<MediaManifest>, // Related images e.g. https://images-assets.nasa.gov/image/as11-40-5874/collection.json
    "links": [Link], // thumbnail
}

Metadata {
  total_hits: Int, // e.g. 336
}

Collection<T> {
  "href": URL, // e.g. https://images-api.nasa.gov/search?q=apollo%2011...
  "items": [T],
  "links": [Link<Collection<T>>],
  "metadata": Metadata,
  "version": "1.0",
}

Response<T> {
    "collection": Collection<T>
}

```


## Architecture


The application uses standard Model-View-Controller architecture for the purpose of displaying information to the user, and receiving commands from the user.
Various other components are used for other purposes, such as retrieving, converting and displaying data.
The available categories and their roles is described under the subheadings below.

Files in the project are grouped by their corresponding role, so that existing files can located more easily, and new files can be placed in a predictable location.
Groups are organised roughly in order of abstraction level, from highest abstraction level first (e.g. builders), to lower abstraction levels last (web services).
Newcomers to the code base are encouraged to read the code in order that the groups are listed, as this will start with a broad overview (seeing the forest), followed by progressively finer details (the trees).

The design goals of the system are maintainability and testability. 
Maintainability in this context means that code can be added, removed, and changed without causing unexpected side effects.
Side effects caused by changing code should be isolated to the module being worked on.
Testability means that code should be able to be exercised in isolation in a unit test.
The test case should only need to instantiate the direct dependencies of the object in order to test it.
Gven these goals, an emergent property of resulting code is that it is highly modular (consisting of isolated components) and flexible (components can be changed without affecting the system).
A potential drawback to the design is that it exhibits greater complexity compared to a less regorous approach. 


### App

The app group contains the `AppDelegate` and `SceneDelegate`, which serve as the entry point to the app.
The `SceneDelegate` (or `AppDelegate`, depending on the configuration), uses a builder to construct the initial view controller, which it then presents.


### Builders

Builders serve the purpose of creating objects used by the application, usually by composing multiple general-purpose objects to serve a specific purpose.
In this design, builders create components that are specific to the needs of the application - that is to say, they cannot generally be used interchangeably in other applications.
When the structure of the application needs to change, the change is usually made in a builder, by reconfiguring or replacing an existing component.
When a new type of feature needs to be implemented, a new builder is also implemented to provide that feature to the application.


### Coordinators

Coordinators are used by view models to perform navigation actions. 
Usually the flow is as follows:

- The user performs an action, such as tapping on a button, or entering some text into a field.
- The view calls a method on a view model.
- The view model performs some processing, then delegates the action to the coordinator.
- The coordinator uses a builder to instantiate a view controller, then presents the view controller using the appropriate method.

Coordinators usually holds a weak reference to the view controller that will present the new view controller.
An example is where a coordinator holds a reference to a `UINavigationController` which it uses to push a view controller onto a navigation stack, such as the `PhotoCoordinator`.

Benefits of decoupling the navigation action from the view, view controller, and view model, include:

- Flexibility in changing the navigation method when the need of the app change, without changing any of the related view classes.
- Removing dependencies between view components - i.e. the view controller that is performing the navigation to another view controller is not affected when the second view controller needs to change.
- Improved testability - by allowing the coordinator to be replaced with a mock, a test can ensure that a navigation action would be performed, without needing to set up or inspect a live navigation stack.


### Theme

The theme is global service locator that provides resources commonly used views, such as fonts, colours, icons, margins, and other user interface resources defined by the design guide.
The intended purpose is be able to customise all standard attributes of the user interface from a single resource, with the eventual aim of defining the customisable attributes using a data file, so that individual custom apps can be created relatively easily by changing the file.  
Currently the theme only provides the fonts used by the user interface. 


### Views

Views are native or custom UIKit objects that display the interface to the user, and receive input from the user.
Views should be and reusable in any context and independent of the rest of the system.
Views should only implement logic necessary to render the user interface, and should not contain any process, validation, or business logic.
When building a user interface for a design system, custom view components should be created for each of the available user interface elements defined by the design system.


### View Controllers

View controllers facilitate communications between views that render onto the screen, and view models that provide information to be displayed.
View Controllers observe a view model, and update their view or viewss when the view model changes.
View Controllers observe their views, and invoke actions on the models when the views provide output.
View Controllers facilitate state transitions by applying a state defined by a model to a view, and by applying actions initiated by user interation to the view model.
Complex user interfaces should be created by composing several simpler view controllers, instead of using fewer, larger view controllers.


### Formatters

Formatters are simple objects that serve the purpose of converting data into human readable information. 
They usually perform lossly conversion from a well defined data type, into a string, or other easily representable information.
An example of a formatter is the `PhotoDescriptionFormatter`, which combines the name of a photographer, and a date, into a single piece of text that is displayed on the list of photos, and the photo detail screen. 


### View Models

View models define the state of information that should be displayed on the screen. 
A view model usually uses an underlying domain model that provides the raw data, which the view model converts into a form that can be presented to a user.
View models also act on inputs from the user interface, such as by processing information internally, or delegating the action to a coordinator.
An example is the `ListViewModel` which models a collection of items displayed in a list.


### Models

Models serve as the responsible source of data used by the application.
While the same piece of data may be represented in multiple places and take on different forms in the application, the original source of the data is contained by a model.
Models are carefully designed to represent all of the necessary aspects of a particular domain, without ambiguity or redundancy.
Models may exist independently of the system, or may be use other models, or components such as repositories or services directly.
Models often convert entities from repositories that match external interfaces, into internal domain specific representations, using a transformation method or closure.
An example is the  `PagedCollectionModel` that fetches successive batches of data from a paginated resource, and provides the aggregate of all batches to the application. 


### Entities

Entities are simple structures that only provide data, and limited or no functionality. 
They are used to represent as accurately as possible, data that is provided by external systems, such as a web interface or database.
They are designed be serializable to a file using a standardised encoding scheme, such as JSON, Property List, or Message Pack, amongst others.
In this project, entities model the data returned by the NASA images API.
When interfacing with other web services, other entities should be defined that match the 
As such, a good approach to organisation would be to place the entities in a separate framework which can serve as a namespace to prevent entities from different domains with similar names from clashing.
An example of an entity is the `CollectionEntity` which represents a collection of items received from a paginated web service. In this case, a page of images returned by the NASA images API. 


### Repositories

Repositories provide a well defined interface to the application to access type-safe data from an external system. 
A typical use case is providing data from a web service, file, or database.
Data provided by a repository is decoded into an object (called an Entity) that closely matches the external representation.
An example of a repository is the `CollectionRepository`, which is used for fetching a single batch of data from a paginated endpoint, or in this case, a page consisting of 100 images out of the approximately 6000 available images. 


### Services

Services provide generic or general purpose interfaces to external systems.  
An example is the `CodableHTTPGetService` that retrieves Decodable objects from an HTTP endpoint using the GET method.


### Mocks

Mocks serve the purpose of replacing a concrete object, with one where the behaviour is predefined to produce a specific side-effect.
Mocks are most often used in testing, to replace dependencies, so that the behaviour of the subject can be analysed in isolation without external side effects.
They can also be used during development, to stand in for objects or systems that do not exist yet, or to control application behaviour to simulate specific conditions.
An example is the `MockCursor`, which can be used to emulate a cursor with specific behaviours.


### Helpers

Helpers are general classes and extensions that don't belong in any specific category.
In this project, helpers are defined as extensions on Foundation and UIKit classes, and used to remove or reduce boilerplate or other commonly reoccuring code.


## Components


The below components were defined in the original design documentation, and are kept here to illustrate the thought process that went into the design. 
Some of the initial concepts have evolved in the current code, with the most notable exception being that of the Photos view controller, model, and repository, which was later changed to the more general purpose List view controller, model, and repository. 


### PhotoTableViewCell

Displays information for a photo in a list. 
- Thumbnail image view
- Title label
- Photographer label
- Date label


### PhotosViewController

Displays photos in a list.

- Displays a TableView with a list of PhotoTableViewCells. 
- Observes PhotosViewModel. 
- Updates the list of photos when the PhotosViewModel publishes a new list of photos.
- Uses PhotosSnapshotTransformer to convert the list of photos to a NSDiffableDataSourceSnapshot.
- Displays an error alert when the PhotosViewModel publishes an error.
- Refreshes the PhotosViewModel when the user taps the Retry button on the error alert. 
- Refreshes the PhotosViewModel when the user pulls down on the view to refresh
- Selects an item on the PhotosViewModel when the user taps a list item.


### PhotosViewModel

Provides a set of photos for display.

- Conforms to Combine Publisher. 
- Publishes a list of PhotoViewModels.
- Observes a PhotosModel and outputs a new set of photos when the model changes.
- Reloads the model when refreshed.
- Delegates to the PhotosCoordinator when an item is selected.


### PhotosDetailCoordinator

Navigates to the PhotoDetailViewController.


### PhotosModel

Provides the set of photos displayed by the application.


### PhotosRepository

Provides photos from the NASA images API.

- Keeps a reference to the page of photos that will be returned by the request. 
- Retrieves a subset of the available photos using the CodableGetService.
- Provides cursors for retrieving the next and previous PhotosRepository in the collection.


### CodableGetService

Abstract interface for services that return objects conforming to the Decodable protocol.
Concrete classes implement specific networking or file operations, and data conversion.
Implemented by CodableHTTPGetService.


### CodableHTTPGetService

Retrieves objects conforming to the Decodable protocol, from a resources that uses a an HTTP interface.

- Takes the base URL to the remote HTTP resource and URL Session in the initializer.
- Constructs the request URL by appending the provided path and query parameters to the base URL.
- Returns the deserialized object of the given type when the call succeeds, or returns an error when the call fails.

