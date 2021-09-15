import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.apache.commons.io.IOUtils;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

public class FlexmarkTest {
    protected int value1, value2;
    Flexmark flexmark;
    @BeforeEach
    protected void setUp(){

    }

    @Test
    public void testParse() throws IOException {
        flexmark = new Flexmark();
        String doc = getTestDoc();
        String html = flexmark.render(doc);
        System.out.println(html);
    }

    @Test
    public void testAnchorTextParse() throws IOException {
        flexmark = new Flexmark("tables=true,abbreviation=true,admonition=true,anchorlink=true,anchorlinks_wrap_text=false,attributes=true,autolink=true,definition=true,emoji=true,escapedcharacter=true,footnote=true,strikethrough=true");
        String doc = getTestDoc();
        String html = flexmark.render(doc);
        System.out.println(html);
    }
    //TODO: relative path for this??
    public String getTestDoc()  throws IOException {
        String doc = new String(Files.readAllBytes(Paths.get("D:\\git\\markdown\\testing\\sources\\markdown_test_doc.md")), StandardCharsets.UTF_8);
        return doc;

    }
    @Test
    public void htmlConverter() throws IOException {
        flexmark = new Flexmark();
        String doc = getTestDoc();
        String html = flexmark.render(doc);
        html = flexmark.toMarkdown(html);
        System.out.println(html);
    }


}
