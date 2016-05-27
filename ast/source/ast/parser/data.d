module ast.parser.data;

import ast.lexer.token;
import std.variant;
import ast.parser.statement;
import std.json;
import ast.util.json;

struct NoData {
	JSONValue toJson() {
		return JSONValue("null");
	}
}
//Don't forget to update the ast.util.json.toJson function!
alias TypeContainer = Algebraic!(TypeToken, SymbolToken, NoData);

struct Argument {
	TypeContainer type;
	SymbolToken symbol;
	Statement defaultValue;

	JSONValue toJson() {
		return JSONValue(["class" : JSONValue(typeid(this).name), "type" : type.toJson, "symbol" : symbol.toJson,
				"defaultValue" : defaultValue.toJson]);
	}
}
