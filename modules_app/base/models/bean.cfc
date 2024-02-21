component output="false" displayname="base.bean" accessors="true"  {

	/**
	* @displayname  getUidHash
	* @description  I return a hashed string version of the primary key of the bean that extends this bean
	* @param 		format {String} I am the format of the hash - one of 'url' (default) or 'form'
	* @return		string
	*/
	public string function getUidHash( string format = 'url' ) {

		// get the cached uid hash for this bean and format
		var hashUid = cacheGet( 'hash_uid_' & arguments.format & '_' & hash( getCurrentTemplatePath() ) );

		// check if the cached version exists
		if( isNull( hashUid ) ) {

			// it doesn't, check which format the hash should be in
			if( arguments.format eq 'form' ) {
				// it should be 'form' format, generate the form based uid hash
				// NOTE: Adjust the iterations of this hash to make it unique to your application
				// e.g. '84' iterations instead of '30'
				hashUid = 'f' & application.securityService.uberHash( getPrimaryKey(), 'SHA-512', 79 );
			// otherwise
			} else {
				// it should be 'url' format, generate the url based uid hash
				// NOTE: Adjust the iterations of this hash to make it unique to your application
				// e.g. '49' iterations instead of '15'
				hashUid = 'v' & application.securityService.uberHash( getPrimaryKey(), 'SHA-384', 39 );
			}

			// and put this format hash uid into the cache for 30 mins, 15 mins idle
			// NOTE: adjust the cache times for longer durations in production
			cachePut( 'hash_uid_' & arguments.format & '_' & hash( getCurrentTemplatePath() ), hashUid, createTimeSpan( 0, 0, 30, 0 ), createTimeSpan( 0, 0, 15, 0 ) );
		}

		return hashUid;
	}

	/**
	* @displayname  getTokenKeyHash
	* @description  I return a standard hashed value for the CSRF token key variable
	* @return		string
	*/
	public string function getTokenKeyHash() {
		// get the cached token key hash
		var tokenKeyHash = cacheGet( 'token_key_hash' );

		// check if the cached version exists
		if( isNull( tokenKeyHash ) ) {
			// it doesn't, generate the token key hash
			// NOTE: Adjust the value and iterations of this hash to make it unique to your application
			// e.g. 'powerTokenKey' instead of 'tokenKey' and '28' iterations instead of '45'
			tokenKeyHash = 'f' & application.securityService.uberHash( 'tokenKey', 'SHA-512', 121 );

			// and put it into the cache for 30 mins, 15 mins idle
			// NOTE: adjust the cache times for longer durations in production
			cachePut( 'token_key_hash', tokenKeyHash, createTimeSpan( 0, 0, 30, 0 ), createTimeSpan( 0, 0, 15, 0 ) );
		}

		return tokenKeyHash;
	}

	/**
	* @displayname  getTokenHash
	* @description  I return a standard hashed value for the CSRF token variable
	* @return		string
	*/
	public string function getTokenHash() {
		// get the cached token hash
		var tokenHash = cacheGet( 'token_hash' );

		// check if the cached version exists
		if( isNull( tokenHash ) ) {
			// it doesn't, generate the token hash
			// NOTE: Adjust the value and iterations of this hash to make it unique to your application
			// e.g. 'powerToken' instead of 'token' and '72' iterations instead of '69'
			tokenHash = 'f' & application.securityService.uberHash( 'token', 'SHA-512', 47 );

			// and put it into the cache for 30 mins, 15 mins idle
			// NOTE: adjust the cache times for longer durations in production
			cachePut( 'token_hash', tokenHash, createTimeSpan( 0, 0, 30, 0 ), createTimeSpan( 0, 0, 15, 0 ) );
		}

		return tokenHash;
	}

	/**
	* @displayname  getEncUid
	* @description  I return an encrypted string version of the primary key of the bean that extends this bean
	* @param 		format {String} I am the format of the encryption - one of 'url' (default) or 'form'
	* @return		string
	*/
	public string function getEncUid( string format = 'url' ) {

		// check if we're using form encrytion format
		if( arguments.format eq 'form' ) {
			// we are, return the form encrypted primary key
			return application.securityService.dataEnc( evaluate( "get#getPrimaryKey()#()" ), 'form' );
		// otherwise
		} else {
			// we're using url encryption, return the url encrypted primary key
			return application.securityService.dataEnc( evaluate( "get#getPrimaryKey()#()" ), 'url' );
		}
	}

	/**
	* @displayname  getDecUid
	* @description  I return a decrypted string version of the passed in guid
	* @param 		encGuid {String} I am the encrypted guid to decrypt
	* @param 		format {String} I am the format of the encryption - one of 'url' (default) or 'form'
	* @return		string
	*/
	public string function getDecUid( required string encGuid, string format = 'url' ) {

		// check if we're using form decrytion format
		if( arguments.format eq 'form' ) {
			// we are, return the decrypted guid using form decryption
			return application.securityService.dataDec( arguments.encGuid, 'form' );
		// otherwise
		} else {
			// we're using url decryption, return the decrypted guid using url decryption
			return application.securityService.dataDec( arguments.encGuid, 'url' );
		}
	}

	/**
	* @displayname  getPrimaryKey
	* @description  I return the primary key of the bean that extends this bean
	* @return		string
	*/
	public string function getPrimaryKey() {

		var primaryKey = '';
		var metaProperty = '';

		// get component metadata from the cache
		var metaData = getThisMetaData();

		// get the primary key from the cache using the metadata information
		primaryKey = cacheGet( metaData.name & '_primary_key' );

		// check that we have a cached primary key
		if( isNull( primaryKey ) ) {
			// we don't, loop through the components properties
			for( metaProperty in metaData.properties ) {
				// check if the 'primary' attribute is set on this property and is true
				if( structKeyExists( metaProperty, 'primary' ) and metaProperty.primary ) {
					// it does, set the primary key value to this properties name
					primaryKey = metaProperty.name;
					// and store it in the cache for 30 mins / 15 mins idle
					// NOTE: adjust the cache times for longer durations in production
					cachePut( metaData.name & '_primary_key', primaryKey, createTimeSpan( 0, 0, 30, 0 ), createTimeSpan( 0, 0, 15, 0 ) );
					// and break out of the loop since we have our primary key now
					break;
				}
			}
		}

		// return the primary key name
		return primaryKey;
	}

	/**
	* @displayname  getJson
	* @description  I return a serialized json string of the current beans memento
	* @return		string
	*/
	public string function getJson() {
		return serializeJSON( getMemento() );
	}

	/**
	* @displayname  doImport
	* @description  helper function to do a mass import of data
	* @return       void
	*/
	public void function doImport( required struct importData ) {
		var memento = getMemento();
		for( var field in memento ) {
			if( structKeyExists( arguments.importData, field ) ) {
				variables[ field ] =  arguments.importData[ field ];
			}
		}
	}

	/**
	* @displayname  populate
	* @description  I return a populated bean with properties set to any matching struct keys in beanData
	*
	* @return		any
	*/
	public any function populate( required struct beanData, required array decryptFields = [] ) {
		var propertyValue = '';
		var colKey = '';
		var colKeyNoUnderscores = '';

		var decryptFieldsArr = arrayMap( duplicate( arguments.decryptFields ), function( _item ) {
			return listFirst( _item, ':' );
		} );

		var decryptAlgArr = arrayMap( duplicate( arguments.decryptFields ), function( _item ) {
			return listLast( _item, ':' );
		} );

		// get component columns as array from the cache
		var beanColumnArray = getColumnArray();

		// loop through the components properties to assign properties values based on input struct
		for( colKey in arguments.beanData ) {
			// remove _ from field names if there are any
			colKeyNoUnderscores = find( '_', colKey ) ? replace( colKey, '_', '', 'ALL' ) : colKey;

			// check if the attribute exists in the input struct
			if( beanColumnArray.findNoCase( colKeyNoUnderscores ) and len( trim( arguments.beanData[ colKey ] ) ) ) {
				// set the default value
				propertyValue = arguments.beanData[ colKey ];

				// see if this field is encrypted in the DB and decrypt if yes
				if( arrayLen( decryptFieldsArr ) && arrayFind( decryptFieldsArr, colKey ) ) {
					propertyValue = len( arguments.beanData[ colKey ] ) ? application.securityService.dataDec( arguments.beanData[ colKey ], ( arrayLen( decryptAlgArr ) >= arrayFind( decryptFieldsArr, colKey ) ? decryptAlgArr[ arrayFind( decryptFieldsArr, colKey ) ] : 'db' ) ) : '';
				}

				variables[ colKeyNoUnderscores ] = propertyValue;
			}
		}

		// return the primary key name
		return this;
	}

	public struct function getMemento() {
		var memento = {};
		var metaProperty = '';

		// get component metadata from the cache
		var metaData = getThisMetaData();

		// loop through the components properties to build memento struct
		for( metaProperty in metaData.properties ) {
			memento[ metaProperty.name ] = variables[ metaProperty.name ];
		}

		return memento;
	}

	public array function getColumnArray() {

		// get component metadata from the cache
		var metaData = getThisMetaData();
		var metaProperty = '';

		//get column array from cache
		var columnArray = cacheGet( 'bean_column_array_' & hash( getCurrentTemplatePath() ) );

		// check that the column array exists in the cache
		if( isNull( columnArray ) ) {
			columnArray = [];

			// loop through the components properties to build column array
			for( metaProperty in metaData.properties ) {
				columnArray.append( metaProperty.name );
			}
			// NOTE: adjust the cache times for longer durations in production
			cachePut( 'bean_column_array_' & hash( getCurrentTemplatePath() ), columnArray, createTimeSpan( 0, 1, 0, 0 ), createTimeSpan( 0, 0, 15, 0 ) );
		}

		return columnArray;
	}

	public struct function getThisMetaData() {
		// get component metadata from the cache
		var metaData = cacheGet( 'bean_meta_' & hash( getCurrentTemplatePath() ) );

		// check that the component metadata exists in the cache
		if( isNull( metaData ) ) {
			// it doesn't, get the components meta data
			metaData = getMetaData( this );
			// and store it in the cache for 30 mins / 15 mins idle
			// NOTE: adjust the cache times for longer durations in production
			cachePut( 'bean_meta_' & hash( getCurrentTemplatePath() ), metaData, createTimeSpan( 0, 0, 30, 0 ), createTimeSpan( 0, 0, 15, 0 ) );
		}

		return metaData;
	}
    
}