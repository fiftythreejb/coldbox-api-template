# Architecture

- [Architecture](#architecture)
	- [What is HMVC](#what-is-hmvc)
		- [Convention](#convention)
		- [Hierarchical, Model, View, Controller](#hierarchical-model-view-controller)
		- [Our MVC Layout \& Examples](#our-mvc-layout--examples)
			- [Module Structure](#module-structure)
			- [Examples](#examples)
				- [Module Service](#module-service)
				- [Module DAO](#module-dao)
				- [Module Bean](#module-bean)
	- [Caching](#caching)
	- [Injection](#injection)
	- [CommandBox](#commandbox)
		- [Our Primary Uses](#our-primary-uses)
			- [To start a local dev server](#to-start-a-local-dev-server)
				- [local server](#local-server)
				- [Docker](#docker)
			- [Create a ColdBox Module](#create-a-coldbox-module)
	- [Coldbox Details](#coldbox-details)
		- [Handlers](#handlers)
			- [Security](#security)

## What is HMVC

**Reference Summary:**\
[https://coldbox.ortusbooks.com/readme/what-is-mvc](https://coldbox.ortusbooks.com/readme/what-is-mvc)

The HMVC pattern cleanly separates code into logical pieces to separate business logic, data layer, and presentation code. This allows easier maintenance, testing, debugging and feature development as well as improve code reuse. Each feature set can be divided into standalone modules that can be called by convention to integrate into other modules.

### Convention

The ColdBox framework is built to wire up modules and functionality based on where you put each of these pieces. This reduces the need for boilerplate code to get your modules up and running.

### Hierarchical, Model, View, Controller

- hierarchical - you can nest your code modules inside one another
- model - this contains your business logic, cfScript components that define logic, data layer and manipulation of the data-layer.
- view - this is you UI layer generally built primarily with HTML and some CFML for dynamic pieces and variables.
- controller - this CF component is generally referred to as a handler. Define the presentation needs for each route of the module. This ushers the data into the form needed for the view.

### Our MVC Layout & Examples

The application modules are located (by convention) in the `moldules_app` folder. Your module will be contained in a folder with the name of your module.

#### Module Structure

- A config file is placed at the root of this folder called ModuleConfig.cfc. This file sets up the options for your module allowing it to be registered to the framework on application start.
- Config - configuration files, like routes.
  - Routes will define the paths of your application. By default, ColdBox creates default routes based on your and handler by convention.
    - Default: base-URL/moduleName/handlerName/handlerMethodName
- Handlers - Controller files: methods(actions) that will be executed to serve the visual representation of your route.
  - The action process will intake any variables needed from the request and application and format it for the view it calls
  - Views will be called by convention (moduleName is implied / modulesViewsFolder / handlerName -> handlerActionName.cfm) and can be overridden
  - In our case, we don't use views. We let the framework auto format and output our data into a response JSON object.
- Views - .cfm files containing mostly HTML and some CFML to display the needed UI.
- Models - this folder contains our data layer, data object, and services.
  - We have set up some base models that we extend to reduce boilerplate code.
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

Extends the base service and uses WireBox injection to lazy load the DAO. Gets the related module bean and connects to the DAO to get lists, a populated bean, and access to CRUD operations.

##### Module DAO

Extends the base DAO and provides CRUD operations for the data source. This interacts with the bean to provide the populated data object.

##### Module Bean

(optional) Extends the base bean to provide the specific properties for the related data model. The base bean provides the base methods for population, getting the memento and hashing. Used to add methods required for the related data model.

## Caching

[https://wirebox.ortusbooks.com/getting-started/getting-jiggy-wit-it/scoping#scope-annotations](https://wirebox.ortusbooks.com/getting-started/getting-jiggy-wit-it/scoping#scope-annotations)

Coldbox caches files based on the `singleton` methodology. Components with the singleton attribute will be cached based on the policy set in the ColdBox config file. We also have caching enabled for data as needed though the extended base service.

## Injection

[https://wirebox.ortusbooks.com/getting-started/overview#dependency-injection-explained](https://wirebox.ortusbooks.com/getting-started/overview#dependency-injection-explained)

the built in Wirebox module provides an injection methodology to call components and services throughout the app.

## CommandBox

**Reference Summary:**
[https://commandbox.ortusbooks.com/overview](https://commandbox.ortusbooks.com/overview)

Similar to NPM, Grunt/Gulp, Maven, Bower, and Node, CommandBox is a standalone, native Command Line Interface (CLI), Package Manager, Embedded CFML Server and and more, built to improve CFML development, productivity, enhance automation, provide dependency management, and command line-based tools.

### Our Primary Uses

- Runs our CFML engine inside of our docker container
- manages our ColdBox packages - Installs, updates, dependencies
- Can be used for scaffolding apps and modules
- Starting up a local server to test the app

#### To start a local dev server

##### local server

> [!WARNING]
> The env currently points at a local docker image of the database. Make sure you configure it to use the database you will be using.

1. Install the modular CommandBox executable in a central location on your system
2. Pull the repository from Bitbucket
3. copy the `env.example` file and customize any settings
4. Run CommandBox by either
    1. opening a terminal instance and navigating to the root of your project and run the executable using the full path of the box.exe file
    2. run the box.exe file and navigate to the root of your project
5. type `start` and enter to spin up the cf server that is already
    configured in the `.cfConfig.json` file.

##### Docker

  > [!WARNING]
  > ensure your docker image has access to the same network as your database. If your database is also in a container, you will need to configure them to use the same network.

1. Open a terminal in the root of the project
2. docker-compose up -d

#### Create a ColdBox Module

1. Can copy the `ModTemplate`folder and update the names and settings. (this will match our structure and templating)
2. `coldbox create module <moduleName>` This will create the basics needed to begin a module.

## Coldbox Details

### Handlers

#### Security

Our handlers are secured behind a login by adding a Security Annotation to your handler cfc declaration or individual handler actions.

[CB Security - Security Annotations](https://coldbox-security.ortusbooks.com/usage/security-annotations)

``` CFML
component accessors="true" extends="coldbox.system.RestHandler" secured {
	

/**
	 * This is a port of equities investment data
	 * 
	 * @title					?: equities titleEn
	 */
	function equitiesInvestmentGet( event, rc, prc ) secured {
````

This can be augmented by extending or implementing the [hasRole method in the IAuthUser service](https://coldbox-security.ortusbooks.com/usage/authentication-services#iauthuser).

