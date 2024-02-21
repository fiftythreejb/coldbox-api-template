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
				var event = this.post(
					route  = "/api/login",
					params = {username : "admin@coldbox.org", password : "admin"}
				);
				var response = event.getPrivateValue("Response");
				var repData = response.getData();
				setAuthToken(repData.access_token);
				debug(getAuthToken());
			});

			beforeAll(function(currentSpec){
				
			});

			it("index", function(){
                // Execute event or route via GET http method. Spice up accordingly
				var event = get(event = "modTemplate:modTemplate.index", params = {});
				var response = event.getPrivateValue( "Response" );
				var repData = response.getData();
				// expectations go here.
				expect(response.getError()).toBeFalse( response.getMessages().toString());
				expect(response.getStatusCode()).toBe(200);
			});

			it("create", function(){
				// $assert.skip('A create event in an integration test should not create records that can impact the system, Ensure you clean up an test data.');
				variables.newRecordValue = 'New Record';
				var event = post(
					event = "modTemplate:modTemplate.create", 
					params = {'title': variables.newRecordValue, 'x-auth-token': getAuthToken()}
				);
				var response = event.getPrivateValue("Response");
				var repData = response.getData();
				variables.newRecordId = repData.id;
				expect(response.getError()).toBeFalse(response.getMessages().toString());
				expect(response.getStatusCode()).toBe(200, 'Invalid request response: #response.getStatusCode()#');
				expect(repData.title).toBe(variables.newRecordValue, 'Invalid title');
			});

			it("show", function(){
                // Execute event or route via GET http method. Spice up accordingly
				var event = get(event = "modTemplate:modTemplate.show", params = {id = variables.newRecordId});
				var response = event.getPrivateValue("Response");
				var repData = response.getData();

				expect(response.getError()).toBeFalse(response.getMessages().toString());
				expect(response.getStatusCode()).toBe(200, 'Invalid request response: #response.getStatusCode()#');
				expect(repData.title).toBe(variables.newRecordValue, 'Invalid title');
			});

			it("update", function(){
				// $assert.skip('An update event in an integration test should not modify records that can impact the system. If you are using the create test, you can modify the test data here.');
				var event = post(
					event = "modTemplate:modTemplate.update", 
					params = {id = variables.newRecordId, title = variables.newRecordValue}
				);
				var response = event.getPrivateValue("Response");
				var repData = response.getData();

				expect(response.getError()).toBeFalse(response.getMessages().toString());
				expect(response.getStatusCode()).toBe(200, 'Invalid request response: #response.getStatusCode()#');
			});

			it("delete", function(){
				$assert.skip('If you are using the create test, you can clean up an test data here.');
                // Execute event or route via GET http method. Spice up accordingly
				var event = get(event = "modTemplate:modTemplate.delete", params = {id = variables.newRecordId});
				var response = event.getPrivateValue("Response");
				var repData = response.getData();

				expect(response.getError()).toBeFalse(response.getMessages().toString());
				expect(response.getStatusCode()).toBe(200, 'Invalid request response: #response.getStatusCode()#');
			});


		});

	}

}
