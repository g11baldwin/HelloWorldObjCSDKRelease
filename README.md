# <b>Hello World</b> - playPORTAL Objective-C SDK</b></br>

#### The following instructions will guide you through setting up & running the included "Hello World" app.

##### The playPORTAL Objective-C SDK currently supports the following APIs:
* Login
* Profile

## Getting Started

* ### <b>Step 1:</b> Create playPORTAL Partner Account

	* Navigate to [playPORTAL Partner Dashboard](https://partner.iokids.net)
	* Click on <b>Sign Up For Developer Account</b>
	* After creating your account, email us at [info@playportal.io](mailto:info@playportal.io?subject=Developer%20Sandbox%20Access%20Request) to verify your account.
  </br>

* ### <b>Step 2:</b> Add an App

	* After confirmation, log in to the [playPORTAL Partner Dashboard](https://partner.iokids.net)
	* In the left navigation bar click on the <b>Apps</b> tab.
	* In the <b>Apps</b> panel, click on the "+ Add App" button.
	* Add an icon
	* Add a name
		* App names must be unique.
		* Use some variation of "HelloWorld" (i.e. - "HelloWorld123" )
	* Add a description
	* For "Environment" leave "Sandbox" selected.
	* Click "Add App"
  </br>

* ### <b>Step 3:</b> Generate your Client ID and Client Secret

	* Tap "Client IDs & Secrets"
	* Tap "Generate Client ID"
	* You will use these values in the HelloWorld App later.
  </br>

* ### <b>Step 4:</b> Add Redirect URI

	* A custom URL scheme (helloworld://redirect) has already been set up in the included XCode Project.
	* From the [playPORTAL Partner Dashboard](https://partner.iokids.net) navigate to your app
	* Click <b>Registered Redirect URIs</b>
	* Enter <b>helloworld://redirect</b> as a "Registered Redirect URI"
  </br>

* ### <b>Step 5:</b> Generate "Sandbox" Users
	* In the left navigation pane of the [playPORTAL Partner Dashboard](https://partner.iokids.net) click on "Sandbox".
	* In the "Users" section, click the "Generate" button.
	* In the dropdown menu select either "Parent" or "Adult" for the type of user to generate.
	* The generated user will have a "handle" prefixed by "@" and their generated password will be shown.


* ### <b>Step 6:</b> Run the HelloWorld App
	* Clone or Download this repo.
	* Open the HelloWorld.xcodeproj
	* Add your <b>ClientID & ClientSecret</b> in the "AppDelegate.m" file at the following lines:

	```
	NSString *clientId = @"<YOUR CLIENTID HERE>";
	NSString *clientSecret = @"<YOUR CLIENT SECRET HERE>";
	```

* ### <b>Step 7:</b> Log In with "Sandbox" User
	* Tap on the "Log In With playPORTAL" button.
	* In the Safari page that appears, enter your "Sandbox" user's username & password.
		* Username is the second value under the profile picture and is prefixed by "@"
