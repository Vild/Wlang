/**
	Main application module for compiler
	Copyright: © 2015 Dan Printzell
	License: Mozilla Public License Version 2.0, as written in the included LICENSE file.
	Authors: Dan Printzell
*/
module app;

import ast.lexer.lexer;
import ast.parser.parser;
import wlang.io.log;
import std.file;
import std.stdio;

Log log;

int main(string[] args) {
	log = Log.MainLogger();
	foreach (arg; args[1 .. $])
		processFile(arg);
	return 0;
}

/**
* This function opens the $(PARAM file) and processes it.
*/
void processFile(string file) {
	log.Info("Processing file: %s", file);
	Lexer lexer = new Lexer(readText(file));
	File flex = File(file[0 .. $ - 1] ~ "lex.json", "w");
	scope (exit)
		flex.close();
	flex.writeln("[");
	size_t idx = 0;
	foreach (token; lexer.Tokens)
		flex.write((idx++ ? ",\n" : "") ~ token.toString);
	flex.writeln("\n]");

	Parser parser = new Parser(lexer);

	File fpar = File(file[0 .. $ - 1] ~ "par.json", "w");
	scope (exit)
		fpar.close();
	fpar.writeln("[");
	idx = 0;
	foreach (token; parser.Root.List)
		fpar.writeln((idx++ ? ",\n" : "") ~ token.toString);
	fpar.writeln("\n]");
	log.Info("End");
}
