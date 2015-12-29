import ast.lexer.lexer;
import ast.parser.parser;
import wlang.io.log;
import std.file;
import std.stdio;

Log log;

int main(string[] args) {
	log = Log.MainLogger();
	foreach (arg; args[1..$])
		processFile(arg);
	return 0;
}

void processFile(string file) {
	log.Info("Processing file: %s", file);
	Lexer lexer = new Lexer(readText(file));
	File flex = File(file[0..$-1]~"lex", "w");
	scope(exit)
		flex.close();
	foreach (token; lexer.Tokens)
		flex.writeln(token.toString);

	Parser parser = new Parser(lexer);

	File fpar = File(file[0..$-1]~"par", "w");
	scope(exit)
		fpar.close();
	foreach (token; parser.Root.List)
		fpar.writeln(token.toString);
	log.Info("End");
}
