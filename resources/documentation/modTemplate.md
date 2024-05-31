# ModTemplate

There is a module template in the `modules_app` folder called `modTemplate`. You can duplicate this file and make sure it is placed in the `modules_app` folder.

You will need to rename files folders and code to setup your new module.

All places where “**modTemplate**” text is will be replaced with the name of your module.

The Setup and use of models in the below examples is not necessary.

You may use other model setups as long as they return data and you can avoid adding lots of business logic in the handler.

## ModuleConfig.cfc

Replace all instances of **“modTemplate**” with the name of your module. This tells coldbox how to refer to your module for injection and routing.

### Config Details

- this.title

  - This is the name of your module and can be listed in several utilities such as the `/endpoints` tool that you can use in development.

  - For example: [http://127.0.0.1:53844/endpoints](http://127.0.0.1:53844/endpoints)

- These are used when defining a module for package repositories like forgeBox.io

  - this.author

  - this.webURL

  - this.description

  - this.version

- this.viewParentLookup

  - This tells coldbox if you want to traverse up the tree when looking for module views.

  - First it will look in the current module view folder, then in the parent module view folder (if it is a nested module) then in the view folder in root of the application.

  - 1\. current module

  - 2\. parent module (if nested - will continue for all layers)

  - 3\. root views folder

- this.layoutParentLookup

  - This follows the same pattern as above for views

- this.entryPoint

  - Entry point refers to the routing for the module. When navigating the URL, your module path will begin with this route.

  - It is good practice to keep this the same name as the namespace and mapping

  - EX: `localhost/ap1/modTemplate`

  - Note: we have prefixed `api` which is not required. We use api as a way to separate api modules from non api modules. If we choose to have an endpoint return html or we have a documentation endpoint we don't want to confuse those with api endpoints.

- this.inheritEntryPoint

  - If your module is nested, the entry point from the parent can be used

- this.modelNamespace

  - This is how ColdBox refers to your module when injecting and referencing cfcs in code.

  - It is good practice to keep this the same name as the entrypoint and mapping

- this.cfmapping

  - This is how ColdBox refers to your module when injecting and referencing cfcs in code.

  - It is good practice to keep this the same name as the entrypoint and namespace

- this.autoMapModels

  - This will map any cfc in your models sub folder to your module for injection.

  - EX: `property name="modTemplateService" inject="modTemplateService@modTemplate";`

- this.dependencies

  - This is an array of any module dependencies that will be loaded from the related package repository upon installing/building.

## Handlers

The handler will serve your endpoints. Each function relates to the served endpoint. This should not contain business logic, mainly connect and transform data to what is needed for the endpoint. This should also contain error handling for the request.

### Renaming

Make sure to rename the modules handler to a relevant name for your module. ColdBox usually defaults to `main.cfc` and our modules are usually named after the module name.

Ensure you insect and update any model names correctly.

Your dependency injections should look be updated

- From `property name="modTemplateService" inject="modTemplateService@modTemplate";`

- To `property name="myModuleNameService" inject="myModuleNameService@myModuleName";`

Replace all calls to the service variable

- From `modTemplateService`

- To `myModuleNameService`

You will also need to update your setters, getters and argument calls to reflect the needs from your service. See models below.

### Templated Endpoints

There are some basic CRUD (Create, Read, Update, Delete) endpoints templated for you. You will need to update the calls to match the data and models you are using in your module.

By convention, These are mapped by the built in rest handler to existing endpoints for security.

[https://coldbox.ortusbooks.com/digging-deeper/rest-handler](https://coldbox.ortusbooks.com/digging-deeper/rest-handler)

The Rest endpoints that match up with a mapped name will be restricted to the related HTTP method when being called. When you call `localhost\myModule\my endpoint` it will only accept requests with the related http method.

Ex: `localhost\myModule\myHandler\create` will require a post call, or it will throw the appropriate error.

```CFML
// Default REST Security for ColdBox Resources
this.allowedMethods = {
	"index" : "GET",
	"new" : "GET",
	"get" : "GET",
	"create" : "POST",
	"show" : "GET",
	"list" : "GET",
	"edit" : "GET",
	"update" : "POST,PUT,PATCH",
	"delete" : "DELETE"
};
```

## Models

We have some model templates for easy object oriented separation of concerns. These are not necessary to use but are strongly encouraged for good code organization.

### Rename

Replace Model file names to reflect the correct data being manipulated. In our case we are usually using the module name and postfix with the model type.

- `ModTemplateBean.cfc` => `ModuleNameBean.cfc`

- `ModTemplateDao.cfc` => `ModuleNameDao.cfc`

- `ModTemplateService.cfc` => `ModuleNameService.cfc`

Rename all declarations in the model code to replace `modTemplate` with `myModuleName`.

Ensure you use PascalCase for model names and camelCase for variable names.

Example:

- `modTemplate.models.ModTemplateService` => `myModuleName.models.MyModuleNameService`

- `modTemplateCache` => `myModuleNameCache`

### Structure

We have a suggested object structure with 3 main pieces that are extended from base classes. This will give us a quick way to import your needed queries into these models and have objects set to feed your endpoints.

The simplest use of these is to setup a set of modules per table/data source or set of tables. We can also modify these to serve many tables are data sources.

#### Bean

This extends the base bean and will primarily contain properties that relate to table column names.

This will hold our object data and house methods for manipulating or transforming that data in simple ways. The base bean contains basic methods:

- getting primary key

- get memento

- get memento as json

- populate bean from data struct

- get meta data

- hashing and getting primary key

#### Dao

This is our data layer. An interface for a data source table or set of API endpoints. This will make our SQL calls or calls to external API endpoints and format the data for our service to serve to our handler endpoint.

This template has place holder methods you can customize and use as examples for your CRUD operations. They are outlines and samples of database calls that can be modified to target the needed tables. Many of these receive a bean object and manipulate it by reference. (This will modify the passed in object directly and not require the function to return anything.)

The base DAO will inject our data source struct so we can use the data source keys to access the needed databases.

```CFML
getDsn().documents

// the datasource structure is in the coldbox config
settings = {
	datasource: {
		'documents': 'documents',
		'apps': 'apps',
		'webspace': 'webspace'
	}
}
```

> [!NOTE]
>**Note:** This can be setup to use test or dev databases depending on environment.

##### Included methods

- create
  - add a record to a table from a bean object
- read
  - Receives a bean with the primary key set and reads the related record to populate the bean.
- update
  - Updates a record from the data in the referenced bean.
- filter
  - This is a query builder that can take any column(s) in the table and filter by it.
- exists
  - uses the reference bean to check the database and return if it can find the related record.

#### Service

This is the orchestrator for the Bean and DAO. The handler will interface with the service to get the needed data. Your business logic can be placed in the service.

The base service that this will extend provides the basic interface needed for interacting with the DAO.

- injection
  - builds the cache object for the service
  - gets the property to hold the cachebox instance
- load
  - this will load data into the passed in bean from the DAO read method
- remove
  - This will delete the record related to the passed in bean
- save
  - This will either update or insert the data based on the passed in bean
- setCachedData
  - This will cache the data called from the data source based on the arguments passed and time period specified. 60 minutes is the default.

Our template service includes additional methods that can be used to interface with your DAO.

- getBean
  - Get an instance our the bean used for our data layer
- filter
  - accesses the filter method from our DAO
- loadById
  - Reads data into a bean by only passing in a primary key value.

## Router

[https://coldbox.ortusbooks.com/the-basics/routing](https://coldbox.ortusbooks.com/the-basics/routing)

In the modules config folder is our router. This creates our modules endpoints. This is already setup to serve all of the handlers routes by convention.

You will replace the `modTemplate` handler with the one you specified as your module handler name. Rename all declarations in the router code to replace `modTemplate` with `myModuleName`.

- `patch("/").to("modTemplate.update");` => `patch("/").to("myModuleHandler.update");`
- `get(pattern = "/", target = "modTemplate.index");` => `get(pattern = "/", target = "myModuleHandler.index");`
- `route(pattern="/:action").toHandler("modTemplate");` => `route(pattern="/:action").toHandler("myModuleHandler");`

## Route configuration

[https://coldbox.ortusbooks.com/the-basics/routing/routing-dsl](https://coldbox.ortusbooks.com/the-basics/routing/routing-dsl)

The code used to set a route is a function called `route(pattern='')`. This will take a pattern and use the built in module route to serve methods from your router.

The routes will create routes in a precedence based on their order in this file. There are shortcut methods that will be wrappers for the route() method which restrict the endpoint to be served only to certain http method requests.

### Custom Specified Routes

Ideally, we will only provide custom routes in production to avoid exposing unneeded routes.

- `patch("/").to("modTemplate.update");`
  - If the URL is `localhost/api/modTemplate/` with a HTTP **PATCH** method, the `update` function in the `handlers/modTemplate.cfc` file will be returned.
- `get(pattern = "/", target = "modTemplate.index");`
  - If the URL is `localhost/api/modTemplate/` with a HTTP **GET** method, the **index** function in the `handlers/modTemplate.cfc` file will be returned.

If any other method is used, an error will be thrown as no route is set up for the base `localhost/api/modTemplate/` route.

- if you would like a catch all route for the base route you could use the below
  - `route(pattern = "/", target = "modTemplate.index");`
    - this will accept any HTTP method

### Convention Based Routes

These will allow any method in the handler to be used. ColdBox gives us 2 useful variables.

`:handler` is the handler name, `:action` is the handler action name.

- `route(pattern="/:action").toHandler("modTemplate");`
  - If the URL is `localhost/api/modTemplate/anyHandlerActionName`, the **handler action** function that matches the `:action` variable that exists in the `handlers/modTemplate.cfc` file will be returned.
- `route( "/:handler/:action?").end();`
  - If the URL is `localhost/api/modTemplate/myHandlerName/anyHandlerActionName`
    - the handler that matches (`myHandlerName`) to a file in the `modTemplate/handlers` folder will be used
    - the action (`anyHandlerActionName`) that matches a function in the above handler will be called
