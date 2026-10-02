<!---
A simple component to apply local defaults for our JARS
--->
component extends="markdown.flexmark" {

	function init(jsoup = "jsoup-1.22.1.jar", flexmark= "flexmark-all-0.64.0-lib.jar") {
		
		if (! IsDefined("server.system.environment.javalib") ) {
			throw("server.system.environment.javalib not defined.")
		}

		this.jsoupJarPath = server.system.environment.javalib & "\" & arguments.jsoup;
		if (! FileExists( this.jsoupJarPath ) ) { throw("JSOUP jar file (#this.jsoupJarPath#) not found");}

		this.flexmarkPath = server.system.environment.javalib & "\" & arguments.flexmark;

		if (! FileExists( this.flexmarkPath ) ) { throw("Flexmark jar file (#this.flexmarkPath#) not found");}

		this.coldsoupObj = new coldsoup.coldSoup(jarpath=this.jsoupJarPath);
		
		super.init(attributes="true",typographic=true,coldsoupObj=this.coldsoupObj,jarpath=this.flexmarkPath);

		return this;

	}


}