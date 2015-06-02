import parser.lexer.lexer;
import std.file;
import des.log;
import std.stdio;

int main(string[] args) {
	logger.rule.setLevel(LogLevel.TRACE);
	Lexer lexer = new Lexer(readText("test.w"));
	foreach (token; lexer.Tokens)
		writeln("\t", token);
	return 0;
}
