module ast.parser.exception;

import ast.lexer.token;
import ast.parser.parser;
import std.string;
import std.container.array;
import ast.lexer.lexer;

abstract class ParserException : Exception {
public:
	this(Parser parser, Array!Token tokens, size_t idx, string error, string f = __FILE__, size_t l = __LINE__) {
		super("", f, l);
		Token token = tokens[idx];
		Lexer lexer = token.TheLexer;
		size_t[2] startPos = lexer.GetLinePos(token.Start);
		size_t[2] endPos = lexer.GetLinePos(token.End);

		size_t lineStart = lexer.GetDataPos([startPos[0], 0]);
		size_t lineEnd = lexer.GetDataPos([endPos[0]+1, 0]) - 1;

		import std.stdio;
		writefln("\nstartPos: %s, endPos: %s, lineStart: %s, lineEnd: %s", startPos, endPos, lineStart, lineEnd);

		string pointer = "";
		if (lineStart == -1 || lineEnd == -1)
			lineStart = lineEnd = 0;
		else {
			import std.range;
			import std.conv;
			pointer ~= to!string(' '.repeat.take(startPos[1]));
			pointer ~= "^";
			if (endPos[1] - 1 > startPos[1]) {
				if (endPos[1] - 2 > startPos[1])
					pointer ~= to!string('-'.repeat.take(endPos[1] - startPos[1] - 2));
				pointer ~= "^";
			}
		}
		
		msg = format("%s ID: %d, Starting at line %d:%d, ending at %d:%d.\nToken: %s\nLine: %s\n      %s",
			error,
			idx,
			startPos[0], startPos[1],
			endPos[0], endPos[1],
			token,
			lexer.Data[lineStart .. lineEnd],
			pointer);
	}
private:
	
}

class UnknownTokenParsingException : ParserException {
public:
	this(Parser parser, Array!Token tokens, size_t idx, string f = __FILE__, size_t l = __LINE__) {
		super(parser, tokens, idx, "Unknown token parsing!", f, l);
	}
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
		super(parser, token, idx, "Expected '" ~ expected.stringof ~ "' got " ~ token[idx].toString, f, l);
	}
}