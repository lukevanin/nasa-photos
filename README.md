# NASA Photos Browser

Displays photos from NASA's images API. This is a small educational example that 
demonstrates some useful concepts:

- Basic Model-View-Controller architecture
- UI and Unit testing
- Separation of concerns: user interface, domain, and networking 
- Using Codable objects
- Building reactive applications using Combine Publisher


TODO: Document use of recieve completion instead of using assign.
TODO: Document cursor design.
TODO: Document entities.


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

Display a higher resolution  version of the photo with the title, photographer, date, and description.


### Photo Viewer Screen ###

Tap on the larger photo to display the original photo in the photo viewer. 
Double tap to toggle between scaling the photo to fit the screen, and scaling the photo to its original dimensions. 
Drag to pan the photo.
Pinch to zoom the photo. 
The photo cannot be resized so that its width is smaller than the width of the screen, or larger than the original dimensions. Where the original size is smaller than the screen width, the size is constrained to the screen width.


## API ##

Endpoint: from https://images-api.nasa.gov/search?q=%22%22
Document: https://images.nasa.gov/docs/images.nasa.gov_api_docs.pdf
Search results use Collection+JSON format: https://github.com/collection-json/spec

Data types:
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
    "data": [Data], // data about the 
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

The application uses standard Model-View-Controller architecture to communicate updates from models to the views, and inputs from the views to models.
Additional components such as Coordinators, Repositories, and Services are used to facilitate the views, models, and controllers

Views are native or custom UIKit objects that display the user interface, and receive input from the user.
Views send output to view controllers using a target-action, delegate, or closure.
Views should be and reusable in any context and independent of the rest of the system,
In principle, views should only implement logic necessary to render the user interface, and should not contain any business logic.
The implementation of the View changes when its visual appearance needs to change.

View Controllers observe one or more models, and update their views when the models change.
View Controllers observe their views, and invoke actions on the models when the views provide output.
View Controllers facilitate state transitions by applying a state defined by a model to a view, and by applying actions initiated by user interation to the model.
The implementation of a View Controller needs to change when a user interface element is added, changed, or removed. 
View Controllers can be composed to create complex user interfaces. 

Models provide the information used by the application, and recieve actions initiated by events such as notifications and user interaction.
Models may exist independently of the system, or may be composed of other Models, Repositories, Services, or other components.
Models are generally implemented as, or composed of, Combine Publishers. 
Models are generally categorized into Domain Models and View Models.

View Models provide information in a format that is directly usable for displaying in views. 
For example, numbers and dates are formatted as strings, and text is localized.
View Models are generally used by View Controllers to provide state for the view. 
View Models receive inputs from the user through the view controller.
The general principle is to model the entire view state as atomic units. 
That is, View Models should provide a full description of what the view should display, instead of providing changes or mutations to views. 
The benefits of modelling view state atomically include: 
- Reduced cognitive load: View state can be reasoned about holistically, without needing to execute a series of mutations mentally. 
- Thread safety: State can be passed as immutable types.
- Testability: Entire state can be checked in a single equality expression.
View Models may delegate responsibilities to other components, such as delegating navigation to a Coordinator.
View Models generally receive information from, and send information to, an underlying Domain Model which owns the information.
A View Model should model a single view of a user interface, such as a button or table. 
View Models may maintain state, but they do not own the information.
If the underlying representation of the information changes, the View Model should update to reflect that change. 
The implementation of the View Model needs to change when the underlying Domain Model changes.

Domain Models implement business logic and act as the source of truth within an application.
A Domain Model owns a defined subset of the information used by the application.
Domain Models may communicate with external resources through Services or Repositories.
Domain Models may internally transform data received by external APIs to a consistent form used internally by the application.

Services and Repositories serve as interfaces for communicating between the application and external systems.
They are similar in that they both provide an interface that closely resembles the external interface.
They are different in that a Repository provides a collection of data (ie a list of things), whereas a Service provides an interface for performing operations on the data.
For example, Repository might provide a list of data received from a backend server.
The data would be provided by a Service, by calling the specific method for fetching the data.

Data Transfer Objects are used by Services and Repositories to serialize and deserialize content to and from a data format.

[TODO] Discuss using Redux.

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

