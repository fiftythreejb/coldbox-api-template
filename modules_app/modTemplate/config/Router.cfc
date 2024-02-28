component{

	function configure(){
		patch("/").to("modTemplate.update");
		get(pattern = "/", target = "modTemplate.index");
		
		route(pattern="/:action").toHandler("modTemplate");
		route( "/:handler/:action?").end();
	}

}