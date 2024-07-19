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
	 * Sets an object in the storage
	 *
	 * @objectKey         The object key
	 * @object            The object to save
	 * @timeout           Timeout in minutes, or cacheTime format (0d 0h 0m 0s)
	 * @lastAccessTimeout Idle Timeout in minutes, or cacheTime format (0d 0h 0m 0s)
	 * @extras            Not implemented. Here for compatibility with CacheBox only.
	 */
	void function set(
		required objectKey,
		required object,
		timeout           = "",
		lastAccessTimeout = "",
		extras            = {}
	) {

		if( findOneOf( 'dhms', arguments.timeout ) ) {
			// get the timespan for the timeout passed in
			ttl = getTimespanFromCacheTime( arguments.timeout );
		} else if( isNumeric( arguments.timeout ) ) {
			ttl = createTimeSpan( 0, 0, arguments.timeout, 0 );
		} else {
			ttl = createTimeSpan( 0, 0, 15, 0 );
		}
		
		if( findOneOf( 'dhms', lastAccessTimeout ) ) {
			// get the timespan for the lastAccessTimeout passed in
			lattl = getTimespanFromCacheTime( arguments.lastAccessTimeout );
		} else if( isNumeric( arguments.lastAccessTimeout ) ) {
			lattl = createTimeSpan( 0, 0, arguments.lastAccessTimeout, 0 );
		} else {
			lattl = int( ttl/2 );
		}

		// put the item into the cache
		cachePut(
			getEntity() & arguments.objectKey,
			arguments.object,
			ttl,
			lattl
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
