/**
 * I manage modTemplate
 */
component singleton accessors="true" extends="base.models.service" displayname="ModTemplateService"{

	// Properties
	property name="dao" lazy; // coldbox lazy load of dao

/************************
	PUBLIC
************************/

	/**
	 * Constructor
	 * I return an ModTemplate bean
	 *
	 * @return modTemplate.models.ModTemplateService instance
	 */
	public modTemplate.models.ModTemplateService function init(){
		super.init();

		if( isNull( getModelCache() ) ) {
			setModelCache( new base.models.cache( entity = "modTemplateCache" ) );
		}
		return this;
	}

	/**
	 * I return an ModTemplate bean
	 *
	 * @return modTemplate.models.ModTemplateBean
	 */
	public modTemplate.models.ModTemplateBean function getBean() {
		return new modTemplate.models.ModTemplateBean();
	}

	/**
	 * list records
   	 * I run a filtered query of all records within the [table name] table in the database
   	 *
	 * @returnColumns string	(optional) A list of the columns
	 * @exchangeId numeric		(optional) Identity of the table record 
	 *
	 * @return query
	 */
	public query function filter(
		string returnColumns = "list, of, columns",
		boolean cache = true,
		boolean clearCache = false,
		string cacheTime = '60',
		numeric id,
		date createdOn,
		date updatedOn,
		boolean isActive,
		string groupBy,
		string orderBy,
		boolean pagination = false,
		numeric start,
		numeric length
	) {
		// check if we're caching the query
		if( arguments.cache ) {
			// duplicate the arguments
			var args = duplicate( arguments );

			// remove cache arguments from duplicate
			structDelete( args, 'cache' );
			structDelete( args, 'clearCache' );
			structDelete( args, 'cacheTime' );

			// set the cache item name
			var cacheItemName = hash( serializeJson( args ), 'MD5', 'UTF-8' );

			// check if we're not clearing the cache
			if( !arguments.clearCache ) {
				// we aren't, get the query from the cache
				var cachedQuery = getModelCache().get( cacheItemName );
				// check if we have this query cached
				if( !isNull( cachedQuery ) ) {
					// we do, return the cached query
					return cachedQuery;
				}
			}
		}

		// we don't have a cached query or aren't using cache, get the data from the dao
		var cachedQuery = getDao().filter( argumentCollection = arguments );

		// check if we're caching this query
		if( arguments.cache ) {
			// we are, set this query into the cache
			getModelCache().set(
				objectKey = cacheItemName,
				object = cachedQuery,
				timeout = arguments.cacheTime
			);
		}

		// return the query from the dao
		return cachedQuery;
	}

	/**
	 * I return an ModTemplate by ID
	 * @id numeric ?: The value for id
	 *
	 * @return modTemplate.models.ModTemplateBean
	 */
	public modTemplate.models.ModTemplateBean function loadById(required numeric id) {
		var bean = getBean();
		bean.setId(arguments.id);
		load(bean);
		return bean;
	}


/****************
	Private
****************/
	/**
	 * Build a Dao object lazyily, by convention.
	 * The first time you call it, it will lock, build it, and store it by convention as 'variables.dao'
	 */
	private function buildDao(){
		return new modTemplate.models.ModTemplateDao();
	}

}