# Architecture

## What is HMVC

**Reference Summary:**\
[https://coldbox.ortusbooks.com/readme/what-is-mvc](https://coldbox.ortusbooks.com/readme/what-is-mvc){card-appearance="inline"}

The HMVC pattern cleanly separates code into logical pieces to separate
business logic, data layer, and presentation code. This allows easier
maintenance, testing, debugging and feature development as well as
improve code reuse. Each feature set can be divided into standalone
modules that can be called by convention to integrate into other
modules.

### Convention

The ColdBox framework is built to wire up modules and functionality
based on where you put each of these pieces. This reduces the need for
boilerplate code to get your modules up and running.

### Hierarchical, Model, View, Controller

- hierarchical - you can nest your code modules inside one another

- model - this contains your business logic, cfScript components that
    define logic, data layer and manipulation of the data-layer.

- view - this is you UI layer generally built primarily with HTML and
    some CFML for dynamic pieces and variables.

- controller - this CF component is generally referred to as a
    handler. Define the presentation needs for each route of the module.
    This ushers the data into the form needed for the view.

### Our MVC Layout & Examples

The application modules are located (by convention) in the
`moldules_app` folder. Your module will be contained in a folder with
the name of your module (our module template module pictured - right).

#### **Module Structure:**

- A config file is placed at the root of this folder called
    MuduleConfig.cfc. This file sets up the options for your module
    allowing it to be registered to the framework on application start.
- Config - config files like routes.
  - Routes will define the paths of your application. By default,
        ColdBox creates default routes based on your module and handler
        by convention.
    - Default: base-URL/moduleName/handlerName/handlerMethodName
- Handlers - Controller files: methods(actions) that will be executed
    as to serve the visual representation of your route.
  - The action will process will intake any variables needed from
        the request and application and format it for the view that it
        calls
  - Views will be called by convention (module is implied /
        modulesViewsFolder / handlerName handlerActionName.cfm) and can
        be overridden
  - In our case, we don\'t use to many views. We let the framework
        auto format and output our data into a response JSON object.
- Views - .cfm files containing mostly HTML and some CFML to display
    the needed UI.
- Models - this folder contains our data layer, data object, and
    services.
  - We have set up some base models that we extend to reduce
        boilerplate code.
    - Bean (optional) - an object that can be used to provide state and behavior for a data object.
      - We have built out several methods that are extended from the base bean
    - DAO - our data layer that provides access to external datasources.
      - This includes several CRUD methods extended from base service.
      - Interfaces with the modules bean as needed
    - Service - Contains the business logic for the application and manipulates the data.
      - This includes may CRUD methods from the extended base service.
      - interfaces with the DAO and bean

#### Examples

##### Module Service

Extends the base service and uses WireBox injection to lazy load the
DAO. Gets the related module bean and connects to the DAO to get lists,
a populated bean, and access to CRUD operations.

##### Module DAO

Extends the base DAO and provides CRUD operations for the data source.
This interacts with the bean to provide the populated data object.

##### Module Bean

(optional) Extends the base bean to provide the specific properties for
the related data model. The base bean provides the base methods for
population, getting the memento and hashing. Used to add methods
required for the related data model.

## Caching

[https://wirebox.ortusbooks.com/getting-started/getting-jiggy-wit-it/scoping#scope-annotations](https://wirebox.ortusbooks.com/getting-started/getting-jiggy-wit-it/scoping#scope-annotations){card-appearance="inline"}

Coldbox caches files based on the `singleton` methodology. Components
with the singleton attribute will be cached based on the policy set in
the ColdBox config file. We also have caching enabled for data as needed
though the extended base service.

## Injection

[https://wirebox.ortusbooks.com/getting-started/overview#dependency-injection-explained](https://wirebox.ortusbooks.com/getting-started/overview#dependency-injection-explained){card-appearance="inline"}

the built in Wirebox module provides an injection methodology to call
components and services throughout the app.

## CommandBox

**Reference Summary:**
[https://commandbox.ortusbooks.com/overview](https://commandbox.ortusbooks.com/overview){card-appearance="inline"}

Similar to NPM, Grunt/Gulp, Maven, Bower, and Node, CommandBox is a
standalone, native Command Line Interface (CLI), Package Manager,
Embedded CFML Server and and more, built to improve CFML development,
productivity, enhance automation, provide dependency management, and
command line-based tools.

### Our Primary Uses

- Runs our CFML engine inside of our docker container
- manages our ColdBox packages - Installs, updates, dependencies
- Can be used for scaffolding apps and modules
- Starting up a local server to test the app

#### To start a local dev server

1. Install the modular CommandBox executable in a central location on your system
2. Pull the repository from Bitbucket
3. copy the `env.example` file and customize any settings
4. Run CommandBox by either
    1. opening a terminal instance and navigating to the root of your
        project and run the executable using the full path of the
        box.exe file
    2. run the box.exe file and navigate to the rood of your project
5. type `start` and enter to spin up the cf server that is already
    configured in the `.cfconfig.json` file.

#### Create a ColdBox Module

1. `coldbox create module <moduleName>` This will create the basics
    needed to begin a module.
2. Can also copy the `ModTemplate `folder and update the names and settings.
