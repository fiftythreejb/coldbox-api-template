component displayname="base.dao" accessors="true" singleton {

	property name="dsn" inject="coldbox:configSettings:datasource";

	public function init() {
		return this;
	}

}