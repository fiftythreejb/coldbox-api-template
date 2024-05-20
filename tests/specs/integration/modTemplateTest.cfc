/**
 * 	ColdBox Integration Test
 *
 * 	The 'appMapping' points by default to the '/root ' mapping created in  the test folder Application.cfc.  Please note that this
 * 	Application.cfc must mimic the real one in your root, including ORM  settings if needed.
 *
 *	The 'execute()' method is used to execute a ColdBox event, with the  following arguments
 *	- event : the name of the event
 *	- private : if the event is private or not
 *	- prePostExempt : if the event needs to be exempt of pre post interceptors
 *	- eventArguments : The struct of args to pass to the event
 *	- renderResults : Render back the results of the event
 *
 * You can also use the HTTP executables: get(), post(), put(), path(), delete(), request()
 **/
component extends="coldbox.system.testing.BaseTestCase" accessors="true" autowire appMapping="/"{

	property name="authToken" type="string" default="";

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		variables.newRecordId = 0;
		variables.newRecordValue = '';
		// do your own stuff here
	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){

		describe("modTemplate Suite", function(){

			beforeEach(function( currentSpec ){
				// Setup as a new ColdBox request for this suite, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			});

			beforeAll(function(currentSpec){
				getRequestContext().$reset();
			});

			it("Can authenticate", function(){
				if (getAuthToken().len()) {
					$assert.skip('Authentication not needed');
				}
				// Execute event or route via POST http method.
				var event = post(route  = "/api/login", params = {username : "admin@coldbox.org", password : "admin"});
				// Get the response data to test
				var response = event.getPrivateValue("Response");
				var repData = response.getData();

				// expectations go here.
				expect(response.getStatusCode()).toBe(200, response.getMessages().toString());
				expect(response.getError()).toBeFalse(response.getMessages().toString());
				expect(repData.len()).toBeGT(1);

				// set token for future requests
				setAuthToken(repData.access_token);
			});

			it("Run index: list items", function(){
                // Execute event or route via GET http method. Spice up accordingly
				var event = get(event = "modTemplate:modTemplate.index", params = {});
				var response = event.getPrivateValue( "Response" );
				var repData = response.getData();
				// expectations go here.
				expect(response.getStatusCode()).toBe(200, response.getMessages().toString());
				expect(response.getError()).toBeFalse(response.getMessages().toString());
			});

			it("Run create: insert record", function(){
				// $assert.skip('A create event in an integration test should not create records that can impact the system, Ensure you clean up an test data.');
				runAuth();
				variables.newRecordValue = 'New Record';
				var event = post(
					event = "modTemplate:modTemplate.create", 
					params = {'title': variables.newRecordValue, 'x-auth-token': getAuthToken()}
				);
				var response = event.getPrivateValue("Response");
				var repData = response.getData();
				variables.newRecordId = repData.id;
				expect(response.getStatusCode()).toBe(200, 'Invalid request response: #response.getStatusCode()#');
				expect(response.getError()).toBeFalse(response.getMessages().toString());
				expect(repData.title).toBe(variables.newRecordValue, 'Invalid title');
			});

			it("show", function(){
                // Execute event or route via GET http method. Spice up accordingly
				runAuth();
				
				var event = get(event = "modTemplate:modTemplate.show", params = {id = variables.newRecordId, 'x-auth-token': getAuthToken()});
				var response = event.getPrivateValue("Response");
				var repData = response.getData();

				expect(response.getStatusCode()).toBe(200, 'Invalid request response: #response.getStatusCode()#');
				expect(response.getError()).toBeFalse(response.getMessages().toString());
				expect(repData.title).toBe(variables.newRecordValue, 'Invalid title');
			});

			it("update", function(){
				// $assert.skip('An update event in an integration test should not modify records that can impact the system. If you are using the create test, you can modify the test data here.');
				runAuth();
				var event = post(
					event = "modTemplate:modTemplate.update", 
					params = {id = variables.newRecordId, title = variables.newRecordValue, 'x-auth-token': getAuthToken()}
				);
				var response = event.getPrivateValue("Response");
				var repData = response.getData();

				expect(response.getStatusCode()).toBe(200, 'Invalid request response: #response.getStatusCode()#');
				expect(response.getError()).toBeFalse(response.getMessages().toString());
			});

			it("delete", function(){
				$assert.skip('If you are using the create test, you can clean up an test data here.');
				runAuth();
                // Execute event or route via GET http method. Spice up accordingly
				var event = get(event = "modTemplate:modTemplate.delete", params = {id = variables.newRecordId, 'x-auth-token': getAuthToken()});
				var response = event.getPrivateValue("Response");
				var repData = response.getData();

				expect(response.getStatusCode()).toBe(200, 'Invalid request response: #response.getStatusCode()#');
				expect(response.getError()).toBeFalse(response.getMessages().toString());
			});


		});
	}

	private void function runAuth() {
		if (getAuthToken().len()) {
			debug('exists');
			return;
		}
		var event = post(
			route  = "/api/login",
			params = {username : "admin@coldbox.org", password : "admin"}
		);
		var response = event.getPrivateValue("Response");

		if (response.getError() == true) {
			debug(response);
			throw(response.getMessages().toString());
		}
		
		var repData = response.getData();
		setAuthToken(repData.access_token);
		debug(getAuthToken());
	} 

}
