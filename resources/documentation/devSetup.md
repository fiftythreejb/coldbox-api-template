# Dev Setup

- [Dev Setup](#dev-setup)
  - [CommandBox](#commandbox)
    - [Set up VS Code integration](#set-up-vs-code-integration)
  - [Local Development](#local-development)
  - [Running Endpoints](#running-endpoints)
    - [Re Init the App](#re-init-the-app)
    - [Manually Running the Endpoints](#manually-running-the-endpoints)
    - [Running in Postman](#running-in-postman)

## CommandBox

1. Download CommandBox (executable)
    1. [https://www.ortussolutions.com/products/commandbox#download](https://www.ortussolutions.com/products/commandbox#download)
    2. Download the correct version that includes the JRE. *[(You can
        use a JRE already available on your system but is more
        complicated)]*
2. Unzip the file and place the resulting folder in a location that is
    easily accessible. Likely you user directory.
3. You can run the CLI by double clicking the executable. This will set
    it up for the first time.
    1. You may be prompted to allow the application to run

### Set up VS Code integration

(**optional** *strongly recommended*)

> [!WARNING]
> I had problems setting this up, This may not work. In that case you may use a vscode plugin calles [Project Manager](https://marketplace.visualstudio.com/items?itemName=alefragnani.project-manager). It may be labled as deprecated, it still works.

[https://code.visualstudio.com/docs/terminal/profiles](https://code.visualstudio.com/docs/terminal/profiles)

[https://commandbox.ortusbooks.com/ide-integrations/visual-studio-code](https://commandbox.ortusbooks.com/ide-integrations/visual-studio-code)

1. Open VS Code and click the Gear Icon in the bottom tight corner to
    open settings
2. Ensure that you are editing user settings by selecting the `User`
    tab in the top right corner
3. Open the JSON edit view by selecting the page icon in the upper
    right corner
4. Find (or create if it doesn't exist) the structure for windows
    profiles.
5. Add the details for your box.exe file
6. Once you close and reopen VS Code, you should see the option in the
    list of available terminals.

## Local Development

1. Clone the repository @
    [https://bitbucket.org/\...](https://bitbucket.org/...)
2. Copy the `.env.example`
    1. rename to `.env`
    2. Ensure variables are filled out and ensure the `ENVIRONMENT` variable is set to `development`
3. Open command box via the built-in terminal or launch the CommandBox executable.
4. Make sure the terminal is at the root of your project
5. type `install` then enter to install ColdBox and its dependencies
6. type `start` then enter to run the server that is configured for this project.
7. This will start a Lucee server and place an icon in your system  tray. It will also open a web browser window at the root of the app.
8. Changes made to the code will be reflected in the running server.
    1. Coldbox uses caching for many components so you may need to re-init the app for many changes.

## Running Endpoints

### Re Init the App

With ColdBox caching, you may need to re-init the app to view code
changes. the fastest method is to use a URL variable.

  ----
  > for any URL, you can append a `?fwreinit` to the end of the URL to run the re-init
  ----
  > [!NOTE]
  >**Note:** In production, we will include a re-init password which will look like this `?fwreinit=initPassword`
  ----

### Manually Running the Endpoints

You can hit any unsecured GET endpoint by navigating to its route. `http://localhost:{portNumber}/api/echo/`

  ----
  > [!NOTE]
  > For Non GET requests, you will pass a \_**method** URL parameter `localhost:{portNumber}/api/login?_method=post`
  ----

For secured endpoints you will need to run the login endpoint and pass in the auth-token.

1. Run the login endpoint (as a POST request) and pass URL variables for userName and Password
    1. `localhost:{portNumber}/api/login?_method=post&username=user@domain.com&password=myPasswordIsWeak`
    2. copy the `access_token` from the data structure
    3. You will pass in the token as a URL variable with your supplemental requests `http://127.0.0.1:62558/api/whoami?x-auth-token=eyJ0eXAiOiJKV1QiL...`

  ----
  > [!NOTE]
  > Note that re-initing will wipe out your session and you will need to re-login
  ----

### Running in Postman

There is a postman collection in the root resources folder of the project in a folder called `_postman`. Import that into Postman and login can be handled automatically for each request.

In the collection folder, you will enter your username and password into the variables section as well as the specific url you will be hitting.

If your authentication has been manually expired (EX: from a re-init) you can run the login endpoint.
