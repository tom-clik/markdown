<!--- Run from the repository root: box execute testing/preview_paths_test.cfm --->
<cfscript>
include "../preview/pathHelpers.cfm";
rootDir = getDirectoryFromPath(getCurrentTemplatePath()) & "sources";
mappings = {"mydocs": rootDir};
checks = 0;

function check(required boolean condition, required string message) {
	if (! arguments.condition) { throw(message=arguments.message); }
	variables.checks++;
}

function rejects(required string filename, boolean throwonerror=true) {
	try {
		getFileDetails(arguments.filename, variables.mappings, arguments.throwonerror);
	}
	catch (any e) {
		check(e.type eq "Preview.PathOutsideMapping", "Wrong rejection for " & arguments.filename);
		return;
	}
	throw(message="Accepted escaping path: " & arguments.filename);
}

for (filename in ["mydocs/report.pdf", "MYDOCS/report.pdf", "mydocs\report.pdf",
	"mydocs/nested/report.html", "mydocs/nested/../report.pdf", "mydocs/report.md"]) {
	info = getFileDetails(filename, mappings);
	check(info.found, "Valid mapped file was rejected");
	expected = createObject("java", "java.io.File").init(rootDir,
		replace(removeChars(filename, 1, 7), "\", "/", "all")).getCanonicalPath();
	check(compare(info.path, expected) eq 0, "Wrong resolved file for " & filename);
	check(compare(getFilePath(filename, mappings, rootDir), expected) eq 0, "Mapped helper path differs");
}

for (filename in ["mydocs/../../secret.pdf", "mydocs\..\secret.html",
	"mydocs/../sources-private/secret.pdf", "mydocs/nested/../../secret.md", "mydocs/.."]) {
	rejects(filename);
	// A recognized but unsafe mapping must not fall through to relative lookup.
	rejects(filename, false);
}

for (filename in ["prefixmydocs/report.pdf", "other/mydocs/report.pdf", "mydocs-extra/report.pdf"]) {
	check(! getFileDetails(filename, mappings, false).found, "Accepted partial mapping: " & filename);
	rejected = false;
	try { getFileDetails(filename, mappings); }
	catch (any e) { rejected = true; }
	check(rejected, "Unmapped direct request was accepted");
}

for (filename in ["template.html", "nested/template.html", "../template.html"]) {
	check(compare(getFilePath(filename, mappings, rootDir),
		getCanonicalPath(rootDir & "/" & filename)) eq 0, "Relative fallback changed");
}
writeOutput("PASS: " & checks & " preview path checks" & chr(10));
</cfscript>
