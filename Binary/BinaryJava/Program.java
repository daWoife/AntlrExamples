


import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import org.antlr.v4.gui.TreeViewer;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CodePointCharStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.*;
import org.antlr.v4.runtime.*;


public class Program {
    public static void main(String[] args) throws IOException
    {
	ParseTree tree = null;
	CommonTokenStream tokens = null;
	ANTLRInputStream input = new ANTLRInputStream("((A∧B)∨((A∧B)∧B))⇒B");
	BinaryLexer lexer = new BinaryLexer(input);
	tokens = new CommonTokenStream(lexer);
	BinaryParser parser = new BinaryParser(tokens);
	tree = parser.expr();
	Class1 c = new Class1();
		ParseTreeWalker.DEFAULT.walk(c, tree);
    }
}
