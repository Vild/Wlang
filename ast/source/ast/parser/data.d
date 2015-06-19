module ast.parser.data;

import ast.lexer.token;
import std.variant;

enum NoData = cast(void *)null;
alias TypeContainer = Algebraic!(TypeToken, SymbolToken, /* For no data */ void *);
alias ValueContainer = Algebraic!(ValueToken, SymbolToken, /* For no data */ void *);

struct Argument {
	TypeContainer type;
	SymbolToken symbol;
	ValueContainer value;
}
