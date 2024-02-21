/**
 * This service provides user authentication, retrieval and much more.
 * Implements the CBSecurity IUserService: https://coldbox-security.ortusbooks.com/usage/authentication-services#iuserservice
 */
component accessors="true" singleton {

	/**
	 * --------------------------------------------------------------------------
	 * DI
	 * --------------------------------------------------------------------------
	 */

	property name="populator" inject="wirebox:populator";
	property name="people" inject="peopleService@people";
	property name="pepper" inject="coldbox:configSettings:pepper";
	property name='log' inject='logbox:logger:{this}';

	/**
	 * --------------------------------------------------------------------------
	 * Properties
	 * --------------------------------------------------------------------------
	 */

	/**
	 * Constructor
	 */
	function init(){
		return this;
	}

	/**
	 * Construct a new user object via WireBox Providers
	 */
	User function new() provider="User"{
	}

	/**
	 * Verify if the incoming username/password are valid credentials.
	 *
	 * @username The username
	 * @password The password
	 */
	boolean function isValidCredentials( required username, required password ){
		var oTarget = retrieveUserByUsername( arguments.username );

		if ( !oTarget.isLoaded() ) {
			return false;
		}

		return arguments.username == oTarget.getUsername() && arguments.password == oTarget.getPassword();
		// return oTarget.getPas sword().compareNoCase(people.simpleHash(password = arguments.password, salt = oTarget.getSalt())) == 0;
	}

	/**
	 * Retrieve a user by username
	 *
	 * @return User that implements JWTSubject and/or IAuthUser
	 */
	function retrieveUserByUsername( required username ){
		var person = people.loadByEmail(email = arguments.username);
		var user = new();
			user.setId(person.getId());
			user.setFirstName(person.getFirstName());
			user.setLastName(person.getLastName());
			user.setUsername(person.getEmail());
			user.setSalt(person.getSalt());
			user.setPassword(person.getPasswordHash());
		return user;
	}

	/**
	 * Retrieve a user by unique identifier
	 *
	 * @id The unique identifier
	 *
	 * @return User that implements JWTSubject and/or IAuthUser
	 */
	User function retrieveUserById( required id ){
		var person = people.loadById(id = arguments.id);
		var user = new();
			user.setId(person.getId());
			user.setFirstName(person.getFirstName());
			user.setLastName(person.getLastName());
			user.setUsername(person.getEmail());
			user.setPassword(person.getPasswordHash());
			user.setSalt(person.getSalt());
		return user;
	}

}
