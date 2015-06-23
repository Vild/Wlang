module ast.parser.data;

import ast.lexer.token;
import std.variant;
import ast.parser.statement;
import std.json;

enum NoData = cast(void *)null;
alias TypeContainer = Algebraic!(TypeToken, SymbolToken, /* For no data */ void *);
JSONValue toJson(T)(T obj) if (is(T == TypeContainer)) {
	return JSONValue(obj.toString);
}

struct Argument {
	TypeContainer type;
	SymbolToken symbol;
	Statement defaultValue;

	JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(this.stringof),
				"type": type.toJson,
				"symbol": symbol.toJson,
				"defaultValue": defaultValue.toJson
			]);
	}
}
