/**
* The base model test case will use the 'model' annotation as the instantiation path
* and then create it, prepare it for mocking and then place it in the variables scope as 'model'. It is your
* responsibility to update the model annotation instantiation path and init your model.
*/
component extends="coldbox.system.testing.BaseModelTest" model="modTemplate.models.ModTemplateService"{

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();

		// setup the model
		super.setup();

		// init the model object
		model.init();

		// prepare model for mocking
		prepareMock(model);

		// mock properties
		variables.dao = createMock(className = 'modTemplate.models.ModTemplateDao');
		model.$property(propertyName = 'Dao', mock = dao);
	}

	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){

		describe( "ModTemplateService Suite", function(){

			it( "can be created", function(){
				expect( model ).toBeComponent();
			} );

			it( "should list", function(){
				dao.$(method = 'filter', returns = simRecords());
				var listRecords = model.filter();

				expect(listRecords).toBeTypeOf('query', 'object is not at query');
				expect(listRecords).toHaveLength(2, 'query should have 2 rows');
			});


			it( "should save", function(){
				dao.$(method = 'update');
				dao.$(method = 'create');
				dao.$(method = 'exists').$results(true);
				var bean = getInstance('modTemplate.models.ModTemplateBean');
				
				// can update
				bean.setId(1);
				model.save(bean);
				var daoSaveCalls = dao.$count('update');
				expect(daoSaveCalls).toBe(1, 'record not updated');
				
				// can force update
				var bean2 = duplicate(bean.setId(2));
				dao.$reset();
				dao.$(method = 'exists').$results(false);
				model.save(referenceBean = bean2, forceUpdate = true);
				var daoSaveCalls = dao.$count('update');
				expect(daoSaveCalls).toBe(1, 'record not force updated');
				
				// can create new
				var bean3 = duplicate(bean.setId(3));
				dao.$reset();
				model.save(referenceBean = bean3);
				var daoCreateCalls = dao.$count('create');
				var daoExistsCalls = dao.$count('exists');
				expect(daoExistsCalls).toBe(1, 'did not check for existence');
				expect(daoCreateCalls).toBe(1, 'record not created');
				
				// can force create new
				var bean4 = duplicate(bean.setId(4));
				dao.$reset();
				model.save(referenceBean = bean4, forceInsert = true);
				var daoCreateCalls = dao.$count('create');
				expect(dao.$never('exists')).toBeTrue('should not check existence');				
				expect(daoCreateCalls).toBe(1, 'record not force created');				
			});	

			it( "should delete", function(){
				$assert.skip('may not always implement delete');
				expect(false).toBeTrue();
			});			

			it( "should get", function(){
				dao.$(method = 'read');
				var bean = getInstance('modTemplate.models.ModTemplateBean');
				
				// can read
				bean.setId(1);
				model.load(bean);
				var daoReadCalls = dao.$count('read');
				expect(daoReadCalls).toBe(1, 'record not loaded');
			});
		});
	}

	/***************
	 * Private	
	***************/
	private any function simRecords() {
		return querySim("id, title
			1 | sample record
			2 | another record
		");
	}

}
