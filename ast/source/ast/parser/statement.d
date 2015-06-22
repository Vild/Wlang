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
	@property bool NeedEndToken() { return true; }

protected:
	Parser parser;
	Array!AttributeToken attr;
}

class VoidStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr) {
		super(parser, attr);
	}

	override string toString() {
		return "[VoidStatement]";
	}
}

class ValueStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, ValueToken value) {
		super(parser, attr);
		this.value = value;
	}
	
	override string toString() {
		return format("[ValueStatement] Value: '%s'", value);
	}
private:
	ValueToken value;
}

class SymbolStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, SymbolToken symbol) {
		super(parser, attr);
		this.symbol = symbol;
	}
	
	override string toString() {
		return format("[SymbolStatement] Symbol: '%s'", symbol);
	}
private:
	SymbolToken symbol;
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
	@property override bool NeedEndToken() { return false; }

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
	this(Parser parser, Array!AttributeToken attr, TypeToken type, SymbolToken symbol, Statement startValue) {
		super(parser, attr);
		this.type = type;
		this.symbol = symbol;
		this.startValue = startValue;
	}

	@property TypeToken Type() { return type; }
	@property SymbolToken Symbol() { return symbol; }
	@property Statement StartValue() { return startValue; }

	override string toString() {
		return format("[VariableDefinitionStatement] Type: '%s', Symbol: '%s', StartValue: '%s'", type, symbol, startValue);
	}

private:
	TypeToken type;
	SymbolToken symbol;
	Statement startValue;
}

class FunctionDefinitionStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, TypeToken type, SymbolToken symbol, Array!Argument templates, Array!Argument arguments) {
		super(parser, attr);
		this.type = type;
		this.symbol = symbol;
		this.templates = templates;
		this.arguments = arguments;
	}
	
	@property TypeToken Type() { return type; }
	@property SymbolToken Symbol() { return symbol; }
	@property Array!Argument Templates() { return templates; }
	@property Array!Argument Arguments() { return arguments; }

	@property override bool NeedEndToken() { return false; }
	
	override string toString() {
		import std.conv;
		return format("[FunctionDefinitionStatement] Type: '%s', Symbol: '%s', Template: '%s', Arguments: '%s'", type, symbol, to!string(templates[]), to!string(arguments[]));
	}
	
private:
	TypeToken type;
	SymbolToken symbol;
	Array!Argument templates;
	Array!Argument arguments;
}

class FunctionCallStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, SymbolToken symbol, Array!Statement templates, Array!Statement arguments) {
		super(parser, attr);
		this.symbol = symbol;
		this.templates = templates;
		this.arguments = arguments;
	}

	@property SymbolToken Symbol() { return symbol; }
	@property Array!Statement Templates() { return templates; }
	@property Array!Statement Arguments() { return arguments; }
	
	override string toString() {
		import std.conv;
		return format("[FunctionCallStatement] Symbol: '%s', Template: '%s', Arguments: '%s'", symbol, to!string(templates[]), to!string(arguments[]));
	}
	
private:
	SymbolToken symbol;
	Array!Statement templates;
	Array!Statement arguments;
}

class ValueContainerStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, Statement value) {
		super(parser, attr);
		this.value = value;
	} 
	
	@property Statement Value() { return value; }

	override string toString() {
		import std.conv;
		return format("[ValueContainerStatement] Value: '%s'", value);
	}
private:
	Statement value;
}

class NotStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, Statement value) {
		super(parser, attr);
		this.value = value;
	} 
	
	@property Statement Value() { return value; }
	
	override string toString() {
		import std.conv;
		return format("[NotStatement] Value: '%s'", value);
	}
private:
	Statement value;
}

class PlusStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, Statement left, Statement right) {
		super(parser, attr);
		this.left = left;
		this.right = right;
	} 
	
	@property Statement Left() { return left; }
	@property Statement Right() { return right; }
	
	override string toString() {
		import std.conv;
		return format("[PlusStatement] Left: '%s', Right: '%s'", left, right);
	}
private:
	Statement left;
	Statement right;
}

