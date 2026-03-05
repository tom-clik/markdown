<!---

# Convert markdown to HTML and process mustache template

Options to save HTML and convert to PDF can be supplied as URL parameters or YAML variables

## Usage

1. Download jsoup-1.20.1.jar to a folder for your Java libs and esnure that folder is set in environment.javalib [^jsoup]
1. Ensure flexmark is in your java class path 
1. Create a markdown file and a mustache template
1. Add mustache template relative path to YAML variable (see exmaple)
1. Ensure a path mapping is saved in mappings.json
	
	e.g. if you intend to preview mydocs/test.md  ensure {"mydocs":"C:/dev/data/mydocs"} is in mappings

1. Add html=1 or pdf=1 to your yaml variables to save HTML or PDF
1. Preview


[^jsoup]: We need a newer version of JSOUP to the one in Flexmark. Without explicitly setting the class path, the Flexmark one will probably be loaded


--->

<cfscript>
param name="url.filename" default="clikwriter/fiona/ConsentForms/newest_treamtment.md";
param name="url.template" default="";

version = "jsoup-1.20.1.jar";
if (! IsDefined( "server.system.environment.javalib" ) ) { throw("server.system.environment.javalib not defined. See notes");}

jsoupJarPath = server.system.environment.javalib & "\" & version
if (! FileExists( jsoupJarPath ) ) { throw("JSOUP jar file (#jsoupJarPath#) not found");}

mappingsFile = expandPath( "./mappings.json");
if (! FileExists( mappingsFile ) ) { throw("mappings File (#mappingsFile#) not found. Please create this from the available sample");}

mappings = deserializeJSON( FileRead( mappingsFile ) );

fileInfo = getFileDetails(url.filename,mappings);
// dump(var=fileInfo,abort=1);

// DM project set up to preview all files through this page. Quick bounce for PDFs or HTML.
ext = ListLast(fileInfo.filename,".");
if (ext neq "md") {
	throw("Only markdown files can be previewed");
}


flexmark = new markdown.flexmark(attributes="true",typographic=true,jsoupjar=variables.jsoupJarPath);

fileInfo["md"] = FileRead(fileInfo.directory & "/" & fileInfo.filename,"utf-8");
doc = flexmark.markdown(text=fileInfo.md,replace_vars=false);
fileInfo["meta"] = doc.data.meta;
fileInfo["html"] = flexmark.replaceVars(doc.html, fileInfo.meta);


for (field in fileInfo.meta) {
	temp = fileInfo.meta[field];
	if (ListLast(temp,".") eq "md") {
		tempPath= getCanonicalPath(fileInfo.directory & "/" & temp )
		if (! FileExists( tempPath ) ) { throw("Meta  File (#tempPath#) not found.");}
		tempData = FileRead(tempPath);
		fileInfo.meta[field] = flexmark.toHTML(tempData);
	}
}

StructAppend( fileInfo.meta, {"save"=0,"pdf"=0},false);

if ( fileInfo.meta.pdf ) {
	fileInfo.meta.save = 1;
}

if ( fileInfo.meta.keyExists("template") ) {
	url.template = fileInfo.meta.template;
}
if (url.template != ""){
	templatePath= getCanonicalPath(fileInfo.directory & "/" & url.template )
	fileInfo.meta.body = fileInfo.html;
	if (! FileExists( templatePath ) ) { throw("template  File (#templatePath#) not found.");}
	template = FileRead(templatePath);
	doc.html = template
}

doc.html = flexmark.replaceVars(doc.html, fileInfo.meta);

if ( fileInfo.meta.save ) {
	fileInfo.outputFile = fileInfo.directory & "/" & Replace(fileInfo.filename,".md", ".html") ;
	fileWrite(fileInfo.outputFile, doc.html);
	
	if ( fileInfo.meta.pdf ) { 
		fileInfo["pdfFile"] = convertPDF( fileInfo.outputFile );
		writeOutput("File saved to #fileInfo.pdfFile#");
	}
	else {
		writeOutput("File saved to #fileInfo.outputFile#");
	}
}
else {
	writeOutput(doc.html);
	abort;
}

struct function getFileDetails(filename, mappings) localmode=true {
	ret = {};
	arguments.filename = replace(arguments.filename, "\", "/", "all");
	ret["filename"] = ListLast( arguments.filename, "/" );
	ret["stem"] = Replace(arguments.filename, "/" & ret.filename,"") ;
	found = 0;
	for (mapping in mappings) {
		if ( findNoCase(mapping, ret.stem) ) {
			ret["directory"] = Replace( ret.stem, mapping, arguments.mappings[mapping]);
			found = 1;
			break;
		}
	}
	
	if (! found ) {
		throw("path #ret.stem# not found in mappings");
	}
	
	return ret;

}

string function convertPDF( inputFile ) localmode=true {
	
	pdfFile = Replace(arguments.inputFile,".html", ".pdf") ;

	princeExecutable = server.system.environment.princeExecutable ? :  "C:/Program Files/Prince/engine/bin/prince.exe";
	if ( FileExists( princeExecutable ) ) {
		cfexecute(name=princeExecutable,arguments=arguments.inputFile,variable="res");

		if (IsDefined("res") && res != "") {
			local.extendedinfo = {"res"=res};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "Error Generating PDF"
			);
		}
		
	}
	else {
		throw("Prince not defined");
		html = FileRead( arguments.inputFile, "UTF-8");
		
		cfdocument(
			format = "pdf",
			name   = "pdfData"
		){
			writeOutput( html );
		}

		fileWrite( pdfFile, pdfData );
	}

	return pdfFile;

}
</cfscript>
