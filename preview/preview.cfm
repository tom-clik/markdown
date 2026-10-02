<!---

# Convert markdown to HTML and process mustache template

Options to save HTML and convert to PDF can be supplied as URL parameters or YAML variables

## Usage

1. Download jsoup (currently jsoup-1.22.1.jar) to a folder for your Java libs and esnure that folder is set in environment.javalib
1. Download flexmark (flexmark-all-0.64.0-lib.jar) to the same folder
1. Create a markdown file and optionally a mustache template
1. Add mustache template relative path to YAML variable (see exmaple)
1. Ensure a path mapping is saved in mappings.json
	
	e.g. if you intend to preview mydocs/test.md  ensure {"mydocs":"C:/dev/data/mydocs"} is in mappings

1. Add html=1 or pdf=1 to your yaml variables to save HTML or PDF
1. Preview


--->

<cfscript>
param name="url.filename";
param name="url.template" default="templates/template_basic.tmpl";
param name="url.pdf" default="0";
param name="url.save" default="0";

options = duplicate(url);

flexmark = new markdown.testing.flexmarkTestObj();

mappingsFile = expandPath( "./mappings.json");
if (! FileExists( mappingsFile ) ) { throw("mappings File (#mappingsFile#) not found. Please create this from the available sample");}

mappings = deserializeJSON( FileRead( mappingsFile ) );

include "pathHelpers.cfm";
fileInfo = getFileDetails(url.filename,mappings);

// DM project set up to preview all files through this page. Quick bounce for PDFs or HTML.
ext = ListLast(fileInfo.filename,".");
if (ext neq "md") {
	cfcontent( file=fileInfo.path );
	abort;
}

fileInfo["md"] = FileRead(fileInfo.path,"utf-8");

doc = flexmark.markdown(text=fileInfo.md,replace_vars=false);

// add publish_code to coldlight index files to run configured settings
if ( doc.data.meta.keyExists("publish_code") ) {
	location( "/coldlight/sample/process.cfm?code=#doc.data.meta.publish_code#");
}

fileInfo["meta"] = doc.data.meta;

// YAML data with a value ending in .md will read from markdown file and convert to html
loop collection=fileInfo.meta key="field" value="value" {
	ext = ListLast(value,".");
	if (ext eq "md") {
		filePath= getFilePath( filename=value, mappings=mappings, rootdir=fileInfo.directory );
		if (! FileExists( filePath ) ) { throw("Import  File (#filePath#) not found.");}
		fileInfo.meta[field] = flexmark.toHTML(FileRead(filePath));
	}
}

fileInfo["html"] = flexmark.replaceVars(doc.html, fileInfo.meta);

StructAppend(options, fileInfo.meta, true);

if ( options.pdf ) {
	options.save = 1;
}

if (options.template != ""){
	templatePath= getFilePath( filename=options.template, mappings=mappings, rootdir= fileInfo.directory );
	StructAppend(fileInfo.meta,{"author"="","description"=""},false);
	fileInfo.meta.body = fileInfo.html;
	if (! FileExists( templatePath ) ) { throw("template  File (#templatePath#) not found.");}
	template = FileRead(templatePath);
	doc.html = template;

	// asset can be added by adding list of filenames. They are added inline
	for ( asset in ['style','script'] ) {
		if ( fileInfo.meta.keyExists(asset) ) {
			assets = "<#asset#>";
			for ( filename in listToArray( fileInfo.meta[asset] ) ) {
				assets &= FileRead( getFilePath( filename=filename, mappings=mappings, rootdir= fileInfo.directory ) );
			}
			assets &= "</#asset#>";
			fileInfo.meta[asset] = assets;
		}
		else {
			fileInfo.meta[asset] = "";
		}
	}
	
}

doc.html = flexmark.replaceVars(doc.html, fileInfo.meta);

if (fileInfo.meta.keyExists("plugins") ) {
	if (! isArray(fileInfo.meta.plugins)){ fileInfo.meta.plugins = listToArray(fileInfo.meta.plugins ) }
	for ( plugin in fileInfo.meta.plugins ) {
		pluginObj = new bridge.html_plugin(coldSoupObj=flexmark.coldSoupObj);
		pluginObj.process(doc=doc, path=fileInfo.directory);
	}
}


if ( options.save ) {
	fileInfo.outputFile = fileInfo.directory & "/" & Replace(fileInfo.filename,".md", ".html") ;
	fileWrite(fileInfo.outputFile, doc.html);
	
	if ( options.pdf ) { 
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

string function convertPDF( inputFile ) localmode=true {
	
	pdfFile = Replace(arguments.inputFile,".html", ".pdf") ;

	princeExecutable = server.system.environment.princeExecutable ? :  "C:/Program Files/Prince/engine/bin/prince.exe";
	if ( FileExists( princeExecutable ) ) {
		cfexecute(name=princeExecutable,arguments="'" & arguments.inputFile & "'",variable="res");

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
