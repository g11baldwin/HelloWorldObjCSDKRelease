# <b>playPORTAL Objective-C SDK</b></br>
playPORTAL <sup>TM</sup> provides a service to app developers for managing users of all ages and the data associated with the app and the app users, while providing compliance with required COPPA laws and guidelines.


## Getting Started

* ### <b>Step 1:</b> Create playPORTAL Partner Account

	* Navigate to [playPORTAL Partner Dashboard](https://partner.iokids.net)
	* Click on <b>Sign Up For Developer Account</b>
	* After creating your account, email us at [info@playportal.io](mailto:info@playportal.io?subject=Developer%20Sandbox%20Access%20Request) to verify your account.
  </br>

* ### <b>Step 2:</b> Register your App with playPORTAL

	* After confirmation, log in to the [playPORTAL Partner Dashboard](https://partner.iokids.net)
	* In the left navigation bar click on the <b>Apps</b> tab.
	* In the <b>Apps</b> panel, click on the "+ Add App" button.
	* Add an icon, name & description for your app.
	* For "Environment" leave "Sandbox" selected.
	* Click "Add App"
  </br>

* ### <b>Step 3:</b> Generate your Client ID and Client Secret

	* Tap "Client IDs & Secrets"
	* Tap "Generate Client ID"
	* Copy these and save them to a secure place accessible by your app. Be careful not to share them or store them in public version control - they uniquely identify your app and grant the permissions to your app as defined in the [playPORTAL Partner Dashboard](https://partner.iokids.net).
  </br>

* ### <b>Step 4:</b> Add your Redirect URI

	* Add a [Custom URL Scheme for your app](https://developer.apple.com/documentation/uikit/core_app/communicating_with_other_apps_using_custom_urls?language=objc)
	* From the [playPORTAL Partner Dashboard](https://partner.iokids.net) navigate to your app and tap <b>Registered Redirect URIs</b>
	* Enter the your Custom URL Scheme
  </br>

* ### <b>Step 5:</b> Install the SDK
	* Unzip the PlayPortalSDKObjC.zip file and drag all three folders in to the top level of your XCode project.
	* Be sure to check "Copy Items If Needed"

---
## Configure
* Be sure to import the PPManager anywhere you call the SDK.
	```
	#import "PPManager.h"
	```
* Make your clientID, clientSecret & redirectURI available to your app
* Call the configure method in AppDelegate.m as folows:
	```
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

		[[PPManager sharedInstance] configure:clientID secret:clientSecret andRedirectURI:redirectURI];

		return YES;
	}
	```
---
## Login
* Implement the following function in AppDelegate.m
	```
	- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {

		[[PPManager sharedInstance] handleOpenURL:url];

		return YES;

	}
	```
* Implement the following method and provide a callback to receive a user once the login flow is completed:
	```
	[PPManager sharedInstance].PPusersvc.addUserListener = ^(NSDictionary *user, NSError *error){
		if (error) {

			NSLog(@"%@ error: %@", NSStringFromSelector(_cmd), error);

		} else {

			// When user is returned you can parse keys and values here
			for(id key in user) {
				NSLog(@"key=%@ value=%@", key, [user objectForKey:key]);
			}

		}
	};
	```
* Call the following method to allow a user to log in:
	```
	[[PPManager sharedInstance].PPusersvc login];
	```
---
## Storage
* Coming soon!
