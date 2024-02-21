component accessors="true" {

	property name="entity" type="string" default="";

	/**
	* @displayname 	init
	* @description 	I initialize this singleton for a specific entity
	* @entity 		I am the entity (cache region) to use
	* @return		this
	*/
	public function init(
		required string entity
	) {
		// set the entity property
		setEntity( arguments.entity & ( !find( '_', right( arguments.entity, 1 ) ) ? '_' : '' ) );

		// return this singleton
		return this;
	}

	/**
	* @displayname 	get
	* @description 	I get an entity from the entities cache
	* @itemName 	I am the name of the item stored in cache
	* @return		any
	*/
	public any function get(
		required string itemName
	) {
		// do a standard cacheGet() for this entities cache region
		return cacheGet( getEntity() & arguments.itemName );
	}


	/**
	* @displayname 	set
	* @description 	I put an entity into the entities cache
	* @itemName 	I am the name of the item stored in cache
	* @item 		I am the item to store in the cache (struct, array, object, string, etc.)
	* @cacheTime 	I am a human readable number of days, hours, minutes and seconds in the format: Xd Xh Xm Xs
	*/
	public void function set(
		required string itemName,
		required any item,
		string cacheTime = "15m"
	) {
		// get the timespan for the cacheTime passed in
		var ttl = getTimespanFromCacheTime( arguments.cacheTime );

		// put the item into the cache
		cachePut(
			getEntity() & arguments.itemName,
			arguments.item,
			ttl,
			( ttl / 2 )
		);
	}

	/**
	* @displayname 	getTimespanFromCacheTime
	* @description 	I convert the human readable cacheTime into a CF usable timespan
	* @cacheTime 	I am a human readable number of days, hours, minutes and seconds in the format: Xd Xh Xm Xs
	* @return		any
	*/
	public any function getTimespanFromCacheTime(
		required string cacheTime
	) {

		// get the cacheTime timespan from cache
		var timespan = cacheGet( arguments.cacheTime & '_timespan' );

		// check if we have it in cache
		if( !isNull( timespan ) ) {

			// we do, return the timespan
			return timespan;

		}

		// get the zero timespan from cache
		timespan = cacheGet( '_zero_timespan' );

		// check tha we have it in cache
		if( isNull( timespan ) ) {

			// we don't, create a timespan struct
			timespan = {
				'd' = 0,
				'h' = 0,
				'm' = 0,
				's' = 0
			};

			// and put the zero timespan struct in the cache for next use
			cachePut(
				listFirst( cgi.server_name, '.' ) & '_zero_timespan',
				timespan,
				createTimespan( 365, 0, 0, 0 )
			);
		}

		// loop through any space separated elements in cacheTime
		for( var element in listToArray( arguments.cacheTime, ' ' ) ) {

			// switch on the letter d, h, m or s in the cacheTime element
			// and add any values to the appropriate day, hour, mnute and second value
			switch( right( element, 1 ) ) {

				case 'd':
					timespan[ 'd' ] += val( element );
				break;

				case 'h':
					timespan[ 'h' ] += val( element );
				break;

				case 'm':
					timespan[ 'm' ] += val( element );
				break;

				case 's':
					timespan[ 's' ] += val( element );
				break;
			}
		}

		// create a timespan value from the timespan struct
		timespan = createTimespan( timespan[ 'd' ], timespan[ 'h' ], timespan[ 'm' ], timespan[ 's' ] );

		// store that value in the cache so it doesn't have to be recalculated later
		cachePut(
			arguments.cacheTime & '_timespan',
			timespan,
			createTimespan( 365, 0, 0, 0 )
		);

		// return the timespan
		return timespan;
	}
}
