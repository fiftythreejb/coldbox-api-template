/**
 * This is a template only. Yyou may copy this module and update "modTemplate" to be your module name
 * 
 * Manage modTemplate as an API Resource
 * It will be your responsibility to fine tune this template, add validations, try/catch blocks, logging, etc.
 */
component extends="coldbox.system.RestHandler" accessors="true" {

	// DI
	property name="modTemplateService" inject="modTemplateService@modTemplate";
	property name="moduleLog" inject="logbox:logger:modTemplate";

	/**
	 * HTML that will be the base for running the utility
	 */
	function entry(event, rc, prc) {
		event.setView( view="entry", noLayout = true);
	}

	/**
	 * Return the collection of modTemplate
	 */
	function index(event, rc, prc){
		if (!rc.keyExists('param1') || !isValid('date', rc.param1)) {
			var statusCode = arguments.event.status.BAD_REQUEST;
			event.getResponse()
				.setError(true)
				.addMessage("Please provide valid param1 values.")
				.setStatus(statusCode, event.getResponse().status_texts[statusCode]);
			return;
		}

		arguments.event.paramValue("page", 1);
		arguments.event.paramValue("maxRows", 10);

		// logging
		moduleLog.error('moduleLog Test log', {data: rc});
		moduleLog.getRootLogger().warn('test warning log');
		
		// Pagination
		event.paramValue("page", 1);
		event.paramValue("maxRows", 500);
		var args = duplicate(rc);
		args.pagination = true;
		args.length = rc.maxRows;
		args.start = rc.page > 1 ? rc.page * rc.maxRows - rc.maxRows + 1 : 1;

		var results = modTemplateService.filter(argumentCollection = args);
		var totalPages = !results.result_count > rc.maxRows ? 0 : ceiling(results.result_count / rc.maxRows);

		arguments.event.getResponse()
			.setData(results)
			.setPagination(
				maxRows = rc.maxRows, 
				page = rc.page,
				offset = args.start,
				totalRecords = results.result_count,
				totalPages = totalPages
		);
	}

	/**
	 * Create a modTemplate
	 */
	function create(event, rc, prc) secured {
		param arguments.rc.title = '';
		var newBean = variables.modTemplateService.getBean();
		newBean.setTitle(arguments.rc.title);
		variables.modTemplateService.save(referenceBean = newBean, forceInsert = 1);
		arguments.event.getResponse().setData(newBean.getMemento());
	}

	/**
	 * Show a modTemplate
	 */
	function show(event, rc, prc) secured {
		arguments.event.paramValue("id", 0);
		var newBean = variables.modTemplateService.loadById(id = arguments.rc.id);
		arguments.event.getResponse().setData(newBean.getMemento());
	}

	/**
	 * Update or create based on record existence a modTemplate
	 */
	function save(event, rc, prc) secured {
		arguments.event.paramValue("id", 0);
		arguments.event.paramValue("title", '');
		
		var newBean = variables.modTemplateService.getBean();
		populateModel(model = newBean, memento = rc, ignoreEmpty = true);
		variables.modTemplateService.save(referenceBean = newBean);
		
		arguments.event.getResponse().setData(newBean.getMemento());
	}

	/**
	 * Delete a modTemplate
	 */
	function delete(event, rc, prc) secured {
		return;// not implemented
		arguments.event.paramValue("id", 0);
		var newBean = variables.modTemplateService.getBean();
		newBean.setId(arguments.rc.id);
		variables.modTemplateService.remove(referenceBean = newBean);
	}
}

