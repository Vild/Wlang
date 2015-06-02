import parser.lexer.lexer;
import std.file;
import des.log;
import std.stdio;

int main(string[] args) {
	logger.rule.setLevel(LogLevel.TRACE);
	logger.Debug("Hello!");
	Lexer lexer = new Lexer(readText("test.w"));
	writeln("Final output!");
	foreach (token; lexer.Tokens)
		writeln("\t", token);
	return 0;
}
