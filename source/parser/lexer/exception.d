module parser.lexer.exception;

import std.string;
import parser.lexer.lexer;

class LexerSyntaxError : Exception {
	public:
	this(Lexer lexer, size_t start, size_t end) {
		super("");
		size_t[2] startLine = lexer.GetLinePos(start);
		size_t[2] endLine = lexer.GetLinePos(end);
		
		msg = format("Syntax error! Starting at line %d:%d (%d), ending at %d:%d (%d).\nLine data: %s\n",
			startLine[0], startLine[1], start,
			endLine[0], endLine[1], end,
			lexer.Data()[start..end]);
	}
	private:
	
}