module ast.parser.exception;

import ast.lexer.token;
import ast.parser.parser;
import std.string;
import std.container.array;
import ast.lexer.lexer;
import std.range;
import std.conv;

/+
pointer = to!string(' '.repeat.take(format("Line %d: ", endPos[0]).length));
			pointer ~= to!string(' '.repeat.take(endPos[1] - 2));
			pointer ~= "^";
+/

abstract class ParserException : Exception {
public:
	this(Parser parser, Array!Token tokens, size_t idx, string error, string f = __FILE__, size_t l = __LINE__, bool endtoken = false) {
		super("", f, l);

		string linePointer = "";

		if (endtoken) {
			Token token = tokens[idx - 1];
			Lexer lexer = token.TheLexer;
			size_t[2] startPos = lexer.GetLinePos(token.Start);
			
			size_t lineStart = lexer.GetDataPos([startPos[0], 0]);
			size_t lineEnd = lexer.GetDataPos([startPos[0]+1, 0]) - 1;
			if (lineStart != 0 && lineEnd == -1)
				lineEnd = lexer.Data.length - 1;

			ulong dif = token.Length - 1;
			string line = format("Line %d: ", startPos[0]);
			linePointer ~= line;
			linePointer ~= lexer.Data[lineStart .. lineEnd];
			linePointer ~= "\n";
			linePointer ~= to!string(' '.repeat.take(line.length + startPos[1] - 2));
			linePointer ~= "^";
			
			if (dif > 0)
				linePointer ~= to!string('-'.repeat.take(dif - 1));
			if (dif > 1)
				linePointer ~= "^";
			linePointer ~= "\n";
		}

		Token token = tokens[idx];
		Lexer lexer = token.TheLexer;
		size_t[2] startPos = lexer.GetLinePos(token.Start);
		
		size_t lineStart = lexer.GetDataPos([startPos[0], 0]);
		size_t lineEnd = lexer.GetDataPos([startPos[0]+1, 0]) - 1;
		if (lineStart != 0 && lineEnd == -1)
			lineEnd = lexer.Data.length - 1;

		{
			ulong dif = token.Length - 1;
			string line = format("Line %d: ", startPos[0]);
			linePointer ~= line;
			linePointer ~= lexer.Data[lineStart .. lineEnd];
			linePointer ~= "\n";
			linePointer ~= to!string(' '.repeat.take(line.length + startPos[1]));
			linePointer ~= "^";

			if (dif > 0)
				linePointer ~= to!string('-'.repeat.take(dif - 1));
			if (dif > 1)
				linePointer ~= "^";
		}
	




		msg = format("\n%s\nStarting at line %d:%d, ending at %d:%d.\nToken: %s\n%s",
			error,
			startPos[0], startPos[1],
			startPos[0]+token.Length, startPos[1],
			token,
			linePointer);
	}
private:
	
}

class UnknownStatementException : ParserException {
public:
	this(Parser parser, Array!Token tokens, size_t idx, string f = __FILE__, size_t l = __LINE__) {
		super(parser, tokens, idx, "Unknown statement starting with token: ", f, l);
	}
}

class ExpectedException(expected) : ParserException {
public:
	this(Parser parser, Array!Token token, size_t idx, string f = __FILE__, size_t l = __LINE__) {
		super(parser, token, idx, "Expected '" ~ expected.stringof ~ "' got " ~ token[idx].toString, f, l, true);
	}
}