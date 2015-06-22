module ast.parser.data;

import ast.lexer.token;
import std.variant;
import ast.parser.statement;

enum NoData = cast(void *)null;
alias TypeContainer = Algebraic!(TypeToken, SymbolToken, /* For no data */ void *);

struct Argument {
	TypeContainer type;
	SymbolToken symbol;
	Statement defaultValue;
}
