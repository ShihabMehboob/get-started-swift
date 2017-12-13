[![Build Status - Master](https://travis-ci.org/IBM-Cloud/get-started-swift.svg?branch=master)](https://travis-ci.org/IBM-Cloud/get-started-swift)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)

# Getting started with Swift on IBM Cloud
To get started, we'll take you through a sample *Getting Started* application that takes only few minutes to deploy.

In order to deploy to IBM Cloud, you'll need an [IBM Cloud account](https://console.ng.bluemix.net/registration/). Once registered, you can automatically deploy the app with toolchain integration using our deploy to IBM Cloud button.

[![Deploy to IBM Cloud](https://bluemix.net/deploy/button.png)](https://bluemix.net/deploy?repository=https://github.com/IBM-Cloud/get-started-swift&branch=master)

To run locally and deploy from the command line, follow the instructions below. The project's required tools are listed in the [Prerequisites](#prerequisites) section. If needed, you can follow the links to download them.

## Prerequisites

* [Git](https://git-scm.com/downloads)
* [IBM Cloud CLI](https://console.bluemix.net/docs/cli/reference/bluemix_cli/all_versions.html#bluemix-cli-installer-downloads)
* [Swift 4.0.2 or newer](https://swift.org/download/) for your platform

## 1. Clone the sample app

Now that you're ready to start working with the simple Swift app, let's clone the repository and change to the directory to where the sample app is located.

```
$ git clone https://github.com/IBM-Cloud/get-started-swift

...

$ cd get-started-swift
```

Peruse the files in the *get-started-swift* directory to familiarize yourself with the contents.

## 2. Run the app locally

Once you have installed the Swift compiler and cloned this Git repository, you can now compile and run the application. Go to the root folder of this repository on your system and issue the following command:

```shell
$ swift build
```

This command might take a few minutes to run.

Once the application is successfully compiled, you can run the executable that was generated by the Swift compiler:
```
$ ./.build/x86_64-apple-macosx10.10/debug/get-started-swift
```

You should see an output similar to the following:

```
Server is listening on port: 8080
```

You can then view your app at: http://localhost:8080.

## 3. Prepare the app for deployment

To deploy to IBM Cloud, it can be helpful to set up a `manifest.yml` file. One is provided for you with the sample. Take a moment to look at it.

The `manifest.yml` file includes basic information about your app, such as the name, how much memory to allocate for each instance, and the route. In this `manifest.yml` **random-route: true** generates a random route for your app to prevent your route from colliding with others. You can replace **random-route: true** with **host: myChosenHostName**, supplying a host name of your choice. [Learn more...](https://console.bluemix.net/docs/manageapps/depapps.html#appmanifest)

```
 applications:
 - name: Get-Started-Swift
   random-route: true
   memory: 256M
```

## 4. Deploy the app

You can use the IBM Cloud CLI to deploy apps.

First, choose your API endpoint:

```
$ bx api <API-endpoint>
```

Replace the *API-endpoint* in the command with an API endpoint from the following list.

|URL                             |Region          |
|:-------------------------------|:---------------|
| https://api.ng.bluemix.net     | US South       |
| https://api.eu-de.bluemix.net  | Germany        |
| https://api.eu-gb.bluemix.net  | United Kingdom |
| https://api.au-syd.bluemix.net | Sydney         |

Login to your IBM Cloud account:

```
$ bx login
```

From within the *get-started-swift* directory push your app to IBM Cloud:

```
$ bx app push
```

This can take a minute. If there is an error in the deployment process you can use the command `bx app logs <Your-App-Name> --recent` to troubleshoot.

When deployment completes you should see a message indicating that your app is running.  View your app at the URL listed in the output of the push command.  You can also issue the `bx app list` command to view your apps status and see the URL.

## 5. Add a database

Next, we'll add a Cloudant NoSQL database to this application and set up the application so that it can run locally and on IBM Cloud.

1. Log in to IBM Cloud in your Browser. Browse to the `Dashboard`. Select your application by clicking on its name in the `Name` column.
2. Click on `Connections` then `Connect new`.
3. In the `Data & Analytics` section, select `Cloudant NoSQL DB` and name it `cloudant`.
4. Select a pricing plan. IBM Cloud offers free `Lite` plans for a select collection of its cloud services with enough capacity to get you started.
5. Once created, navigate to the `Connections` link on the left pane, find `cloudant` and select `Connect` to bind your application to the database.
6. Select `Restage` when prompted. IBM Cloud will restart your application and provide the database credentials to your application using the `VCAP_SERVICES` environment variable. This environment variable is only available to the application when it is running on IBM Cloud.

Environment variables enable you to separate deployment settings from your source code. For example, instead of hardcoding a database password, you can store this in an environment variable which you reference in your source code.

## 6. Use the database

We're now going to update your local code to point to this database. Create a JSON file that will store the credentials for the services the application will use. This file will be used *only* when the application is running locally. When running in IBM Cloud, the credentials will be read from the VCAP_SERVICES environment variable.

1. Create a file called `my-cloudant-credentials.json` in the `config` directory with the following content (as reference, see `config/my-cloudant-credentials.json.example`):

 ```
 {
   "password": "<password>",
   "url": "<url>",
   "username": "<username>"
 }
 ```
Update the `mappings.json` file in the `config` directory by replacing the `cloudant` placeholder with the **name** that was assigned to your Cloudant instance:
```
{
  "MyCloudantDB": {
    "searchPatterns": [
      "cloudfoundry:cloudant",
      "env:kube-cloudant-credentials",
      "file:config/my-cloudant-credentials.json"
    ]
  }
}
```
This sample application uses the `CloudEnvironment` package to interact with IBM Cloud to parse environment variables to obtain the necessary service credentials. [Learn more...](https://packagecatalog.com/package/IBM-Swift/CloudEnvironment)

2. Back in the IBM Cloud UI, select your App -> Connections -> Cloudant -> View Credentials.

3. Copy and paste just the credential values to the corresponding fields in your `my-cloudant-credentials.json` file.

4. Run your application locally.

```
$ swift build

...

$ ./.build/x86_64-apple-macosx10.10/debug/get-started-swift
```

View your app at: http://localhost:8080. Any names you enter into the app will now get added to the database.

This sample application uses the `Kitura-CouchDB` package to interact with Cloudant. [Learn more...](https://packagecatalog.com/package/IBM-Swift/Kitura-CouchDB)

5. Make any changes you want and re-deploy to IBM Cloud!

```
$ bx app push
```

View your app at the URL listed in the output of the push command, for example, *myUrl.mybluemix.net*.
