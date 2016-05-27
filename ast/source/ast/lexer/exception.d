module ast.lexer.exception;

import ast.lexer.lexer;
import std.string;

abstract class LexerException : Exception {
public:
	this(Lexer lexer, size_t start, size_t end, string error) {
		super("");
		size_t[2] startLine = lexer.GetLinePos(start);
		size_t[2] endLine = lexer.GetLinePos(end);

		msg = format("%s Starting at line %d:%d, ending at %d:%d.\nLine data: %s\n", error, startLine[0], startLine[1],
				endLine[0], endLine[1], lexer.Data()[start .. end]);
	}
}

class InvalidTokenException : LexerException {
public:
	this(Lexer lexer, size_t start, size_t end) {
		super(lexer, start, end, "Invalid token!");
	}
}
