component extends="testbox.system.BaseSpec"{
     function beforeTests(){
     	variables.testPath = getDirectoryFromPath(getCurrentTemplatePath()) & "sources\";
		variables.inputFile  = "markdown_test_doc.md";
     }
     
     function afterTests(){}

     function setup( currentMethod ){}
     function teardown( currentMethod ){}

	/**
	* @test
	*/
	function createComponent(){
		try {
			local.markdown = createObject("component","markdown.flexmark").init();
		}
		catch (Any e) {
				$assert.fail( "Failed to create flexmakr component");
		}
	}
	/**
	* @test
	*/
	function parseDocument(){
		try {
			local.markdown = createObject("component","markdown.flexmark").init();
			local.mytest = FileRead(variables.testpath & variables.inputFile,"utf-8");
			local.doc = local.markdown.markdown(local.mytest,{},variables.testpath);

		}
		catch (Any e) {
				$assert.fail( "Failed to parse document #e.message#");
		}
	}
}