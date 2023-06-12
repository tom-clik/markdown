// preview on /flexmark_testBox.cfc?method=runRemote

component extends="testbox.system.BaseSpec"{
     function beforeTests(){
     	variables.testPath = getDirectoryFromPath(getCurrentTemplatePath()) & "sources\";
		variables.inputFile  = "markdown_test_doc.md";
		variables.yaml  = "yaml.md";
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
	/**
	* @test
	*/
	function simpleConverions(){
		try {
			local.markdown = new markdown.flexmark();
			local.mytest = FileRead(variables.testpath & variables.inputFile,"utf-8");
			local.doc = local.markdown.toHtml(local.mytest);

		}
		catch (Any e) {
				$assert.fail( "Failed to parse document #e.message#");
		}
	}
	/**
	* @test
	*/
	function yaml(){
		local.title = "The Life and Adventures of Robinson Crusoe";
		try {
			local.markdown = new markdown.flexmark(attributes=1);
			local.mytest = FileRead(variables.testpath & variables.yaml,"utf-8");
			local.data = {};
			local.html = local.markdown.toHtml(local.mytest,local.data);
			local.doc = local.markdown.markdown(local.mytest);
			
		}
		catch (Any e) {
			$assert.fail( "Failed to parse document #e.message#");
		}
		$assert.isEqual( StructCount( local.data ) ,3 ) ;
		$assert.isEqual( local.data.title ,  local.title ) ;
		$assert.isEqual( local.doc.data.meta.title , local.title ) ;
	}
}