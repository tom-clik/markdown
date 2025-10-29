// preview on /wripper_testBox.cfc?method=runRemote

component extends="testbox.system.BaseSpec"{
     
     function beforeTests(){
     	variables.jsoupJarPath = server.system.environment.javalib & "\jsoup-1.20.1.jar";
     	variables.testPath = getDirectoryFromPath(getCurrentTemplatePath()) & "sources\";
		variables.inputFile  = "wripper_test_doc2.htm";
     }
     
     function afterTests(){}

     function setup( currentMethod ){}
     
     function teardown( currentMethod ){}

	/**
	* @test
	*/
	function createComponent(){
		try {
			local.wripper = new markdown.tools.wripper(variables.jsoupJarPath);
		}
		catch (Any e) {
			$assert.fail( "Failed to create wripper component");
		}
	}
	/**
	* @test
	*/
	function parseDocument(){
		try {
			local.wripper = new markdown.tools.wripper(variables.jsoupJarPath);
			local.mytest = FileRead(variables.testpath & variables.inputFile,"utf-8");
			local.doc = local.wripper.wrip(local.mytest);

		}
		catch (Any e) {
			$assert.fail( "Failed to parse document #e.message#");
		}
	}
	
}