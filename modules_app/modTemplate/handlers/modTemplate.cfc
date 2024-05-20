/**
 * This is a template only. Yyou may copy this module and update "modTemplate" to be your module name
 * 
 * Manage modTemplate as an API Resource
 * It will be your responsibility to fine tune this template, add validations, try/catch blocks, logging, etc.
 */
component extends="coldbox.system.RestHandler" accessors="true" {

	// DI
	property name="modTemplateService" inject="modTemplateService@modTemplate";

	/**
	 * Return the collection of modTemplate
	 */
	function index(event, rc, prc){
		arguments.event.paramValue("page", 1);
		arguments.event.paramValue("maxRows", 10);

		// can setup and pass filter arguments here as well
		arguments.event.getResponse().setData(modTemplateService.filter(
			start = rc.page ? rc.page * rc.maxRows - rc.maxRows : 0,
			length = rc.maxRows,
			pagination = true
		)).setPagination(maxRows = rc.maxRows, page = rc.page);
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

		if (!newBean.getId() > 0) {
			var statusCode = arguments.event.status.NO_CONTENT;
			event.getResponse()
				.setError(true)
				.setStatus(statusCode, event.getResponse().status_texts[statusCode]);
			return event.getResponse().status_texts[statusCode];
		}
		
		arguments.event.getResponse().setData(newBean.getMemento());
	}

	/**
	 * Update a modTemplate
	 */
	function update(event, rc, prc) secured {
		arguments.event.paramValue("id", 0);
		arguments.event.paramValue("title", '');

		if (!rc.id > 0 || !rc.title.len() > 0) {
			var statusCode = arguments.event.status.BAD_REQUEST;
			event.getResponse()
				.setError(true)
				.setStatus(statusCode, event.getResponse().status_texts[statusCode]);
			return;
		}

		var newBean = variables.modTemplateService.getBean();
		newBean.setId(arguments.rc.id);
		newBean.setTitle(arguments.rc.title);
		variables.modTemplateService.save(referenceBean = newBean, forceUpdate = true);
		
		arguments.event.getResponse().setData(newBean.getMemento());
	}

	/**
	 * Delete a modTemplate
	 */
	function delete(event, rc, prc) secured {
		return;// not implemented
		arguments.event.paramValue("id", 0);

		if (!rc.id > 0) {
			var statusCode = arguments.event.status.BAD_REQUEST;
			event.getResponse()
				.setError(true)
				.setStatus(statusCode, event.getResponse().status_texts[statusCode]);
			return;
		}

		var newBean = variables.modTemplateService.getBean();
		newBean.setId(arguments.rc.id);
		variables.modTemplateService.remove(referenceBean = newBean);
	}

}

