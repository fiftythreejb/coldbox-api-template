component displayname="base.dao" accessors="true" singleton {

	property name="dsn" inject="coldbox:configSettings:datasource";

	public function init() {
		return this;
	}

    public any function queryToStruct(
        required query inQuery,
        boolean forceArray = false,
        query row
    ) {
		var localStruct = StructNew();
		var resultStruct = StructNew();
		var idx = "";
		var colName = "";
		var columnLabels = arguments.inQuery.columnArray();

        if ( isDefined( "arguments.row" ) ) {
            localStruct.row = arguments.row;
        } else {
            localStruct.row = 1;
        }

        if ( isDefined( "localStruct.row" ) && !arguments.forceArray ) {
            for (currentIndex in columnLabels) {
                structInsert( resultStruct, currentIndex, arguments.inQuery[currentIndex][localStruct.row] );
            }
        } else if ( isDefined( "localStruct.row" ) ) {
            resultStruct = arrayNew( 1 );
            arrayAppend( resultStruct, structNew() );
            for (currentIndex in columnLabels) {
                structInsert( resultStruct[1], currentIndex, arguments.inQuery[currentIndex][localStruct.row] );
            }
        } else {
            resultStruct = arrayNew( 1 );
            for ( i = 1; i <= arguments.inQuery.recordCount; i++ ) { 
                tempStruct = structNew();
                for (currentIndex in columnLabels) {
                    structInsert( tempStruct, currentIndex, arguments.inQuery[currentIndex][i] );
                }
                arrayAppend( resultStruct, tempStruct );
            }
        }

        return resultStruct;
    }
}