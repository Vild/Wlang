module ast.parser.statement;

import ast.lexer.token;
import ast.parser.data;
import ast.parser.parser;
import std.container.array;
import std.string;
import std.variant;

class Statement {
public:
	this(Parser parser, Array!AttributeToken attr) {
		this.parser = parser;
		this.attr = attr;
	}

	@property Parser TheParser() { return parser; }
	@property Array!AttributeToken Attributes() { return attr; }

protected:
	Parser parser;
	Array!AttributeToken attr;
}

class Scope : Statement {
public:
	this(Parser parser, Array!AttributeToken attr) {
		super(parser, attr);
	}

	Statement Add(Statement stmt) {
		list ~= stmt;
		return stmt;
	}

	@property ref Array!Statement List() { return list; }

	override string toString() {
		import std.string;
		string ret = "[Scope]";
		indent++;
		foreach(stmt; list)
			ret ~= format("\n%d\t %s", indent, stmt.toString);
		indent--;
		return ret;
	}
private:
	Array!Statement list;

	//for nicer text output
	static uint indent = 0;
}

class VariableDefinitionStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, TypeToken type, SymbolToken symbol, ValueContainer startValue = NoData) {
		super(parser, attr);
		this.type = type;
		this.symbol = symbol;
		this.startValue = startValue;
	}

	@property TypeToken Type() { return type; }
	@property SymbolToken Symbol() { return symbol; }
	@property ValueContainer StartValue() { return startValue; }

	override string toString() {
		return format("[VariableDefinitionStatement] Type: '%s', Symbol: '%s', StartValue: '%s'", type, symbol, startValue);
	}

private:
	TypeToken type;
	SymbolToken symbol;
	ValueContainer startValue;
}

class FunctionDefinitionStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, TypeToken type, SymbolToken symbol, Array!Argument t1, Array!Argument t2) {
		super(parser, attr);
		this.type = type;
		this.symbol = symbol;
		this.t1 = t1;
		this.t2 = t2;
	}
	
	@property TypeToken Type() { return type; }
	@property SymbolToken Symbol() { return symbol; }
	@property Array!Argument Tier1() { return t1; }
	@property Array!Argument Tier2() { return t2; }
	
	override string toString() {
		import std.conv;
		return format("[FunctionDefinitionStatement] Type: '%s', Symbol: '%s', Tier1: '%s', Tier2: '%s'", type, symbol, to!string(t1[]), to!string(t2[]));
	}
	
private:
	TypeToken type;
	SymbolToken symbol;
	Array!Argument t1;
	Array!Argument t2;
}