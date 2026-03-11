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
param name="url.template" default="clikwriter/_templates/html_standard.html";
param name="url.pdf" default="0";
param name="url.save" default="0";

options = duplicate(url);

flexmark = new markdown.testing.flexmarkTestObj();

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

fileInfo["md"] = FileRead(fileInfo.directory & "/" & fileInfo.filename,"utf-8");

fileInfo.md = parseBridge(fileInfo.md);
// writeOutput(htmlCodeFormat(fileinfo.md));abort;

doc = flexmark.markdown(text=fileInfo.md,replace_vars=false);
fileInfo["meta"] = doc.data.meta;
fileInfo["html"] = flexmark.replaceVars(doc.html, fileInfo.meta);

// YAML data with a value ending in .md will read from markdown file and converted to html
loop collection=fileInfo.meta key="field" value="value" {
	if (ListLast(value,".") eq "md") {

		filePath= getFilePath( fileInfo.directory, mappings, value );

		if (! FileExists( filePath ) ) { throw("Meta  File (#filePath#) not found.");}
		fileInfo.meta[field] = flexmark.toHTML(FileRead(filePath));
	}
}

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

	// assest can be added by adding list of filenames. They are added inline
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

string function getFilePath(filename, mappings, rootdir) localmode=true {
	info = getFileDetails(argumentCollection = arguments);

	if (info.found) {
		ret = getCanonicalPath(info.directory & "/" & info.filename);
	}
	else {
		ret = getCanonicalPath(arguments.rootdir & "/" & info.stem & "/" & info.filename);
	}

	return ret;

}

struct function getFileDetails(filename, mappings, boolean throwonerror=true) localmode=true {
	ret = {};
	arguments.filename = replace(arguments.filename, "\", "/", "all");
	ret["filename"] = ListLast( arguments.filename, "/" );
	ret["stem"] = Replace(arguments.filename, "/" & ret.filename,"") ;
	ret["found"] = 0;
	
	for (mapping in mappings) {
		if ( findNoCase(mapping, ret.stem) ) {
			ret["directory"] = Replace( ret.stem, mapping, arguments.mappings[mapping]);
			ret.found = 1;
			break;
		}
	}
	
	if (! ret.found && arguments.throwonerror ) {
		throw("path #ret.stem# not found in mappings");
	}
	
	return ret;

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

string function parseBridge(html) {

	// Use to easy instantiation of coldSoupObj
	
	
	bridgeObj = new bridge.html_plugin(coldSoupObj=flexmark.coldSoupObj);

	return bridgeObj.process(arguments.html);

}
</cfscript>
