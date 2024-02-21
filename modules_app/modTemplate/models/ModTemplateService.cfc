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
		numeric length
	) {

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
	 */
	private function buildDao(){
		return new modTemplate.models.ModTemplateDao();
	}

}