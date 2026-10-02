<cfscript>
string function getFilePath(filename, mappings, rootdir) localmode=true {
	info = getFileDetails(argumentCollection = arguments, throwonerror=false);

	if (info.found) {
		ret = info.path;
	}
	else {
		ret = getCanonicalPath(arguments.rootdir & "/" & info.stem & info.filename);
	}

	return ret;

}

struct function getFileDetails(filename, mappings, boolean throwonerror=true) localmode=true {
	ret = {};
	arguments.filename = replace(arguments.filename, "\", "/", "all");
	ret["filename"] = ListLast( arguments.filename, "/" );
	ret["stem"] = ListLen(arguments.filename, "/") gt 1 ? Replace(arguments.filename, "/" & ret.filename,"") & "/" : "";
	ret["found"] = 0;

	for (mapping in mappings) {
		// Match a complete leading mapping, never a substring of the path.
		prefix = replace(mapping, "\", "/", "all");
		if (right(prefix, 1) neq "/") { prefix &= "/"; }
		if ( compareNoCase(left(arguments.filename, len(prefix)), prefix) eq 0 ) {
			root = createObject("java", "java.io.File").init(arguments.mappings[mapping]).getCanonicalFile();
			relativePath = removeChars(arguments.filename, 1, len(prefix));
			target = createObject("java", "java.io.File").init(root, relativePath).getCanonicalFile();
			// Compare whole path components using the host's case rules.
			if (! target.toPath().startsWith(root.toPath()) || target.equals(root)) {
				throw(type="Preview.PathOutsideMapping", message="Requested file is outside its mapping");
			}
			ret["path"] = target.getPath();
			ret["directory"] = target.getParent();
			ret["filename"] = target.getName();
			ret.found = 1;
			break;
		}
	}

	if (! ret.found && arguments.throwonerror ) {
		throw("path #ret.stem# not found in mappings");
	}

	return ret;

}

</cfscript>
