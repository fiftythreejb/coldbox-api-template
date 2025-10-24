/**
 * I manage modTemplate
 */
component singleton accessors="true" extends="base.models.service" displayname="ModTemplateService"{

	// Properties
	// property name="dao" lazy; // coldbox lazy load of dao
	property name="dao" inject="ModTemplateDao@modTemplate";
	property name="defaultCacheTime" type="string" default="60"; // 1hours	

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
		numeric id,
		date createdOn,
		date updatedOn,
		boolean isActive,
		string groupBy,
		string orderBy,
		boolean pagination = false,
		numeric start,
		numeric length,
		boolean cache = false,
		boolean clearCache = false,
		string cacheTime = '60'
	) {
		if( arguments.cache ) {
			// duplicate the arguments
			var args = duplicate( arguments );

			// remove cache arguments from duplicate
			structDelete( args, 'cache' );
			structDelete( args, 'clearCache' );
			structDelete( args, 'cacheTime' );
			// handlew pagination after cache
			structDelete( args, 'pagination' );
			structDelete( args, 'start' );
			structDelete( args, 'length' );
			structDelete( args, 'page' );

			var returnData = setCachedData(
				dataObj = getDao().filter, 
				dataArguments = args,
				clearCache = arguments.clearCache,
				cacheTime = arguments.cacheTime
			);

			var lengthResult = arguments.length;
			var resultStart = arguments.start;
			var getRowCount = returnData.recordCount;
			if (arguments.pagination && getRowCount > lengthResult) {
				returnData = returnData.filter(function(row, current) {
					return current >= resultStart && current <= resultStart + (lengthResult-1);
				});
			}
			
			if (!isDefined('returnData.result_count')) {
				returnData.addColumn("result_count", "numeric", [getRowCount]);
			}

			return returnData;
		}
		return getDao().filter(argumentCollection = arguments);
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
		private function buildDao(){
			return new modTemplate.models.ModTemplateDao();
		}
	 */

}