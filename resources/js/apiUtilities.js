let cfApiUtility = function(customSettings) {
	let settings = {
		baseUrl: 'https://simpplrapi.prod.westernhealth.com/',	// api base url
		parentCssUrl: 'resources/css/apiUtility.css',					// CSS file to append to parent document (used for modal)
		endpointClass: 'makeRequest',									// class of a button (or form) that will be used to call the endpoint
		endpointTargetId_button: 'targetId',							// A data-attribute to target the id of an object that the data will return to (ex: dataTable)
		endpointRestMethod_button: 'method',							// A data-attribute to determine what REST method to use (data-method="GET")

		endpointHtmlClass: 'getHtml',									// class of a button that will be used to call the endpoint and return html
		endpointValidationFunction: 'validateFunction',					// A function in the extending class that can be used to validate a form submit
		endpointConfirm: 'confirm',										// A data attribute that will be used in a confirmation dialog before endpoint execution

		clearDataClass_button: 'clearData',								// button that will be used to clear data from the related
		clearDataTargetId_button: 'targetId',							// A data-attribute to target the id of an object that the data will be cleared from (ex: dataTable)

		resultTemplateType: 'templateType',								// a data-attribute name that will determine template type [table, string, link]
		resultTemplateClass_dataTable: 'data-template',					// class to get the template used for the returned data
		resultAttribute_key_dataTable: 'key',							// a data-attribute that holds the data keys name
		resultAttribute_customFunction_dataTable: 'customFunction',		// a data-attribute that holds the custom function name to populate the template value
		resultAttribute_customJs: 'CUSTOMJS',							// a data-attribute that holds the custom js file path to use for html processing
		resultAttribute_customJsVar: 'CUSTOMJSVAR',						// a data-attribute that holds the custom js variable to use for html processing
		resultAttribute_post_process: 'postProcessFunction',			// a data-attribute that holds the custom function name to run after request execution (receives arguments [response, ele])
		resultAttribute_processResult: 'resultFunction',				// a data-attribute that holds the custom function name to run after each record (receives arguments [response, ele])
		resultAttribute_type_dataTable: 'type',							// a data-attribute that determines the data type to format [date, link]
		resultAttribute_href_dataTable: 'link',							// a data-attribute that determines the href for format link
		resultAttribute_endpoint_datalist_link: 'datalist',				// a data-attribute that determines the ('whack') list of variables that will be appended to the endpoint (/var1/var2/)
		resultAttribute_endpoint_return_link: 'returnType',				// a data-attribute to determine fetch request type ['login', 'file']
		dataTable_colFilter_key: 'filter-column',						// a data-attribute that holds the key for setting up filtered column

		modal_enable: true,												// enable custom modal
		modal_WrapperId: 'apiModal',									// an Id label that will be used for the modal wrapper that's appended to the body
		modal_openAttr: 'modal',										// a data attribute used to select which elements will be set up to open the modal [show,fill]
		modal_populateClass: 'modal-fill',								// a class used to select which elements will be set up to populate a modal the modal

		isIframe: null,

		alertBoxId: 'liveAlertPlaceholder',								// element that will hold the bootstrap 5 alert
		userDataId: 'userData',											// element that will show the logged in user
		userName: 'd.sheets@westernhealth.com',													// the email to use for authorization
		simplerDataElementId: 'simpplr-salesforce-userinfo',			// document element that holds simpplr user data
		simpplrData: {},												// this will hold the data for the user logged into simpler
		jwt: '',														// token needed for api calls
		jwtRefresh: '',													// token needed for api calls
		jwtExpires: '',													// the tokens expiration time
														
		autocompleteClass: 'autocomplete-input',
		autocompleteEndpoint: 'autocomplete-endpoint',
		autocompleteListClass: 'autocomplete-list',									
	};

	// Initialize the api utility
	const init = function(bindElement, bindTemplate = true) {
		if (typeof bindElement === 'undefined') {
			bindElement = document;
		}
		publicMethods.settings.ignoredDataAttributes = ['method', publicMethods.settings.endpointTargetId_button];

		if (typeof customSettings !== 'undefined') {
			if (customSettings.settings !== null){
				publicMethods.settings = {
					...publicMethods.settings,
					...customSettings.settings
				};
			}
			if (customSettings.customUtils !== null){
				publicMethods.customUtils = {
					...publicMethods.customUtils,
					...customSettings.customUtils
				};
			}

			if (typeof customSettings.autoLoadOnHtml !== 'undefined' && customSettings.autoLoadOnHtml !== null){
				publicMethods.autoLoadOnHtml = customSettings.autoLoadOnHtml;
			}
		}

		// see if we can get the user from simpplr. if not, use default
		if ( checkForSimpplrUserData() ) {
			publicMethods.settings.userName = publicMethods.settings.simpplrData.email;
			// console.log('user: ', publicMethods.settings.userName);
		}

		setUiObjects();
		bindUIActions(bindElement, false);

		if (publicMethods.settings.parentCssUrl.length) {
			addCss(publicMethods.settings.baseUrl + publicMethods.settings.parentCssUrl);
		}
	};

/********************
	UI Methods
********************/
	// get the user from simpplr
	const checkForSimpplrUserData = function() {
		let userInfoEle = null;

		// return false if it is not
		if (!isIframe()) {
			userInfoEle = window.document.getElementById(publicMethods.settings.simplerDataElementId);
		} else {
			userInfoEle = parent.document.getElementById(publicMethods.settings.simplerDataElementId);
		}

		// pull in the Simpplr data if available
		if (userInfoEle === null) {
			return false;
		}
		// set the auth user to the simpplr user if available
		try {
			publicMethods.settings.simpplrData = JSON.parse(userInfoEle.textContent.replace(/\s/g,'').replace('""','","'));
			return true;
		} catch (e) {
			return false;
		}
	};

	const setUiObjects = function() {
		// search display
		publicMethods.uiObjects.alertBox = document.getElementById(publicMethods.settings.alertBoxId);

		if (publicMethods.settings.modal_enable) {
			publicMethods.uiObjects.customModal = document.createElement('div');
			buildModal(publicMethods.uiObjects.customModal);
		}
	};

	// set event listeners
	const bindUIActions = function(bindEle, bindTemplate = true) {
		let bindElement = bindEle;
		if (typeof bindElement === 'undefined') {
			bindElement = document;
		}

		// set listeners for endpoint buttons
		const endpointButtons = bindElement.querySelectorAll(`.${publicMethods.settings.endpointClass}`);
		endpointButtons.forEach(ele => {
			if (!bindTemplate && (ele.classList.contains('data-template') || ele.closest('data-template') !== null)) {
				return;
			}

			let fetchType = ele.getAttribute(`data-${publicMethods.settings.resultAttribute_endpoint_return_link}`);
			let postProcessFunction = ele.getAttribute(`data-${publicMethods.settings.resultAttribute_post_process}`);
			let listenerPostFunction = null;
			const targetId = ele.getAttribute(`data-${publicMethods.settings.endpointTargetId_button}`);
			ele.targetElement = bindElement.querySelector(`#${targetId}`);

			if (postProcessFunction != null) {
				listenerPostFunction = publicMethods.customUtils[postProcessFunction];
			} else {
				listenerPostFunction = function(response, ele, publicMethods, event){
					if (publicMethods.settings.modal_enable) {
						let parentObj = document;

						if (isIframe()) {
							parentObj = parent.document;
						} 

						let modalObj = parentObj.getElementById(publicMethods.settings.modal_WrapperId);
						if (modalObj != null) {
							ele.targetElement = publicMethods.uiObjects.customModal.querySelector(`#${targetId}`);
						}
					}

					// second submit may have different settings
					if (ele.tagName == 'FORM' && event.submitter !== null) {
						submitterReturn = event.submitter.getAttribute(`data-${publicMethods.settings.resultAttribute_endpoint_return_link}`);
						if (submitterReturn !== null) {
							fetchType = submitterReturn;
						}
					}

					if (ele.targetElement != null && (fetchType === null || fetchType.toUpperCase() !== 'FILE') ) {
						clearTemplate(ele.targetElement);
						populateTemplate(ele.targetElement, response.data, response.pagination);
					}

					if (ele.tagName === 'FORM') {
						const clearOnSubmit = checkOption(ele, 'clearOnSubmitId');
						if (clearOnSubmit != null && clearOnSubmit.length) {
							clearTemplate(ele.parentElement);
						}
					}
				}
			}

			bindLinkListener(
				ele,
				(ele.tagName == 'FORM' ? 'submit' : 'click'), 
				(fetchType ? fetchType : ''), 
				listenerPostFunction
			);
			publicMethods.actionButtons[ele.id] = ele;
		});

		// Buttons to clear data
		const clearButtons = bindElement.querySelectorAll(`.${publicMethods.settings.clearDataClass_button}`);
		clearButtons.forEach(ele => {
			ele.addEventListener('click', function(event) {
				event.preventDefault();
				const targetId = ele.getAttribute(`data-${publicMethods.settings.clearDataTargetId_button}`);
				ele.targetElement = bindElement.querySelector(`#${targetId}`);
				clearTemplate(ele.targetElement);
				return false;
			});

			publicMethods.actionButtons[ele.id] = ele;
		});

		// HTML requests
		const endpointHtmlCalls = bindElement.querySelectorAll(`.${publicMethods.settings.endpointHtmlClass}`);
		endpointHtmlCalls.forEach(ele => {
			// post Process function
			let postProcessFunction = ele.getAttribute(`data-${publicMethods.settings.resultAttribute_post_process}`);
			let listenerPostFunction = function(response, ele, publicMethods){};
			if (postProcessFunction != null) {
				listenerPostFunction = publicMethods.customUtils[postProcessFunction];
			}

			bindLinkListener(
				ele, 
				(ele.tagName == 'FORM' ? 'submit' : 'click'), 
				'html', 
				listenerPostFunction
			);
			publicMethods.actionButtons[ele.id] = ele;
		});

		// on bootstrap modal show, run bind
		const bsModals = bindElement.querySelectorAll(`.modal`);
		bsModals.forEach(ele => {
			ele.addEventListener('shown.bs.modal', function(event) {
				bindUIActions(ele);
			});

			publicMethods.actionButtons[ele.id] = ele;
		});

		bindAutocomplete(bindElement);
	};

	const bindLinkListener = (ele, action, returnType, processFunction) => {
		if (ele.dataset.hasOwnProperty('hasMakeRequest')) {
			return ele;
		}

		ele.addEventListener(action, function(event) {
			event.preventDefault();
			let restMethod = '';
			let fetchUrl = '';
			let options = {};
			let data = {};
			const useModal = publicMethods.settings.modal_enable;
			let parsedReturnType = returnType;
			let endpointConfirmation = '';

			if (ele.hasAttribute(`data-${publicMethods.settings.endpointConfirm}`)) {
				endpointConfirmation = ele.getAttribute(`data-${publicMethods.settings.endpointConfirm}`);
				if (!confirm(endpointConfirmation)) {
					return false;
				}
			}

			switch (ele.tagName) {
				case 'FORM':
					restMethod = ele.method;
					fetchUrl = publicMethods.settings.baseUrl + ele.getAttribute('action');
					data = new FormData(ele, event.submitter);
					options = {method: restMethod, body: data};
					submitterReturn = event.submitter.getAttribute(`data-${publicMethods.settings.resultAttribute_endpoint_return_link}`);
					if (submitterReturn !== null) {
						parsedReturnType = submitterReturn;
					}

					// validation function
					const validate = ele.getAttribute(`data-${publicMethods.settings.endpointValidationFunction}`);
					if (validate != null && !publicMethods.customUtils[validate](this)) {
						return false;
					}

					if (ele.targetElement != null) {
						clearTemplate(ele.targetElement);
					}
					break;
				default:
					restMethod = ele.getAttribute(`data-${publicMethods.settings.endpointRestMethod_button}`);
					fetchUrl = publicMethods.settings.baseUrl + ele.getAttribute('href');
					options = {method: restMethod};
					data = ele.dataset;
					break;
			}

			if (options.hasOwnProperty('body')) {
				// ignore body set if form
			} else if (restMethod == 'POST' && Object.keys(data).length) {
				options.body = JSON.stringify(data);
			} else if (restMethod == 'DELETE' && Object.keys(data).length) {
				options.body = JSON.stringify(data);
			} else if (restMethod == 'GET') {
				const paramsList = ele.getAttribute(`data-${publicMethods.settings.resultAttribute_endpoint_datalist_link}`);
				if (paramsList != null) {
					const paramArray = paramsList.split();
					paramArray.forEach(item => {
						let keyName = item.toLowerCase();
						if (!publicMethods.settings.ignoredDataAttributes.includes(keyName)) {
							fetchUrl += data[keyName] +'/';
						}
					});

				} else {
					let fetchParams = new URLSearchParams(data);
					fetchUrl += (fetchUrl.includes('?') ? '&' : '?') + fetchParams.toString();
				}
			}

			let fetchReturn = makeRequest(
				fetchUrl,
				options,
				processFunction,
				parsedReturnType,
				this,
				event
			);

			if (parsedReturnType === 'html') {
				fetchReturn.then((data) => {
					if (typeof data !== 'undefined') {
						if (useModal && ele.hasAttribute(`data-${publicMethods.settings.modal_openAttr}`)) {
							switch (ele.getAttribute(`data-${publicMethods.settings.modal_openAttr}`)) {
								case 'show':
									showModal(data);
									break;
								case 'fill':
									populateModal(data);
									break;
								default:
									return false;
							}

							// Set bootstrap js
							const bsScriptEle = document.createElement('script');

							/*
								
								Need a way to use existing bootstrap.
							
							*/
							bsScriptEle.setAttribute('src', 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js');
							bsScriptEle.setAttribute('integrity', 'sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz');
							bsScriptEle.setAttribute('crossorigin', 'anonymous');

							publicMethods.uiObjects.customModal.appendChild(bsScriptEle);

							// do we have a module js
							const jsFile = ele.getAttribute(`data-${publicMethods.settings.resultAttribute_customJs}`);
							const jsVar = ele.getAttribute(`data-${publicMethods.settings.resultAttribute_customJsVar}`);
							if (jsFile !== null && jsVar !== null && jsFile.length && jsVar.length) {
								let scriptEle = document.createElement("script");
								scriptEle.setAttribute("src", publicMethods.settings.baseUrl + jsFile);
								publicMethods.uiObjects.customModal.appendChild(scriptEle);

								scriptEle.addEventListener("load", () => {
									let settingsMerge = parent.document[jsVar];
									if (typeof customSettings !== 'undefined') {
										// merge custom settings
										if (customSettings.settings !== null){
											settingsMerge.settings = {
												...customSettings.settings,
												...settingsMerge.settings,
											};
										}
										if (customSettings.customUtils !== null){
											settingsMerge.customUtils = {
												...customSettings.customUtils,
												...settingsMerge.customUtils,
											};
										}
									}
									
									let tempUtil = (cfApiUtility(settingsMerge));
									tempUtil.init(publicMethods.uiObjects.customModal, false);
									tempUtil.uiObjects = publicMethods.uiObjects;
									tempUtil.autoLoadOnHtml();

									parent.document[jsVar] = tempUtil;
								});

								scriptEle.addEventListener("error", (ev) => {
									console.log("Error on loading file", [ev, jsFile]);
								});
								return false;
							}

							let tempUtil = (cfApiUtility(customSettings));
							tempUtil.init(publicMethods.uiObjects.customModal);
							tempUtil.uiObjects = publicMethods.uiObjects;
							tempUtil.autoLoadOnHtml();
						} else {
							const targetId = ele.getAttribute(`data-${publicMethods.settings.endpointTargetId_button}`);
							const bindElement = useModal ? publicMethods.uiObjects.customModal : document;
							ele.targetElement = bindElement.querySelector(`#${targetId}`);
							ele.targetElement.innerHTML = data;
							publicMethods.bindUIActions(ele.targetElement);
							publicMethods.autoLoadOnHtml();
						}
					}
				});
			}

			ele.dataset.hasMakeRequest = true;
			return false;
		});

		return ele;
	};

	const loadHtml = (endpoint, targetId, data) => {
		let options = {method: 'GET'};
		let fetchUrl = publicMethods.settings.baseUrl + endpoint;
		let fetchParams = new URLSearchParams(data);
		fetchUrl += '?'+ fetchParams.toString();

		let fetchReturn = makeRequest(
			fetchUrl,
			options,
			function(){},
			'html'
		);

		return fetchReturn.then((data) => {
			if (typeof data !== 'undefined') {
				const targetElement = document.getElementById(targetId);
				targetElement.innerHTML = data;
				publicMethods.bindUIActions(targetElement);
				publicMethods.autoLoadOnHtml();
			}
			return data;
		});
	};

	const autoLoad = (endpoint, httpMethod, targetId, data) => {
		let options = {method: httpMethod};
		let fetchUrl = publicMethods.settings.baseUrl + endpoint;
		let targetElement = document.getElementById(targetId);

		if (httpMethod.toUpperCase() == "GET") {
			let fetchParams = new URLSearchParams(data);
			fetchUrl += '?'+ fetchParams.toString();
		} else {
			options.body = JSON.stringify(data);
		}

		let fetchReturn = makeRequest(
			fetchUrl,
			options,
			function() {},
			'autoload'
		);

		return fetchReturn.then((response) => {
			if (typeof response !== 'undefined') {		
				if (publicMethods.settings.modal_enable) {
					let parentObj = document; 

					if (isIframe()) {
						parentObj = parent.document; 
					} 

					let modalObj = parentObj.getElementById(publicMethods.settings.modal_WrapperId);
					if (modalObj != null) {
						targetElement = publicMethods.uiObjects.customModal.querySelector(`#${targetId}`);
					}
				}

				clearTemplate(targetElement);
				populateTemplate(targetElement, response.data);
			}
			return data;
		});
	};

	const buildModal = (modalWrapper) => {
		modalWrapper.className = `modal-custom`;
		modalWrapper.id = publicMethods.settings.modal_WrapperId;
		modalWrapper.tabIndex = 1;
		modalWrapper.setAttribute('role', 'modal');
		modalWrapper.innerHTML = [
			'<div class="modal-dialog-custom">',
			'    <div class="modal-header-custom">',
			'        <button type="button" class="modal-close" aria-label="Close"></button>',
			'    </div>',
			'    <div class="modal-body-custom">',
			'        <p>Modal body text goes here.</p>',
			'    </div>',
			'</div>',
			`<div id="${publicMethods.settings.alertBoxId}_modal"></div>`,
			'<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" integrity="sha256-PI8n5gCcz9cQqQXm3PEtDuPG8qx9oFsFctPg0S5zb8g=" crossorigin="anonymous">',
		].join('');

		const closeButtons = modalWrapper.querySelectorAll('.modal-close');
		closeButtons.forEach(ele => {
			ele.addEventListener('click', function(event) {
				event.preventDefault();
				removeModal();
				return false;
			});
		});		
	};

	const showModal = (data) => {
		let modalObj = publicMethods.uiObjects.customModal;
		let parentBody = document.body; 

		if (isIframe()) {
			parentBody = parent.document.body; 
		} 

		parentBody.append(modalObj);
		publicMethods.uiObjects.alertBox = parentBody.querySelector(`#${publicMethods.settings.alertBoxId}_modal`);
		modalObj.classList.add('fade-in');
		
		populateModal(data);
	};

	const populateModal = (data) => {
		let modalObj = publicMethods.uiObjects.customModal;
		if (data !== undefined) {
			let modalBody = modalObj.querySelector('.modal-body-custom')
			modalBody.innerHTML = data;
		}
	}

	const removeModal = () => {
		publicMethods.uiObjects.alertBox = publicMethods.uiObjects.alertBox = document.getElementById(publicMethods.settings.alertBoxId);
		publicMethods.uiObjects.customModal.remove();
	};
	
/************************
 * UI Utilities
************************/
	const appendAlert = (message, type, timeout = 0) => {
		const wrapper = document.createElement('div');
		wrapper.className = `alert alert-${type} alert-dismissible`;
		wrapper.setAttribute('role', 'alert');

		wrapper.innerHTML = [
			`   <div>${message}</div>`,
			'   <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>',
		].join('');
		
		publicMethods.uiObjects.alertBox.innerHTML = '';
		publicMethods.uiObjects.alertBox.append(wrapper);

		if (timeout > 0) {
			try {
				new bootstrap.Alert(wrapper);
				setTimeout(() => {
					bootstrap.Alert.getInstance(wrapper).close();
				}, timeout);
			} catch (error) {
				console.log(error);
			}
		}
	};

	const formatMessageArray = (messageArr) => {
		if (!Array.isArray(messageArr)) {
			return 'not array';
		}
		
		return messageArr.join(' <br />');
	};

	const clearTemplate = function(ele) {
		let cloneTemplate = ele.querySelector(`.${publicMethods.settings.resultTemplateClass_dataTable}`);
		const eleTemplateType = ele.dataset[publicMethods.settings.resultTemplateType.toLowerCase()];		
		if (eleTemplateType && eleTemplateType == 'html') {
			ele.innerHTML = '';
			return;
		}
		
		if (!cloneTemplate) {
			return;
		}
		
		cloneTemplate.cloneNode(true);
		ele.innerHTML = '';
		ele.appendChild(cloneTemplate);
	};

	const populateTemplate = function(ele, data, pagination = null) {
		let template = ele.querySelector(`.${publicMethods.settings.resultTemplateClass_dataTable}`);
		if (ele.classList.contains(publicMethods.settings.resultTemplateClass_dataTable)) {
			template = ele;
		}
		ele.template = template;

		// get template type
		let templateType = '';
		if (template !== null) {
			templateType = template.getAttribute(`data-${publicMethods.settings.resultTemplateType}`);
		}
		switch(templateType) {
			// table template processing
			case 'table':
				populateTableTemplate(ele, template, data, pagination);
				break;
			case 'link':
				populateLinkTemplate(ele, template, data);
				break;
			case 'struct':
				populateFromStruct(ele, template, data);
				break;
			case 'form':
				populateForm(ele, template, data);
				break;
			case 'DATAARRAY':
				populateArrayTemplate(ele, template, data);
				break;
			default:
				populateEleTemplate(ele, data);
		}
	};

	const populateEleTemplate = function(ele, data) {

		// Hide element if requested
		if (checkOption(ele, 'hideBlank') === 'true' && !data.length ) {
			ele.setAttribute('hidden', true);
		}

		let dataType = ele.getAttribute(`data-${publicMethods.settings.resultAttribute_type_dataTable}`);
		if (dataType === null) {
			dataType = '';
			if (Array.isArray(data)) {
				dataType == 'ARRAY';
			}
		}
		switch (dataType.toUpperCase()) {
			case 'DATE':
				ele.innerHTML = formatDate(data);
				break;
			case 'ARRAY':
				ele.innerHTML = formatMessageArray(data);
				break;
			default:
				ele.innerHTML = data;
		}

		if (ele.innerHTML.length) {
			unHide(ele);
		}

		if (checkOption(ele, 'bindUIActions') == 'true') {
			publicMethods.bindUIActions(ele.parentElement);
		}
	}

	const populateFromStruct = function(ele, template, data, idIndex = 1) {
		let cloneTemplate;
		if (checkOption(template, 'dontClone') == 'true') {
			cloneTemplate = template;
		} else {
			cloneTemplate = template.cloneNode(true);
			cloneTemplate.id += idIndex;
			clearTemplate(ele);
		}
		// loop through the results
		let children = cloneTemplate.children;
		let hasData = false;
		let childCount = children.length;

		for (let i = 0; i < childCount; i++) {
			// loop through elements to get templates to fill
			let child = children[i];
			const objKey = child.getAttribute(`data-${publicMethods.settings.resultAttribute_key_dataTable}`);
			const objType = child.getAttribute(`data-${publicMethods.settings.resultAttribute_type_dataTable}`);

			// return early if we cant get the data
			if (objKey == null) {
				continue;
			} else if (!objKey.length || !data.hasOwnProperty(objKey)) {
				if (!objType == null && objType.length && objType.toUpperCase() == 'TABLE') {
					child.innerHTML = '<tr><td class="text-warning">Could not get data</td></tr>';
				} else {
					child.innerHTML = '<div class="text-warning">Could not get data</div>';
				}
				continue;
			}

			populateTemplate(child, data[objKey]);
			if (!hasData && data[objKey].length) {
				hasData = true;
			}
		}

		// show the new row and append to the parent
		if (!hasData) {
			if (checkOption(ele, 'hideBlank') === 'true') {
				return;
			}
		}
		unHide(cloneTemplate);
		
		if (ele !== template) {
			ele.appendChild(cloneTemplate);
		} else if (checkOption(ele, 'dontClone') !== 'true') {
			ele.parentElement.appendChild(cloneTemplate);
		}
	};

	const populateForm = function(ele, template, data, idIndex = 1) {
		let cloneTemplate;
		cloneTemplate = template.cloneNode(true);
		cloneTemplate.id += idIndex;
		clearTemplate(ele);
		
		// loop through the results
		let children = cloneTemplate.elements;
		let childCount = children.length;

		for (let i = 0; i < childCount; i++) {
			// loop through elements to get templates to fill
			let child = children[i];
			const objKey = child.getAttribute(`data-${publicMethods.settings.resultAttribute_key_dataTable}`);

			// return early if we cant get the data
			if (objKey == null || !objKey.length || !data.hasOwnProperty(objKey)) {
				continue;
			}

			child.value = data[objKey];
		}

		// show the new row and append to the parent
		unHide(cloneTemplate);
		ele.appendChild(cloneTemplate);

		bindUIActions(ele.parentElement);
	};

	const populateTableTemplate = function(ele, template, data, pagination = null) {
		const hideBlankCols = checkTableTemplateForHideBlank(template);
		let parentEle = ele;
		let parentTable = ele;
		let eleIsTemplate = ele == template;
		let blankDataCol = [];
		let columnIndexToHide = [];
		if (eleIsTemplate) {
			parentEle = ele.closest('TBODY');
			template.removeAttribute('data-key');
		}

		if (parentEle.tagName !== 'TBODY') {
			let getParent = parentEle.closest('tbody');
			if (getParent == null) {
				getParent = parentEle.getElementsByTagName('tbody')[0];
			}

			if (getParent == null) {
				console.log('cannot append');
				return;
			}
			parentEle = getParent;
		}

		if (parentTable.tagName !== 'TABLE') {
			parentTable = parentEle;
			if (parentTable.tagName !== 'TABLE') {
				parentTable = parentTable.parentElement;
			}

			if (parentTable.tagName !== 'TABLE') {
				parentTable = parentTable.parentElement;
			}
		}

		if (!data.length) {
			appendAlert('No data returned', 'warning', 10000);
			return;
		}

		if (hideBlankCols.length) {
			blankDataCol = checkBlankTableColumnData(data);
		}

		// loop through the result rows
		data.forEach(row => {
			let cloneTemplate = template.cloneNode(true);
			// copy a reference to the template row and copy
			cloneTemplate.id += data.indexOf(row);
			cloneTemplate.removeAttribute(`data-${publicMethods.settings.resultTemplateType}`);
			cloneTemplate.classList.remove(publicMethods.settings.resultTemplateClass_dataTable);
			
			// loop through the template columns and fill in the values				
			var children = cloneTemplate.children;
			for (var i = 0; i < children.length; i++) {
				let child = children[i];
				const className = child.getAttribute(`data-${publicMethods.settings.resultAttribute_key_dataTable}`);
				let dataType = child.getAttribute(`data-${publicMethods.settings.resultAttribute_type_dataTable}`);
				if (dataType === null) {
					dataType = '';
				}

				switch (dataType.toUpperCase()) {
					case 'DATE':
						if (typeof child !== 'undefined' && typeof child.dataset !== 'undefined' && child.hasAttribute("data-type") && child.dataset.type == 'date') {
							child.innerHTML = formatDate(row[className]);
						}
						break;
					case 'TEMPLATE':
						populateTemplate(child, row);
						break;
					default:
						child.innerHTML = row[className];
						break;
				}

				if (checkOption(child, 'bindUIActions') == 'true') {
					publicMethods.bindUIActions(child.parentElement);
				}

				// Hide column if requested
				if (hideBlankCols.includes(className) && blankDataCol.colsWithOutData.includes(className)) {
					child.setAttribute('hidden', true);
					if (!columnIndexToHide.includes(i)) {
						columnIndexToHide.push(i);
					}
				}
			}

			// show the new row and append to the table
			unHide(cloneTemplate);

			let recordProcessFunction = cloneTemplate.getAttribute(`data-${publicMethods.settings.resultAttribute_processResult}`);
			if (recordProcessFunction !== null) {
				recordProcessFunction = publicMethods.customUtils[recordProcessFunction];
				recordProcessFunction(row, cloneTemplate);
			}

			if (parentEle.tagName !== 'TBODY') {
				tbodyEle = cloneTemplate.closest('tbody');
				if (tbodyEle == null) {
					tbodyEle = parentEle.getElementsByTagName('tbody')[0];
				}

				if (tbodyEle == null) {
					console.log('cannot append');
					return;
				}

				tbodyEle.appendChild(cloneTemplate);
				return;
			}

			parentEle.appendChild(cloneTemplate); 

			if (columnIndexToHide.length) {
				const tableHeadings = parentTable.getElementsByTagName('thead')[0];
				if (tableHeadings !== null) {
					const headingChildren = tableHeadings.lastElementChild.children;					
					columnIndexToHide.forEach(colIndex => {
						// Hide column heading
						const colToHide = headingChildren[colIndex];
						if (typeof colToHide !== 'undefined' && (!colToHide.hasAttribute('hidden') || colToHide.getAttribute('hidden') !== true)) {
							colToHide.setAttribute('hidden', true);
						}
					});
				}

			}

		});

		// build pagination
		if (pagination) {
			ele.parent = parentTable.parentElement;
			buildPaging(ele, pagination);
		}

		// build filter
		const columnToFilter = parentTable.getAttribute(`data-${publicMethods.settings.dataTable_colFilter_key}`);
		if (columnToFilter !== null) {
			filterTableNav(parentTable, columnToFilter);
		}

		// alternately runUI bind
		if (checkOption(parentTable, 'bindUIActions') == 'true') {
			publicMethods.bindUIActions(parentEle);
		}
	};
	
	const populateArrayTemplate = function(ele, template, data) {
		// loop through the result rows
		data.forEach(row => {
			let cloneTemplate = template.cloneNode(true);
			cloneTemplate.id += data.indexOf(row);
			// loop through the template columns and fill in the values				
			var children = cloneTemplate.children;
			for (var i = 0; i < children.length; i++) {
				let child = children[i];
				const className = child.getAttribute(`data-${publicMethods.settings.resultAttribute_key_dataTable}`);

				if (!className.length) {
					continue;
				}

				let dataType = child.getAttribute(`data-${publicMethods.settings.resultAttribute_type_dataTable}`);
				if (dataType === null) {
					dataType = '';
				}

				switch (dataType.toUpperCase()) {
					case 'DATE':
						if (typeof child !== 'undefined' && typeof child.dataset !== 'undefined' && child.hasAttribute("data-type") && child.dataset.type == 'date') {
							child.innerHTML = formatDate(row[className]);
						}
						break;
					case 'TEMPLATE':
						populateTemplate(child, row);
						break;
					case 'DATAARRAY':
						populateArrayTemplate(child, row);
						break;
					default:
						child.innerHTML = row[className];
						break;
				}
			}

			unHide(cloneTemplate);
			ele.appendChild(cloneTemplate);
		});
		publicMethods.bindUIActions(ele);
	};

	const unHide = ele => {
		if (ele.hasAttribute('hidden')) {
			ele.removeAttribute('hidden');
		}

		if (ele.style.visibility.toLowerCase() == 'hidden') {
			ele.style.visibility = 'visible';
		}
	};

	const formatDate = function(dateStr) {
		if (!dateStr.length) {
			return '';
		}

		dateObj = new Date(dateStr);
		let formattedDateStr = dateObj.toLocaleString('en-US', { timeZoneName: 'short' });

		if (formattedDateStr == 'Invalid Date') {
			return 'false';
		}

		return formattedDateStr;
	}

	const populateLinkTemplate = function(ele, template, data) {
		const linkValueKey = template.getAttribute(`data-${publicMethods.settings.resultAttribute_key_dataTable}`);
		const linkCustomFunction = template.getAttribute(`data-${publicMethods.settings.resultAttribute_customFunction_dataTable}`);
		const postProcessFunction = template.getAttribute(`data-${publicMethods.settings.resultAttribute_post_process}`);
		const keys = Object.keys(template.dataset);
		let payload = {};

		// set data values
		keys.forEach(keyItem => {
			let keyValue = data[keyItem.toUpperCase()];
			if (typeof keyValue !== 'undefined') {
				let keyVar = template.dataset[`${keyItem}_var`];

				if (typeof keyVar !== 'undefined' && keyVar.length) {
					template.dataset[keyVar] = keyValue;
					payload[keyVar] = keyValue;
				} else {
					keyVar = template.dataset[keyItem];
					if (typeof keyVar !== 'undefined') {
						template.dataset[keyItem] = keyValue;
						payload[keyItem] = keyValue;
					}
				}
			} else if ( keyItem.toUpperCase() == 'HREF' && template.dataset[keyItem].length) {
				template.setAttribute('href', data[template.dataset[keyItem].toUpperCase()]); 
			}
		});

		// substitute with custom handling
		if (linkCustomFunction != null) {
			publicMethods.customUtils[linkCustomFunction](template, data, publicMethods);
			return;
		}

		// post Process function
		let listenerPostFunction = function(response, ele, publicMethods){};
		if (postProcessFunction != null) {
			listenerPostFunction = publicMethods.customUtils[postProcessFunction];
		}

		const disableLinkVar = checkOption(template, 'disableLinkVar');
		if (disableLinkVar !== null && disableLinkVar.length && template.dataset[disableLinkVar] == 'true') {
			template.setAttribute('href', 'javascript: void(0)'); 
			template.setAttribute('aria-disabled', 'true');
			template.setAttribute('alt', 'You do not have permission');
			template.classList.add('disabled');
			template.classList.remove(publicMethods.settings.endpointHtmlClass);
			template.classList.remove(publicMethods.settings.endpointClass);
		}
		
		if (linkValueKey != null) {
			link = document.createTextNode(data[linkValueKey.toUpperCase()]);
			template.appendChild(link);
		}

		const hideIfBlank = checkOption(template, 'hideBlank');
		if (hideIfBlank !== null 
			&& hideIfBlank.length 
			&& data[hideIfBlank.toUpperCase()].length < 1
		) {
			template.setAttribute('hidden', true);
		}

		publicMethods.bindUIActions(ele);
	}

	const addCss = function(fileName) {
		let head = document.head;
		let link = document.createElement("link");

		if (isIframe()) {
			head = parent.document.head; 
		} 
		
		link.type = "text/css";
		link.rel = "stylesheet";
		link.href = fileName;
		
		head.appendChild(link);
	}

	const isIframe = function() {
		if (publicMethods.settings.isIframe !== null) {
			return publicMethods.settings.isIframe;
		}

		let isIframe = false;
		try {
			isIframe = window.self !== window.top;
		} catch (e) {
			isIframe = true;
		}

		publicMethods.settings.isIframe = isIframe;
		return publicMethods.settings.isIframe;
	}

	const getElementOptions = (ele) => {
		let options = ele.getAttribute('data-options');
		let hasOptions = false;				
		try {
			options = JSON.parse(options);
			hasOptions = options !== null;
		} catch (error) {
			hasOptions = false;
		}
		return {
			hasOptions: hasOptions,
			options: options
		};
	}

	const checkOption = (ele, optKey) => {
		const eleOptionsData = getElementOptions(ele);
		if (!eleOptionsData.hasOptions || !eleOptionsData.options.hasOwnProperty(optKey)) {
			return null;
		}

		return eleOptionsData.options[optKey];
	}

	const checkBlankTableColumnData = data => {
		// works with an array of single layer structs. (table format)
		let returnData = {
			colsWithData: [],
			colsWithOutData: []
		};

		if (!Array.isArray(data)) {
			return returnData;
		}
		
		const keyList = Object.keys(data[0]);
		const hasValue = (value) => value !== undefined && value !== null && value.length;
		
		keyList.forEach(keyItem => {
			const populatedCol = data.some(item => hasValue(item[keyItem]));	
			if (populatedCol) {
				returnData.colsWithData.push(keyItem);
			} else {
				returnData.colsWithOutData.push(keyItem);
			}
		});

		return returnData;
	}

	const checkTableTemplateForHideBlank = tableRowTemplate => {
		// works with a tr of tds (table format)
		if (tableRowTemplate.tagName !== 'TR') {
			return [];
		}

		const children = [...tableRowTemplate.children];
		return children.map( child => {
			if (checkOption(child, 'hideBlank') === 'true') {
				return child.getAttribute(`data-${publicMethods.settings.resultAttribute_key_dataTable}`);
			}
			return null;
		}).filter(n => n);
	}

	const buildPaging = (ele, pagination) => {
		if (pagination.totalPages < 2) {
			if (ele.navElement) {
				ele.parent.removeChild(ele.navElement);
				delete ele.navElement;
			}
			return;
		}

		if (!ele.navElement) {
			ele.navElement = document.createElement('nav');
			ele.navElement.setAttribute('aria-label', 'Data page navigation');
			ele.navElement.navList = document.createElement('ul');
			ele.navElement.navList.classList.add('pagination');
			ele.navElement.appendChild(ele.navElement.navList);
			ele.parent.appendChild(ele.navElement);
		}
		ele.navElement.navList.innerHTML = '';

		let navItem = {};
		navItem.element = document.createElement('li');
		navItem.element.classList.add('page-item');
		navItem.linkEle = document.createElement('a'); // set attributes for make request
		navItem.linkEle.classList.add('page-link');
		navItem.linkEle.classList.add('makeRequest');
		navItem.linkEle.href = pagination.pagingLink;
		navItem.linkEle.dataset.method = "GET";
		navItem.linkEle.setAttribute(`data-${publicMethods.settings.endpointTargetId_button}`, ele.id);
		navItem.element.appendChild(navItem.linkEle);
		
		for (let i = 1; i <= pagination.totalPages; i++) {
			if (pagination.page == i) {
				navItem.element.classList.add('active');
				navItem.element.classList.add('disabled');
			} else {
				navItem.element.classList.remove('active');
				navItem.element.classList.remove('disabled');
			}

			navItem.linkEle.dataset.page = i;
			navItem.linkEle.textContent = 'page '+ i;
			ele.navElement.navList.appendChild(navItem.element.cloneNode(true));
		}

		publicMethods.bindUIActions(ele.navElement.navList);
	};

	const filterTableNav = (table, columnNumber) => {
		if (table.columnFilter) {
			table.parentElement.removeChild(table.columnFilter.filterNav);
			delete table.columnFilter;
		}

		table.columnFilter = {
			filterColumn: columnNumber,
			rowsByValue: {},
			filterNav: document.createElement('div')
		};

		table.columnFilter.filterNav.classList.add('btn-group');
		table.columnFilter.filterNav.classList.add('mt-5');
		let td, tdValue, tempButton;
		let rowValueObjTemplate = {
			filterButton: null,
			filterRows: []
		};

		let filterButton = document.createElement('a');
		filterButton.classList.add('btn');
		filterButton.classList.add('btn-primary');
		filterButton.dataset.colval = 'ALL';
		filterButton.textContent = 'All';
		filterButton.href = '#';
		filterAllButton = filterButton.cloneNode(true);
		table.columnFilter.filterNav.appendChild(filterAllButton);

		table.querySelectorAll("tr").forEach((row) => {
			td = row.getElementsByTagName("td")[columnNumber];
			if (!td || row.classList.contains(publicMethods.settings.resultTemplateClass_dataTable)){
				return;
			}
			tdValue = td.textContent || td.innerText;

			if (!table.columnFilter.rowsByValue.hasOwnProperty(tdValue)) {
				table.columnFilter.rowsByValue[tdValue] = structuredClone(rowValueObjTemplate);
				tempButton = filterButton.cloneNode(true);
				tempButton.dataset.colval = tdValue;
				tempButton.textContent = tdValue.toLowerCase().replace(/\b\w/g, s => s.toUpperCase());
				table.columnFilter.rowsByValue[tdValue].filterButton = tempButton;
				table.columnFilter.filterNav.appendChild(table.columnFilter.rowsByValue[tdValue].filterButton);
			}
			table.columnFilter.rowsByValue[tdValue].filterRows.push(row);
		});

		const keyArray = Object.keys(table.columnFilter.rowsByValue);
		if (keyArray.length < 2) {
			// abort if only 1 col value
			delete table.columnFilter;
			return;
		}
		let allCount = 0;
		keyArray.forEach(keyItem => {
			let valueObj = table.columnFilter.rowsByValue[keyItem];
			valueObj.filterButton.textContent += ' -- '+ valueObj.filterRows.length;
			allCount += valueObj.filterRows.length;
			bindFilterTableColumn(valueObj.filterButton, table);
		});
		filterAllButton.textContent += ' -- '+ allCount;
		bindFilterTableColumn(filterAllButton, table);		

		table.parentElement.prepend(table.columnFilter.filterNav);
	}

	const bindFilterTableColumn = (link, table) => {
		const keyArray = Object.keys(table.columnFilter.rowsByValue);
		
		link.addEventListener('click', function(event) {
			event.preventDefault();			
			keyArray.forEach(filterKey => {
				let valueObjects = table.columnFilter.rowsByValue[filterKey].filterRows;
				valueObjects.forEach(row =>{
					if (link.dataset.colval == 'ALL' || link.dataset.colval == filterKey) {
						row.removeAttribute('hidden');
						return;
					} else {
						row.setAttribute('hidden', true);
					}
				});
			});
			return false;
		});
	}

/*******************
	Request Methods
*******************/
	// login and return jwt token (or promise)
	const getJwt = async function() {
		// check if the token expiration has passed and return existing token if not
		const getNowTime = new Date(Date.now()).getTime();
		if (publicMethods.settings.jwt.length && publicMethods.settings.jwtExpires > getNowTime) {
			return {
				'jwt': publicMethods.settings.jwt,
				'jwtRefresh': publicMethods.settings.jwtRefresh,
			};
		}

		if (publicMethods.settings.jwtRefresh.length && publicMethods.settings.jwtExpires <= getNowTime) {
			publicMethods.settings.jwtRefresh = '';
			// attempt refresh
			let jwtRefresh = makeRequest(
				publicMethods.settings.baseUrl + 'api/refresh', 
				{method: 'POST'},
				function(result) {
					if (result.data.error) {
						publicMethods.settings.jwtRefresh = '';
						return {
							'jwt': '',
							'jwtRefresh': '',
						};
					}
					publicMethods.settings.jwt = result.data.access_token;
					publicMethods.settings.jwtRefresh = result.data.refresh_token;
					publicMethods.settings.jwtExpires = new Date(Date.now() + result.data.access_token_expiry * 1000).getTime();
					return {
						'jwt': publicMethods.settings.jwt,
						'jwtRefresh': publicMethods.settings.jwtRefresh,
					};
				},
				'refresh'
			);
			return await jwtRefresh;
		}

		// Send auth request to get token
		let jwtReturn = makeRequest(
			publicMethods.settings.baseUrl + 'api/login', 
			{	method: 'POST',
				body: JSON.stringify({
					'username': publicMethods.settings.userName
				})
			},
			function(result) {
				if (result.data.error) {
					return {
						'jwt': '',
						'jwtRefresh': '',
					};
				}
				publicMethods.settings.jwt = result.data.access_token;
				publicMethods.settings.jwtRefresh = result.data.refresh_token;
				publicMethods.settings.jwtExpires = new Date(Date.now() + result.data.access_token_expiry * 1000).getTime();
				return {
					'jwt': publicMethods.settings.jwt,
					'jwtRefresh': publicMethods.settings.jwtRefresh,
				};
			},
			'login'
		);

		// return the token request object 
		return jwtReturn;
	}

const makeRequest = async function(url, options, processFunction, type = '', ele = null, event = null) {
	// check for valid url with no double slash (//)
	if (!url.match(/^((?!\/\/).||(https?\:\/\/))*$/)) {
		appendAlert('Could not make request', 'danger', 10000);
		console.log(`Bad API Call: ${url}`);
		return;
	}

	// skip sending token if a login request
		let fileName = '';
		if (type.toUpperCase() !== 'LOGIN') {
			appendAlert('Loading Data', 'warning');
			let jwt = await getJwt();
			const fetchHeaders = new Headers();
			fetchHeaders.append("x-auth-token", jwt.jwt);
			fetchHeaders.append("x-refresh-token", jwt.jwtRefresh);
			if (type.toUpperCase() == 'FILE') {
				fetchHeaders.append("Accept", "application/octet-stream");
			} 
			options.headers = fetchHeaders;
		}

		// make request
		return fetch(url, options)
			.then((response) => {
				// catch any status errors and prep for data processing
				let message = '';
				switch(response.status) {
					case 200:
						if (type.toUpperCase() == 'FILE') {
							fileName = response.headers.get("content-disposition");
							return response.blob();
						} else if (type.toUpperCase() == 'HTML') {
							return response;
						}
						return response.json();
					case 201:
						return response.json();
					case 401:
						// invalidate auth
						publicMethods.settings.jwtExpires = new Date(Date.now()).getTime();
						message = `Failed Auth: ${response.status} - ${response.statusText}`;
						// retry
						return makeRequest(
							url, 
							options, 
							processFunction, 
							type, 
							ele,
							event
						);
					default:
						message = `Failed Response: ${response.status} - ${response.statusText}`;
				}			
				throw new Error(message, {cause: response.json()});
			})
			.then((result) => {
				if (type.toUpperCase() == 'FILE') {
					// Download file with name
					appendAlert('Loaded File', 'success', 2000);
					
					let parsedFileName = 'Download';
					if (fileName !== null) {
						parsedFileName = fileName.replace('attachment; ', '').split('filename=').filter(Boolean)[0].replaceAll(/[,\s\"]/g, '');
					}
					
					saveData(result, parsedFileName);
					return false;

				} else if (type.toUpperCase() == 'HTML') {
					// return an HTML Promise
					appendAlert('Loaded File', 'success', 2000);
					if (typeof result == 'string') {
						return result;
					}
					return result.text();
				}

				if (result.error) {
					// catch any other errors
					throw new Error(result.messages[0]);
				}

				if (type.toUpperCase() !== 'LOGIN') {
					// replace alert with timed success alert
					appendAlert(`Loaded ${result.messages.length ? ':'+ formatMessageArray(result.messages) : ''}`, 'success', 4000);
				}

				if (type.toUpperCase() == 'AUTOLOAD') {
					// return an Promise
					return result;
				}
				
				// send to processing function
				return processFunction(result, ele, publicMethods, event);
			})
			.catch((errorMsg) => { 
				// Handle any errors
				if (errorMsg.cause) {
					errorMsg.cause.then((response) => {
						if (response.messages) {
							appendAlert(`${errorMsg.message} <br />${formatMessageArray(response.messages)}`, 'danger');
						}
					});
				} else {
					console.log(errorMsg);
					appendAlert(errorMsg, 'danger', 10000);
				}
			})
		;
	};

	const saveData = function (data, fileName) {
		let parentObj = document;
		if (isIframe()) {
			parentObj = parent.document;
		}

		const file = window.URL.createObjectURL(data);
		let a = parentObj.createElement("a");
		a.style = "display: none";
		a.href = file;
		a.download = fileName.trim();
		parentObj.body.appendChild(a);

		a.click();
		window.URL.revokeObjectURL(file);
		a.remove();
	};

	/*******************
    * Autocomplete Methods
    ******************/
const bindAutocomplete = function(bindElement) {
	if (typeof bindElement === 'undefined') {
		bindElement = document;
	}
	// Find input elements with the specified class
	let inputElements = bindElement.querySelectorAll(`.${publicMethods.settings.autocompleteClass}`);

	inputElements.forEach(input => {
		input.addEventListener('input', function(event) {
			let endpoint = publicMethods.settings.baseUrl + 
				input.getAttribute(`data-${publicMethods.settings.autocompleteEndpoint}`);

			if (!input.autoCompleteRequest && endpoint && input.value.length % 3 === 0) {
				input.autoCompleteRequest = true;
				setTimeout(() => {
					let searchValue = input.value;
					endpoint += `?searchQuery=${searchValue}`;
					// Make the autocomplete request
					makeRequest(
						endpoint,
						{ method: 'GET' },
						function(response) {
							// Handle the autocomplete response
							populateAutocomplete(input, response.data);
							input.autoCompleteRequest = false;
						},
						'autocomplete'
					);
				}, 600);
			} else {
				// Clear the autocomplete suggestions if the input is less than 3 characters or endpoint is not defined
				// clearAutocomplete(input);
			}
		});
	});
};

const populateAutocomplete = function(input, suggestions) {
	let dlObj = input.parentElement.querySelector(`#${input.id}_list`);
	if (dlObj != null) {
		input.autocompleteList = dlObj;
		input.autoCompleteElement = input.parentElement;
	}

	// Create the autocomplete list element if it doesn't exist
	if (input.autocompleteList == null) {
        input.autocompleteList = document.createElement('datalist');
		input.autocompleteList.id = `${input.id}_list`;
		input.autoCompleteElement = input.parentElement;
        input.autoCompleteElement.appendChild(input.autocompleteList); // Append to the parent element
		input.setAttribute('list', `${input.id}_list`);
    }

	// Clear existing suggestions
	input.autocompleteList.innerHTML = '';

	// Populate suggestions
	suggestions.forEach(suggestion => {
		const listItem = document.createElement('option');
		listItem.textContent = suggestion.LABEL;
		listItem.value = suggestion.ID;
		input.autocompleteList.appendChild(listItem);
	});
};

const clearAutocomplete = function(input) {
	if (input.autocompleteList) {
		// input.autocompleteList.classList.remove('show');
		input.autocompleteList.innerHTML = '';
	}
};
	
/***********************
 * result processing
***********************/

	// public methods
	let publicMethods = {
		init: init,
		uiObjects: {
			alertBox: null
		},
		actionButtons: {},
		settings: settings,
		makeRequest: makeRequest,
		bindAutocomplete: bindAutocomplete,
		bindLinkListener: bindLinkListener,
		populateTemplate: populateTemplate,
		clearAutocomplete: clearAutocomplete,
		populateAutocomplete: populateAutocomplete,
		clearTemplate: clearTemplate,
		bindUIActions: bindUIActions,
		loadHtml: loadHtml,
		autoLoad: autoLoad,
		autoLoadOnHtml: function() {}, // custom js to be run everytime html is loaded
		customUtils: {}
	};

	return publicMethods;
};

const sleepUntil = async (f, timeoutMs) => {
	return new Promise((resolve, reject) => {
		const timeWas = new Date();
		const wait = setInterval(function() {
			if (f()) {
				clearInterval(wait);
				resolve();
			} else if (new Date() - timeWas > timeoutMs) { // Timeout
				clearInterval(wait);
				reject();
			}
		}, 20);
	});
};

/* 
	[ ] share credentials accross modules
	[ ] clearTemplate on click not load
	[ ] hide elements with no data
*/