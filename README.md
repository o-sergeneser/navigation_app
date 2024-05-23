# An Efficient Navigation App in Flutter with Google Maps and Routes APIs

This project demonstrates how to build a robust and efficient navigation app in Flutter using Google Maps and Routes APIs. It covers integrating Google Maps, obtaining routes, checking if the user is on the route, handling location permissions, opening system location settings, efficiently processing location data, and handling app lifecycle events.

## Features

- **Google Maps Integration:** Display maps within your Flutter app.
- **Route Calculation:** Obtain routes between two points using Google Maps Routes API, and efficiently process the existing route before making a new route request.
- **Location Tracking:** Track the user's location in real-time.
- **Permission Handling:** Request and handle location permissions.
- **System Location Settings:** Open system location settings if the location service is turned off.
- **App Lifecycle Handling:** Properly manage app lifecycle events to ensure smooth operation.

## Dependencies

This project uses the following dependencies:

- `google_maps_flutter`
- `google_maps_routes`
- `maps_toolkit`
- `permission_handler`
- `android_intent_plus`
- `geolocator`

## Getting Started

To get started with this project, follow these steps:

1. Clone the repository:
    ```bash
    git clone https://github.com/o-sergeneser/navigation_app.git
    ```
2. Navigate to the project directory:
    ```bash
    cd navigation_app
    ```
3. Install the dependencies:
    ```bash
    flutter pub get
    ```
4. Replace the "YOUR_API_KEY" text in the following files with your own API key:
    - `constants.dart`
    - `AppDelegate.swift`
    - `AndroidManifest.xml`

## Documentation

For detailed instructions and explanations, check out the article on Medium: ["An Efficient Navigation App in Flutter with Google Maps and Routes APIs"]([https://medium.com/benim-makalem](https://medium.com/@oguzhansergeneser/building-an-efficient-navigation-app-in-flutter-with-google-maps-and-routes-apis-bfb7bf49f1cf))

## Emulator Setup

To obtain the example route shown in the Medium article, set your location to coordinates 48.146703, 11.580179 and the destination to 48.151080, 11.578953 in your emulator to simulate the route.

## Contributing

Feel free to fork this project, submit issues and pull requests. Any contributions are greatly appreciated!
