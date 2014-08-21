Vagabound
===========

Description: Travel a lot? Take lots of photos? Get them organized during or after your trip, and see on a map where you have been! Remember trips you have taken by using this iOS journal. Organize your photos by the places you have visited. Add photo memories to your trips.

Features:
* Create a trip, places on that trip and memories at each place and set the title and description of each.
* Take a photo using the camera or select one from your Photo Roll.
* Dates and geolocation are automatically loaded when a photo is selected or taken.
* If the photo doesn't contain geolocation data, the location can be set.
* Set the trip and place cover photo and geolocation on their maps by finding the memory with the desired photo and setting it as the desired cover photo.
* Share to connected social networks.
* Provide feedback by pressing "Talk to us!" on the home screen. Email us, connect with us on Facebook and don't forget to rate and review Vagabound!

Tech Talk:
Custom objects for trips, places and memories.
Objects are saved via SQLite.
Photos are referenced from the Photo Roll using ALAsset Library. Image metadata is used to provide location and date if available.
Google Analytics is used to anonymously track usage.
MKMapview is used for displaying locations in collection header views and for selecting the location of a memory. Map markers are custom icons.
