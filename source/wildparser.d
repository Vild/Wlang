module wild.io.wildparser;

/*

 BUILD_VAR(GLOBAL_VAR)
 GLOBAL_VAR

 LOCAL_VAR

 Multioutput

 rule like ninja

 Generic file to rule
 Specific file to rule

 Find dependencies (Code files)

 Contextes

 If

 Option types:
 string - Text
 int - Text w/ validation
 bool - Checkboxes
 enum - Radio buttons


Indentation based \t ' 'x2

 //Processing
 gcc -o .wild/out/src/main.c.o src/main.c
 gcc -o .wild/out/src/test.c.o src/test.c
 gas -o .wild/out/src/asm.S.o src/asm.S
 //Outputing
 gcc -o prog .wild/out/src/main.c.o .wild/out/src/test.c.o .wild/out/src/asm.S.o

 
//TODO: Should i change the design to use braces and curlybraces?

 */

immutable grammar_code = `
WildParser:
    File           <- (Line :endOfLine?)*
    Line           <- Indent* (SetVar / Option / Rule / Process / Project / Depend / If / StringLine)

    StringLine     <- (!endOfLine .)*

    space          <- :(' ' / '\t')
    endOfLine      <- :('\r'? '\n')
    Indent         <- ('\t' / "    ")

	DQChar         <- EscapeSequence / !doublequote .
    EscapeSequence <- backslash (
    							  quote /
                                  doublequote /
                                  backslash /
                                  [abfnrtv]
                                )
        
    String         <~ :doublequote (DQChar)* :doublequote
    Bool           <- "true" / "false"
    Number         <~ '-'? [0-9]+ ('.' ( [0-9]+ ) ? ) ?
    Value          <- String / Bool / Number / Identifier

	Identifier     <~ !Keyword [a-zA-Z_] [a-zA-Z0-9_]*
	OutputType     <- "execute" / "library" / "object" / "custom"
	Scope          <- "local" / "global"
	OptionType     <- "string" / "int" / "bool" / "enum"
	Keyword        <- Scope / OutputType / "rule" / "process" / "project" / "depend" / "if" / "else" / OptionType / "option"

    Spacing        <~ (space / endOfLine / Comment)*
	Comment        <~ "//" (!endOfLine .)* endOfLine

	If             < "if" "(" IfConditional ")"
	IfConditional  < Value (("==" / "!=" / ">=" / "<=" / ">" / "<") Value)?
	Else           < "else"

	SetVar         < Scope? Identifier :'=' Value
	Rule           < "rule" Identifier OutputType
	Process        < "process" String Identifier
	Option         < "option" OptionType Identifier

	Project        < "project" String OutputType
	Depend         < "depend"

`;

class WildParser {
	
}



void RunTest() {
    
}