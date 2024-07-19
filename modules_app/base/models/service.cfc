
component displayname="base.service" accessors="true" {

	property name="cacheFactory" inject="cacheBox";
	property name="entityName" default="";
	property name="modelCache";

	public function init() {
		setEntityName(getMetaData(this).displayname);
		setCacheFactory(application.cbController.getCachebox());

		if (!getCacheFactory().cacheExists(getEntityName())) {
			getCacheFactory().addDefaultCache(getEntityName());
		}
		setModelCache(getCacheFactory().getCache(getEntityName())); 
		
		return this;
	}

	/**
	 * I return a populated bean with the details of a specific record
	 *
	 * @referenceBean any						 The bean (by reference)
	 *
	 */
	public void function load(required any referenceBean) {
		getDao().read(argumentCollection = arguments);
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

	
	private any function setCachedData(
		any required dataObj, 
		struct dataArguments = {},
		boolean clearCache = false,
		string cacheTime = '60'
	) {
		// set the cache item name
		var cacheItemName = hash( serializeJson( arguments.dataArguments ), 'MD5', 'UTF-8' );

		// check if we're not clearing the cache
		if( !arguments.clearCache ) {
			// we aren't, get the query from the cache
			var cachedData = getModelCache().get( cacheItemName );

			// check if we have this query cached
			if( !isNull( cachedData ) ) {
				// we do, return the cached query
				return cachedData;
			}
		}

		// we don't have a cached query or aren't using cache, get the data from the dao
		getModelCache().set(
			cacheItemName,
			arguments.dataObj,
			arguments.cacheTime
		);
		
		// return the query from the dao
		return arguments.dataObj;
	}

}