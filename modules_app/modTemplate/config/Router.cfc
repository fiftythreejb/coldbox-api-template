component{

	function configure(){
		patch("/").to("modTemplate.update");
		route(pattern="/:action").toHandler("modTemplate");
		get(pattern = "/", target = "modTemplate.index");
		route( "/:handler/:action?").end();
	}

}