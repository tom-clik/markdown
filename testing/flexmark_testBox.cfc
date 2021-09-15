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
			local.markdown = new markdown.flexmark();
		}
		catch (Any e) {
				$assert.fail( "Failed to create flexmark component");
		}
	}
	/**
	* @test
	*/
	function parseDocument(){
		try {
			local.markdown = new markdown.flexmark();
			local.mytest = FileRead(variables.testpath & variables.inputFile,"utf-8");
			local.doc = local.markdown.markdown(local.mytest,{},variables.testpath);

		}
		catch (Any e) {
				$assert.fail( "Failed to parse document #e.message#");
		}
	}
}