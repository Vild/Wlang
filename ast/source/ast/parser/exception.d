module ast.parser.exception;

import ast.lexer.token;
import ast.parser.parser;
import std.string;
import std.container.array;

abstract class ParserException : Exception {
public:
	this(Parser parser, Array!Token tokens, size_t idx, string error) {
		super("");
		Token token = tokens[idx];
		size_t[2] startLine = token.TheLexer.GetLinePos(token.Start);
		size_t[2] endLine = token.TheLexer.GetLinePos(token.End);
		
		msg = format("%s ID: %d, Starting at line %d:%d, ending at %d:%d.\nToken: %s\n",
			error,
			idx,
			startLine[0], startLine[1],
			endLine[0], endLine[1],
			token);
	}
private:
	
}

class UnknownTokenParsingException : ParserException {
public:
	this(Parser parser, Array!Token tokens, size_t idx) {
		super(parser, tokens, idx, "Unknown token parsing!");
	}
}

class UnknownStatementException : ParserException {
public:
	this(Parser parser, Array!Token tokens, size_t idx) {
		super(parser, tokens, idx, "Unknown statement starting with token: ");
	}
}

class ExpectedException(expected) : ParserException {
public:
	this(Parser parser, Array!Token token, size_t idx) {
		super(parser, token, idx, "Expected '" ~ expected.stringof ~ "' got " ~ token[idx].toString);
	}
}