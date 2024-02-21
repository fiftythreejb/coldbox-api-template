
component displayname="base.service" singleton {

	public function init() {
		return this;
	}

	/**
	 * I return a populated bean with the details of a specific record
	 *
	 * @referenceBean any						 The bean (by reference)
	 *
	 */
	public void function load( required any referenceBean ) {

		getDao().read( argumentCollection = arguments );

	}

	/**
	 * I delete a record from the table in the database
	 *
	 * @referenceBean any						 The bean (by reference)
	 */
	public void function remove( required any referenceBean ) {

		getDao().delete( argumentCollection = arguments );

	}

	/**
	 * I save a record in the table in the database
	 *
	 * @referenceBean any     					 The bean (by reference)
	 * @forceInsert boolean                      ?: true/false skip of existence check and force insert (create)
	 * @forceUpdate boolean                      ?: true/false skip of existence check and force update
	 *
	 */
	public void function save(
		required any referenceBean,
		boolean forceInsert = false,
		boolean forceUpdate = false
	) {
		// check if we're forcing an update
		if( arguments.forceUpdate ) {
			// forcing an update
			getDao().update( arguments.referenceBean );
		}
		// check if we're forcing an insert OR this record *does not* exist
		if( arguments.forceInsert || !getDao().exists( arguments.referenceBean ) ) {
			// forcing an insert or does not exist, create the record
			getDao().create( arguments.referenceBean );
		} else {
			// it does exist, update the record
			getDao().update( arguments.referenceBean );
		}
	}

}