#Ofsted Reports App#

Ofsted Reports is an iOS App that lets users look for schools in England based on a location set by the user. Users can then filter schools based on the teaching phase (Primary, Secondary, Others) and latest review by Ofsted (Outstanding, Good, etc). 
Details about the latest Ofsted report are available within the app, as well as a direct link to the official report.

Note: Ofsted is part of the English Government and reviews schools educational performance in England.

##Video Preview##
Link: https://youtu.be/pLwh2X_ANXs

##Installation##
Download as .zip file or clone the repository to your computer using git; then open the workspace with XCode on a Mac. 
The app can be run in the simulator or on a iPhone or iPad device.

##Usage##
The app is structured in 4 main views:

1. WelcomeViewController

2. MapViewController (embedded in a NavigationController)

3. SettingsViewController

4. SchoolDetailsViewController


The functions of each view is detailed here below:

**1. WelcomeViewController**

The top part of the screen allows user to start a new search in 3 different ways: using the user's current location, using a postcode, or using a selected location on the map.
Tapping _'Near Me'_ will request the user to authorize the app to localize the phone on the map.
Tapping _'Post Code'_ will allow the user to type in a text field the postcode of his/her desired location.
Tapping _'Location'_ will display a map, with an instruction for the user to do a long-press on the map to select a location.

The _'Radius'_ area of the screen will define the size of the area in which the app will display schools. The values are minimum 100 meters, and maximum 4000 meters. A circle will be drawn on the map around the user location or the dropped pin (if there is one yet). The circle will be updated whenever the search radius value is updated.

The _'New Search'_ buttun will initiate a new search and access the network. All outlets on the screen should be frozen while the app connects to the API and fetches data. The view will unfreeze once the app is done fetching information from the network. If successful, a segue to the mapViewController will be executed. If unsuccessful, an error message will be displayed in an alerViewController.

The _'Previous Searches'_ buttun will make the whole view move up, and a table with previous searches will be displayed. The cell will display the description of the search, along with the radius used for that particular search. If the search was based on a postcode, the postcode is displayed on the left of the cell. If a GPS coordinate was used for the search, a geocoded string description of the place is displayed.

Swiping from right to left on a cell will give the option for the user to delete the search. Schools associated with the search will be deleted as well from CoreData.

Tapping on a cell will load the search associated with that cell, and a segue to the MapViewController is executed.

The values of the outlets on this view are set with standard values on app launch. However, if the user is coming back to this view from the MapViewController, the outlet values are set to what they were when the user left the screen. These values are kept in an dictionary stored in NSUserDefaults. This dictionary is emptied from NSUserDefaults whenever the app relaunches (in AppDelegate).

**2. MapViewController (embedded in a NavigationController)**

A map occupies the entire space below the navigationBar.

The navigationBar has a button on the left that, if pressed, takes the user back to the WelcomeScreen to do a new search. There is a button on the right called 'Filters' which will take the user to the SettingsViewController. The title of the navigation bar shows the number of schools displayed on the map just below.

The map shows the location of schools that returned from the search selected on the WelcomeScreen, and also that match the userPreferences set in the Settings ViewController (more on this below). Each school is represented by a pin. The map automatically adjusts its region based on the pins. 

When a pin is tapped, the name of the school and a details are shown in the pin annotation.

From this view, a user can do 2 things now:
- Press the Filter button: this will show the settingsViewController.
- Press the details icon on a pin annotation: this will show the schoolDetailsViewController.

**3. SettingsViewController**

On the first launch, all filters are set to 'Yes'. The user can simply tap on each cell to toggle the line's criteria to 'No'.

Once the user is done, the user can navigate back to the map using the button on the left of the navigation bar. The schools shown on that map will now match the filters set by the user.

It is important to know that these filter settings are kept in memomry in NSUserDefaults, and will be applied for future searches. They can be adjusted again in the same way later on.

**4. SchoolDetailsViewController**

This view shows basic information about the schools educational performance as measured by Ofsted, and button at the bottom of the view allows users to navigate to the official Ofsted report for the school.

The left buttun in the navigation controllers allows users to navigate back to the map.
