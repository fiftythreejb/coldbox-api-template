component extends="coldbox.system.testing.BaseTestCase" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		variables.people = prepareMock(getInstance('people.models.peopleService'));
	}
	
	function afterAll(){
		super.afterAll();
	}
	
	/*********************************** BDD SUITES ***********************************/
	
	function run(){
		describe( "UserService", function(){
			beforeEach( function( currentSpec ){
				setup();
				model = getInstance( "UserService" );
				prepareMock(model);

			} );

			it( "can be created", function(){
				expect( model ).toBeComponent();
			} );

			it( "can get a valid mock user by id", function(){
				var oUser = model.retrieveUserById( 1 );
				expect( oUser.getId() ).toBe(999999);
				expect( oUser.isLoaded() ).toBeTrue();
			} );

			it( "can get a new mock user with invalid id", function(){								
				people.$(method = 'loadById', returns = people.getBean());				
				model.$property(propertyName = 'people', mock = people);
				
				var oUser = model.retrieveUserById( 100 );
				expect( oUser.getId() ).toBe( "" );
				expect( oUser.isLoaded() ).toBeFalse();
			} );

			it( "can get a valid mock user by username", function(){
				var investObj = people.getBean().setId(1);
				people.$(method = 'loadByEmail', returns = investObj);				
				model.$property(propertyName = 'people', mock = people);

				var oUser = model.retrieveUserByUsername("admin");
				expect( oUser.getId() ).toBe( 1 );
				expect( oUser.isLoaded() ).toBeTrue();
			} );

			it( "can get a new mock user with invalid username", function(){
				people.$(method = 'loadByEmail', returns = people.getBean());	
				var oUser = model.retrieveUserByUsername( "bogus@admin" );
				expect( oUser.getId() ).toBe( "" );
				expect( oUser.isLoaded() ).toBeFalse();
			} );

			it( "can validate valid credentials", function(){
				var investObj = people.getBean()
					.setPasswordHash('admin')
					.setId(1)
					.setEmail('admin@coldbox.org');
				people.$(method = 'simpleHash', returns = 'admin');				
				people.$(method = 'loadByEmail', returns = investObj);				
				model.$property(propertyName = 'people', mock = people);

				// debug(model.retrieveUserByUsername('admin'));

				var result = model.isValidCredentials("admin@coldbox.org", "admin");
				expect( result ).toBeTrue();
			} );

			it( "can validate invalid credentials", function(){
				people.$(method = 'loadByEmail', returns = people.getBean());	
				var result = model.isValidCredentials( "badadmin", "dd" );
				expect( result ).toBeFalse();
			} );
		} );
	}

}
