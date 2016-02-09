# TwitterTrov

This is a demo app to demonstrate how a twitter client might work without accessing the twitter API. There are inline comments to describe
what I was thinking or trying to do as well as concerns with approaches used.

###Application Info
**XCode Version:** 7.2.1
**Language:** Swift 2.1
**Frameworks Used:** CoreData

###Application Structure
The application uses a CoreData back end to store off tweets and users. The database is abstracted from the UI in order to behave more like a web based application
In order to load data the UI will call the DataManager class which handles database interaction. This is not an approach I'd use in the real world,
depending on requirements for something like a twitter client I'd likely just call the API to get the most recent tweets and allow the user
to pull down to refresh. If offline mode was a requirement I might pull in tweets from the API and store them locally in CoreData for viewing.

An application manager is used to manage UI and life cycle related tasks. This is used to store the current username (assuming that login persistence
is needed since that's how Twitter and Facebook work) and have some convienence methods like displaying the login view and getting the top most view controller.

###Application Flow
At first launch the user will be required to create a user account from the login page. Upon account creation the new user will be logged in and their first tweet will be 
created automatically. New tweets can be added using the button in the upper right corner. The user can log out and switch users with the button in the upper left corner.
When the app is launched the tweet table view will check for an existing logged in user, if it's null it'll present the login view. When a user is logged in
the login screen will notify the tweet table via a delegate method that it needs to load data. The load data method is also called on viewDidLoad.

The load data method will get all tweets for the user. When tweets are added or when the user pulls down to refresh the table it will call a method
to get tweets since the last loaded tweet and insert them into the table. I think this meets the requirement of only loading new tweets on demand.
Typically when loading tables like this I've use an NSFetchResultController to fill the table from the database. Since it can observe changes it makes reloading
data easier than what I'm doing in this application. I wanted to pretend that the database was an external data source though as I said earlier.

Tweets are tied to users so each user will maintain it's own list of tweets.

###DataManager, Web Services and Threading
One of the questions asked was "If you were querying a real web service, is it guaranteed to respond immediately?". It won't, typically
this is dealt with using delegation or callbacks. The older NSURLRequest class could be called synchronously but it meant stalling the app
until the process was complete. Sometimes this is fine, you might want to block all operations until that call happens. There are much better
ways of doing things though. I've been using NSURLSession mostly as of late and it doesn't have a synchonous request (at least that I know of).
It uses delegation or blocks.

What this typically means is that you need to be able to have your app's UI handle the asynchonous response or prevent the user from taking
action during a call if you want the webservice call's result to be processed before continuing. In this project most of my DataManager calls are
synchronous and return immediately. I wanted to include an async example though so I made my login validation method asynchronous. The others
can be changed pretty easily following the same callback model.

###Unit Tests
I don't have any experience with writing or using unit tests. That being said, I took a crack at it. I have no idea if they are the best
way of doing them but they seem to work. I have unit tests for the main datalayer methods and a few UI tests for basic validation. At work
we work in an FDA environment where we are required to have strict documentation and testing so we've been doing manual tests.
