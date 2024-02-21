component singleton accessors="true" extends="base.models.dao" displayname="ModTemplateDao" {

	package modTemplate.models.ModTemplateDao function init() {
		return this;
	}

	/**
	 * I insert a new record into the [table name] table
	 *
	 * @referenceBean any     I am the ModTemplate bean pre-populated with the data to persist
	 *
	 */
	package void function create( required any referenceBean ) {

		// TODO: BEGIN TESTING - REMOVE WHEN UPDATING FROM TEMPLATE
		arguments.referenceBean.setId(9999999);
		arguments.referenceBean.setTitle('New Record');
		return;
		// END TESTING

		arguments.referenceBean.setId(
			queryExecute(
				"
					INSERT INTO modTemplate (
						id,
						createdOn,
						updatedOn,
						isActive
					)
					VALUES (
						:id,
						:createdOn,
						:updatedOn,
						:isActive
					);
					SELECT LAST_INSERT_ID() AS id;
				",
				{
					id   		= {cfsqltype="idstamp", value=arguments.referenceBean.getExchangeUid()},
					updatedOn	= {cfsqltype="timestamp", value=arguments.referenceBean.getCreatedOn()},
					createdOn	= {cfsqltype="timestamp", value=arguments.referenceBean.getUpdatedOn()},
					isActive	= {cfsqltype="bit", value=arguments.referenceBean.getIsActive()},
				},
				{
					datasource = getDsn()
				}
			).id
		);
	}

  /**
	 * I populate an ModTemplate bean with the details of a specific record
	 *
	 * @referenceBean any 		I am the ModTemplate bean pre-populated with the id to load
	 *
	 */
	package void function read( required any referenceBean ) {

		// TODO: BEGIN TESTING - REMOVE WHEN UPDATING FROM TEMPLATE
		arguments.referenceBean.setId(999999);
		arguments.referenceBean.setTitle('New Record');
		arguments.referenceBean.setCreatedOn(now());
		arguments.referenceBean.setUpdatedOn(now());
		arguments.referenceBean.setIsActive(1);
		return;
		// END TESTING
		
		// get the data by the integer id
		var result = queryExecute( "
			SELECT 
				id,
				createdOn,
				updatedOn,
				isActive
			FROM modTemplate
			WHERE id = :id",
			{
				id = { cfsqltype="integer", value=arguments.referenceBean.getId() }
			},
			{
				datasource = getDsn()
			}
		);

		if ( result.recordCount ) {
			arguments.referenceBean.setId(result.id);
			arguments.referenceBean.setCreatedOn(result.createdOn);
			arguments.referenceBean.setUpdatedOn(isDate(result.updatedOn) ? result.updatedOn : now());
			arguments.referenceBean.setIsActive(result.isActive);
		}
	}

	/**
	 * I update this record in the [table name] table of the database
	 *
	 * @referenceBean any 		I am the modTemplate bean pre-populated with the data to persist
	 *
	 */
	package void function update(required any referenceBean) {
		
		// TODO: BEGIN TESTING - REMOVE WHEN UPDATING FROM TEMPLATE
		return;
		// END TESTING

		queryExecute(
			"
				UPDATE modTemplate
				SET
					createdOn = :createdOn,
					updatedOn = :updatedOn,
					isActive = :isActive
				WHERE id = :id;
			",
			{
				id    		= { cfsqltype="numeric", value="#arguments.referenceBean.getId()#" },
				createdOn	= { cfsqltype="timestamp", value="#arguments.referenceBean.getCreatedOn()#" },
				updatedOn	= { cfsqltype="timestamp", value="#arguments.referenceBean.getUpdatedOn()#" },
				isActive	= { cfsqltype="bit", value="#arguments.referenceBean.getIsActive()#" },
			},
			{
				datasource = getDsn()
			}
		);
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
	package query function filter(
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

		// TODO: BEGIN TESTING - REMOVE WHEN UPDATING FROM TEMPLATE
		var dummyQuery = queryNew("id, title",
			"integer, varchar",
			[
				{"id":1,"title":"Do not include this in your code!"},
				{"id":2,"title":"copy and modify this module"},
				{"id":3,"title":"Use this as a template for your own modules"}
			]
		);
		return dummyQuery;
		// END TESTING

		var sql = "SELECT #arguments.returnColumns# FROM modTemplate WHERE 1 = 1 ";
		var params = {};
		var options = { datasource = getDsn() };

		if( structKeyExists( arguments, "id" ) ) {
			sql &= "AND id = :id ";
			params["id"] = {cfsqltype="numeric", value="#arguments.id#"};
		}

		if( structKeyExists( arguments, "createdOn" ) ) {
			sql &= "AND createdOn = :createdOn ";
			params["createdOn"] = { cfsqltype="timestamp", value="#arguments.createdOn#" };
		}

		if( structKeyExists( arguments, "updatedOn" ) ) {
			sql &= "AND updatedOn = :updatedOn ";
			params["updatedOn"] = { cfsqltype="timestamp", value="#arguments.updatedOn#" };
		}

		if( structKeyExists( arguments, "isActive" ) AND ListFind("0,1", arguments.isActive) ) {
			sql &= "AND isActive = :isActive ";
			params["isActive"] = { cfsqltype="bit", value="#arguments.isActive#" };
		}

		if( structKeyExists( arguments, "groupBy" ) && len(arguments.groupBy) ) {
			sql &= "GROUP BY #arguments.groupBy# ";
		}

		if( structKeyExists( arguments, "orderBy" ) && len(arguments.orderBy)) {
			sql &= "ORDER BY #arguments.orderBy# ";
		}

		if( structKeyExists( arguments, "pagination" ) AND arguments.pagination ) {
			sql &= "LIMIT #arguments.length# OFFSET #arguments.start#;";
		}

		// execute the query and return results
		return queryExecute( sql, params, options );
	}

	/**
	 * I check if a record exists in the [modTemplate] table
	 *
	 * @referenceBean any     The Exchange bean
	 *
	 * @return boolean
	 */
	package boolean function exists( required any referenceBean ) {

		// TODO: BEGIN TESTING - REMOVE WHEN UPDATING FROM TEMPLATE
		return true;
		// END TESTING

		if( queryExecute(
				"
					SELECT Id
					FROM modTemplate
					WHERE Id = :Id
				",
				{
					id = { cfsqltype="integer", value="#arguments.referenceBean.getId()#" }
				},
				{
					datasource = getDsn()
				}
			).recordCount gt 0
		) {
			return true;
		} else {
			return false;
		}
	}
}
