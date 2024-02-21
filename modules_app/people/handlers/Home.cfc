/**
 * The main module handler
 */
component extends="coldbox.system.RestHandler" accessors="true" {

	property name="investors" inject="investorsService@investors";

	/**
	 * Module EntryPoint
	 */
	function index( event, rc, prc ) secured {
		event.getResponse().setData('Investor Profile');
	}

}
