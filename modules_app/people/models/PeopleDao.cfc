component displayname="PeopleDao" accessors="true" extends="base.models.dao" singleton {

	package people.models.PeopleDao function init() {
		return this;
	}

	/**
	 * Check for record existence by id
	 *
	 * @referenceBean people.models.PeopleBean     The Parked Order bean pre-populated with the data
	 *
	 * @return boolean
	 */
	package boolean function exists(required people.models.PeopleBean referenceBean) {
		
		// TODO: BEGIN TESTING - REMOVE WHEN UPDATING FROM TEMPLATE
		return true;
		// END TESTING

		return queryExecute("
				SELECT id
				FROM tb_investor
				WHERE id = :investorId
			",
			{investorId = {cfsqltype = "integer", value = arguments.referenceBean.getId()}},
			{datasource = getDsn()}
		).recordCount;
	}

	 /**
	 * Populate a investor bean with the details of a specific record
	 *
	 * @referenceBean people.models.PeopleBean     I am the investor bean pre-populated with tb_investor data
	 *
	 */
	package void function read(required people.models.PeopleBean referenceBean) {

		// TODO: BEGIN TESTING - REMOVE WHEN UPDATING FROM TEMPLATE
		arguments.referenceBean.setId(999999);
		arguments.referenceBean.setFirstName('Test');
		arguments.referenceBean.setLastName('Admin');
		arguments.referenceBean.setEmail('admin@coldbox.org');
		arguments.referenceBean.setPasswordHash('Admin');
		arguments.referenceBean.setSalt('salt');
		return;
		// END TESTING

		var result = queryExecute("
				SELECT
					id,
					d_email,
					d_password_hash,
					d_salt,
					d_first_name,
					d_last_name,
					d_is_active
				FROM tb_investor
				WHERE
					(:investorId IS NOT NULL AND id = :investorId)
					OR (:email IS NOT NULL AND d_email = :email)
			",
			{
				investorId = { cfsqltype="integer", value="#arguments.referenceBean.getId()#", null = (!arguments.referenceBean.getId() GT 0)},
				email = { cfsqltype="varchar", value="#arguments.referenceBean.getEmail()#", null = (!arguments.referenceBean.getEmail().len())}
			},
			{datasource = getDsn()}
		);

		if (result.recordCount) {
			arguments.referenceBean.setId(result.id);
			arguments.referenceBean.setFirstName(result.d_first_name);
			arguments.referenceBean.setLastName(result.d_last_name);
			arguments.referenceBean.setEmail(result.d_email);
			arguments.referenceBean.setPasswordHash(result.d_password_hash);
			arguments.referenceBean.setSalt(result.d_salt);
		}
	}

	/**
	 * Create a new investor from a reference bean
	 *
	 * @referenceBean people.models.PeopleBean     investor bean pre-populated with data
	 */
	public numeric function create(required people.models.PeopleBean referenceBean) {
		var result = queryExecute("
				INSERT INTO tb_investor (
					d_email,
					d_password_hash,
					d_salt,
					d_first_name,
					d_last_name,
					d_is_active,
					d_record_created
				)
				Values (
					:email,
					:passwordHash,
					:firstName,
					:lastName,
					:isActive,
					CURRENT_TIMESTAMP
				);
				SELECT LAST_INSERT_ID() AS investorId;
			",
			{
				email = { cfsqltype="varchar", value="#arguments.referenceBean.getEmail()#", null = (!arguments.referenceBean.getEmail().len())},
				passwordHash = { cfsqltype="varchar", value="#arguments.referenceBean.getPasswordHash()#", null = (!arguments.referenceBean.getPasswordHash().len())},
				firstName = {cfsqltype = "varchar", value = arguments.referenceBean.getFirstName()},
				lastName = {cfsqltype = "varchar", value = arguments.referenceBean.getLastName()},
				isActive = {cfsqltype = "bit", value = (arguments.referenceBean.getIsActive() ? 1 : 0)}
			},
			{datasource = getDsn()}
		).investorId;

		arguments.referenceBean.setId(result);
	}


	/**
	 * I run a filtered query of all records within the parked order in the database
	 *
	 * @returnColumns string 				A list of the columns
	 * @investorId numeric					The primary key for the investor record
	 * @email string						investor email
	 * @email firstName						investor first name
	 * @email lastName						investor last name
	 * @isActive boolean					Is the parked record active
	 *
	 * @return query
	 */
	package query function filter(
		string returnColumns = "id,d_email,d_first_name,d_last_name,d_is_active",
		numeric investorId,
		string email,
		string firstName,
		string lastName,
		boolean isActive
	) {

		var sql = "SELECT #arguments.returnColumns# FROM tb_investor WHERE 1 = 1 ";

		var params = {};

		if(! isNull( arguments.investorId)) {
			sql &= "AND id = :investorId ";
			params["investorId"] = {cfsqltype = "integer", value = "#arguments.investorId#"};
		}

		if(! isNull( arguments.email)) {
			sql &= "AND d_email = :email ";
			params["email"] = {cfsqltype = "varchar", value = "#arguments.email#"};
		}
		
		if(! isNull( arguments.firstName)) {
			sql &= "AND d_first_name = :firstName ";
			params["firstName"] = {cfsqltype = "varchar", value = "#arguments.firstName#"};
		}
		
		if(! isNull( arguments.lastName)) {
			sql &= "AND d_last_name = :lastName ";
			params["lastName"] = {cfsqltype = "varchar", value = "#arguments.lastName#"};
		}


		if(! isNull( arguments.isActive)) {
			sql &= "AND d_is_active = :isActive ";
			params["isActive"] = {cfsqltype = "tinyint", value = "#arguments.isActive#"};
		}

		// execute the query and return results
		return queryExecute( sql, params, {datasource: getDsn()});
	}

	/**
	 * Update an existing parked transaction
	 *
	 * @referenceBean people.models.PeopleBean     Parked Order bean pre-populated with data
	 */
	public void function update(required people.models.PeopleBean referenceBean) {
		queryExecute("
				UPDATE tb_investor
				SET
					d_first_name = :firstName,
					d_last_name = :lastName,
					d_is_active = :isActive,
					d_record_updated = CURRENT_TIMESTAMP
				WHERE id = :investorId
			",
			{
				investorId = { cfsqltype="integer", value="#arguments.referenceBean.getId()#", null = (!arguments.referenceBean.getId() GT 0)},
				firstName = {cfsqltype = "varchar", value = arguments.referenceBean.getFirstName()},
				lastName = {cfsqltype = "varchar", value = arguments.referenceBean.getLastName()},
				isActive = {cfsqltype = "bit", value = (arguments.referenceBean.getIsActive() ? 1 : 0)}
			},
			{datasource = getDsn()}
		);
	}


    /**
	 * Soft delete parked orders by transaction id
	 *
	 * @referenceBean any	I am the parked order bean pre-populated with the data

	 */
	package void function delete(required any referenceBean) {
		if (!arguments.referenceBean.getId() > 0) {
			throw(type="validation", message="Invalid arguments.", detail="Investor id not found.");
		}

		queryExecute("
				UPDATE tb_investor
				SET d_is_active = 0,
					d_record_updated = CURRENT_TIMESTAMP
				WHERE id = :investorId
			",
			{investorId = { cfsqltype="integer", value="#arguments.referenceBean.getId()#", null = (!arguments.referenceBean.getId() GT 0)}},
			{datasource = getDsn()}
		);
	}
}
