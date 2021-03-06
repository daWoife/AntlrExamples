lexer grammar FlexLexer;
 
channels {
	OFF_CHANNEL		// non-default channel for whitespace and comments
}

options {
	superClass = LexerAdaptor ;
}

tokens {
BEGIN_REPEAT_FLEX,
BEGIN_REPEAT_FLEX,
BEGIN_REPEAT_POSIX,
CARET,
CCE_ALNUM,
CCE_ALPHA,
CCE_BLANK,
CCE_CNTRL,
CCE_DIGIT,
CCE_GRAPH,
CCE_LOWER,
CCE_NEG_ALNUM,
CCE_NEG_ALPHA,
CCE_NEG_BLANK,
CCE_NEG_CNTRL,
CCE_NEG_DIGIT,
CCE_NEG_GRAPH,
CCE_NEG_LOWER,
CCE_NEG_PRINT,
CCE_NEG_PUNCT,
CCE_NEG_SPACE,
CCE_NEG_UPPER,
CCE_NEG_XDIGIT,
CCE_PRINT,
CCE_PUNCT,
CCE_SPACE,
CCE_UPPER,
CCE_XDIGIT,
CCL_OP_DIFF,
CCL_OP_UNION,
CHAR, 
CLOSE_BRACKET,
COMMA,
END_REPEAT_FLEX,
END_REPEAT_FLEX,
END_REPEAT_POSIX,
EOF_OP,
EQUAL,
ERROR,
EXIT_FAILURE,
MINUS,
NAME,
NUMBER,
PLUS,
PREVCCL,
QUESTION,
QUOTE,
RETURNNAME,
SCDECL,
SECTEND,
TOK_EXTRA_TYPE,
TOK_HEADER_FILE,
TOK_OPTION,
TOK_OUTFILE,
TOK_PREFIX,
TOK_TABLES_FILE,
TOK_YYCLASS,
XSCDECL
}

// ======================= Common fragments =========================




fragment Alnum :
    ( Alpha | Digit )
	;

fragment Alpha :
	('a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | 'h' | 'i' | 'j' | 'k' | 'l' | 'm' | 'n' | 'o' | 'p' | 'q' | 'r' | 's' | 't' | 'u' | 'v' | 'w' | 'x' | 'y' | 'z'
	|'A' | 'B' | 'C' | 'D' | 'E' | 'F' | 'G' | 'H' | 'I' | 'J' | 'K' | 'L' | 'M' | 'N' | 'O' | 'P' | 'Q' | 'R' | 'S' | 'T' | 'U' | 'V' | 'W' | 'X' | 'Y' | 'Z' )
	;

fragment Blank :
	' ' | '\t'
	;

// Cntrl?

fragment Digit :
	[0-9]
	;

// Graph?

fragment Lower :
	[a-z]
	;

// Print?

// Punct?

fragment Space :
	[ ]
	;

fragment Upper :
	[A-Z]
	;

// XDigit?

fragment Ws :
	Blank+
	;

fragment OptWs :
	Blank*
	;

fragment NotWs :
	~( ' ' | '\t' | '\r' | '\n')
	;

fragment Nl :
    [\r]?[\n]
	;


fragment Name :
	(Alpha | Digit | '$') (Alpha | Digit | [_.\-/$])*
	;

fragment Scname :
	Name
	;

fragment EscSeq
	:	'\\'
		([abefnrtv?"'\\]	// The standard escaped character set such as tab, newline, etc.
		| [xuU]?[0-9]+) // C-style 
	;

fragment First_ccl_char :
	~( '\\' | '\n')
	| EscSeq
	;
	
fragment Ccl_char :
	~( '\\' | '\n' | ']')
	| EscSeq
	;

fragment Ccl_expr :
	'[:' '^'? Alpha+ ':]'
	;

fragment Lexopt :
    [aceknopr]
	;

fragment M4qstart :
	'[['
	;

fragment M4qend :
	']]'
	;

// ===================================================================

mode ACTION;
	I_action_m4qstart : M4qstart { ACTION_ECHO_QSTART(); } ;
	I_action_m4qend : M4qend { ACTION_ECHO_QEND(); } ;
	I_action_opencurly : '{' { ACTION_ECHO(); ++bracelevel; } ;
	I_action_closecurly : '}' { ACTION_ECHO(); --bracelevel; } ;
	I_action_alpha : ~('a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | 'h' | 'i' | 'j' | 'k' | 'l' | 'm' | 'n' | 'o' | 'p' | 'q' | 'r' | 's' | 't' | 'u' | 'v' | 'w' | 'x' | 'y' | 'z'
			| 'A' | 'B' | 'C' | 'D' | 'E' | 'F' | 'G' | 'H' | 'I' | 'J' | 'K' | 'L' | 'M' | 'N' | 'O' | 'P' | 'Q' | 'R' | 'S' | 'T' | 'U' | 'V' | 'W' | 'X' | 'Y' | 'Z'
			| '_' | '{' | '}' | '"' | '\'' | '/' | '\n' | '[' | ']')+
			{ ACTION_ECHO(); } ;
	I_action_dq : '"' { ACTION_ECHO(); BEGIN(ACTION_STRING); } ;
	I_action_nl : Nl {
                ++linenum;
                ACTION_ECHO();
                if (bracelevel <= 0) {
                   if ( doing_rule_action )
                      add_action( "\tYY_BREAK]\"]\n" );

                   doing_rule_action = false;
                   BEGIN(SECT2);
                }
             } ;
	I_action_dot : . { ACTION_ECHO(); } ;


mode ACTION_STRING;

	I_action_string_m4qstart : M4qstart { ACTION_ECHO_QSTART(); } ;
	I_action_string_m4qend : M4qend { ACTION_ECHO_QEND(); } ;
	I_action_string_any : ~('[' | ']' | '"' | '\\' | '\n')+ { ACTION_ECHO(); } ;
	I_action_string_dq : '"' { ACTION_ECHO(); BEGIN(ACTION); } ;
	I_action_string_bn : ('\\' | '\n')* { ACTION_ECHO(); } ;
	I_action_string_bbn : '\\' ('\\' | '\n')* { ACTION_ECHO(); } ;
	I_action_string_nl : Nl {
		++linenum;
		ACTION_ECHO();
		if (bracelevel <= 0)
		{
			BEGIN(SECT2);
		}
		else
		{
			BEGIN(ACTION);
		}
	} ;
	I_action_string_dot : . { ACTION_ECHO(); } ;

mode CARETISBOL;

	I_caretisbol : '^' { BEGIN(SECT2); Type='^'; } ;


mode CCL;

	I_ccl_min : '-/' ~(']' | '\n')	{ Type=MINUS; } ;
	I_ccl_ret : ~('\\' | '\n') { RETURNCHAR(); } ;
	I_ccl_closebracket : ']' { BEGIN(SECT2); Type=CLOSE_BRACKET; } ;
	I_ccl_cce_alnum : Alnum  { BEGIN(CCL); Type=CCE_ALNUM; } ;
	I_ccl_cce_alpha : Alpha  { BEGIN(CCL); Type=CCE_ALPHA; } ;
	I_ccl_cce_blank : Blank { BEGIN(CCL); Type=CCE_BLANK; } ;
	//I_ccl_cce_cntrl : Cntl { BEGIN(CCL); Type=CCE_CNTRL; } ;
	I_ccl_cce_digit : Digit { BEGIN(CCL); Type=CCE_DIGIT; } ;
	//I_ccl_cce_graph : Graph { BEGIN(CCL); Type=CCE_GRAPH; } ;
	I_ccl_cce_lower : Lower { BEGIN(CCL); Type=CCE_LOWER; } ;
	//I_ccl_cce_print : Print { BEGIN(CCL); Type=CCE_PRINT; } ;
	//I_ccl_cce_punct : Punct { BEGIN(CCL); Type=CCE_PUNCT; } ;
	I_ccl_cce_space : Space { BEGIN(CCL); Type=CCE_SPACE; } ;
	I_ccl_cce_upper : Upper { BEGIN(CCL); Type=CCE_UPPER; } ;
	//I_ccl_cce_xdigit : Xdigit { BEGIN(CCL); Type=CCE_XDIGIT; } ;

	I_ccl_cce_neg_alnum : '^' Alnum  { BEGIN(CCL); Type=CCE_NEG_ALNUM; } ;
	I_ccl_cce_neg_alpha : '^' Alpha  { BEGIN(CCL); Type=CCE_NEG_ALPHA; } ;
	I_ccl_cce_neg_blank : '^' Blank { BEGIN(CCL); Type=CCE_NEG_BLANK; } ;
	//I_ccl_cce_neg_cntrl : '^' Cntl { BEGIN(CCL); Type=CCE_NEG_CNTRL; } ;
	I_ccl_cce_neg_digit : '^' Digit { BEGIN(CCL); Type=CCE_NEG_DIGIT; } ;
	//I_ccl_cce_neg_graph : '^' Graph { BEGIN(CCL); Type=CCE_NEG_GRAPH; } ;
	I_ccl_cce_neg_lower : '^' Lower { BEGIN(CCL); Type=CCE_NEG_LOWER; } ;
	//I_ccl_cce_neg_print : '^' Print { BEGIN(CCL); Type=CCE_NEG_PRINT; } ;
	//I_ccl_cce_neg_punct : '^' Punct { BEGIN(CCL); Type=CCE_NEG_PUNCT; } ;
	I_ccl_cce_neg_space : '^' Space { BEGIN(CCL); Type=CCE_NEG_SPACE; } ;
	I_ccl_cce_neg_upper : '^' Upper { BEGIN(CCL); Type=CCE_NEG_UPPER; } ;
	//I_ccl_cce_neg_xdigit : '^' Xdigit { BEGIN(CCL); Type=CCE_NEG_XDIGIT; } ;

	I_ccl_cll_expr : Ccl_expr {
			format_synerr(
				"bad character class expression: " +
					yytext );
			BEGIN(CCL); Type=CCE_ALNUM;
		} ;
	I_ccl_esqseq : EscSeq {
			yylval = myesc(yytext );
			if ( YY_START == FIRSTCCL )
				BEGIN(CCL);
			Type=CHAR;
		} ;

mode CHARACTER_CONSTANT;

	I_character_constant_any : ~('[' | ']' | '\'' | '\\' | '\n')+ { ACTION_ECHO(); } ;
	I_character_constant_dq : '\'' { ACTION_ECHO(); BEGIN(ACTION); } ;
	I_character_constant_bn : ('\\' | '\n')* { ACTION_ECHO(); } ;
	I_character_constant_bbn : '\\' ('\\' | '\n')* { ACTION_ECHO(); } ;
	I_character_constant_nl : Nl {
		++linenum;
		ACTION_ECHO();
		if (bracelevel <= 0)
		{
			BEGIN(SECT2);
		}
		else
		{
			BEGIN(ACTION);
		}
	} ;
	I_character_constant_dot : . { ACTION_ECHO(); } ;

mode CODE_COMMENT;

	I_code_comment_noblahblah : ~('[' | ']' | '*' | '\n')* { ACTION_ECHO(); } ;
	I_code_comment_dot : . { ACTION_ECHO(); } ;
	I_code_comment_nl : Nl { ++linenum; ACTION_ECHO(); } ;

	I_code_comment_end : '*/' { ACTION_ECHO(); yy_pop_state(); } ;


mode CODEBLOCK;

	I_codeblock_cl : '%}' .* Nl { ++linenum; END_CODEBLOCK(); } ;
	I_codeblock_other : ~('\n' | '%' | '[' | ']')* { ACTION_ECHO(); } ;
	I_codeblock_dot : . { ACTION_ECHO(); } ;
	I_codeblock_nl : Nl {
			++linenum;
			ACTION_ECHO();
			if ( indented_code ) END_CODEBLOCK();
		} ;
	I_codeblock_m4qstart : M4qstart { ACTION_ECHO_QSTART(); } ;
	I_codeblock_m4qend : M4qend { ACTION_ECHO_QEND(); } ;

mode CODEBLOCK_MATCH_BRACE;

	I_codeblock_match_brace_cl : '}' {
                if( --brace_depth == 0)
				{
                    /* TODO: Matched. */
                    yy_pop_state();
                }
				else
				{
                    //buf_strnappend(&top_buf, yytext, yyleng);
				}
        } ;
	I_codeblock_match_brace_op : '{' {
                brace_depth++;
                //buf_strnappend(&top_buf, yytext, yyleng);
        } ;
	I_codeblock_match_brace_nl : Nl {
                ++linenum;
                //buf_strnappend(&top_buf, yytext, yyleng);
        } ;
	I_codeblock_match_brace_m4qstart : M4qstart {
			//buf_strnappend(top_buf, escaped_qstart, (int) strlen(escaped_qstart));
		} ;
    I_codeblock_match_brace_m4qend : M4qend {
			//buf_strnappend(top_buf, escaped_qend, (int) strlen(escaped_qend));
		} ;
	I_codeblock_match_brace_other :
		( ~('{' | '}' | '\r' | '\n' | '[' | ']')+
		| ~('{' | '}' | '\r' | '\n')) {
			//buf_strnappend(top_buf, yytext, yyleng);
		} ;

// ===================================================================

mode COMMENT;

	I_comment_noblahblah : ~('[' | ']' | '*' | '\n')* { ACTION_ECHO(); } -> skip ;
	I_comment_dot : . { ACTION_ECHO(); } -> skip ;
	I_comment_nl : Nl { ++linenum; ACTION_ECHO(); } -> skip ;
	
	I_comment_end : '*/' { add_action("*/]\"]"); yy_pop_state(); } -> skip ;

// ===================================================================


mode COMMENT_DISCARD;

	I_comment_discard_end : '*/' { yy_pop_state(); };
	I_comment_discard_star : '*' { } ;
	I_comment_discard_ws : ~('*' | '\n') { } ;
	I_comment_discard_nl : Nl { ++linenum; } ;

mode EXTENDED_COMMENT;

	I_extended_comment_cp : ')' { yy_pop_state(); } ;
	I_extended_comment_ws : ~('\n' | ')')+ { } ;
	I_extended_comment_nl : Nl { ++linenum; } ;


mode FIRSTCCL;

	I_firstccl_up : '^' '/' ~('-' | ']' | '\n') { BEGIN(CCL); Type=CARET; } ;
	I_firstccl_upother : '^' '/' ('-' | ']') { Type=CARET; } ;
	I_firstccl_dot : . { BEGIN(CCL); RETURNCHAR(); } ;
	I_firstccl_cce_alnum : Alnum  { BEGIN(CCL); Type=CCE_ALNUM; } ;
	I_firstccl_cce_alpha : Alpha  { BEGIN(CCL); Type=CCE_ALPHA; } ;
	I_firstccl_cce_blank : Blank { BEGIN(CCL); Type=CCE_BLANK; } ;
	//I_firstccl_cce_cntrl : Cntl { BEGIN(CCL); Type=CCE_CNTRL; } ;
	I_firstccl_cce_digit : Digit { BEGIN(CCL); Type=CCE_DIGIT; } ;
	//I_firstccl_cce_graph : Graph { BEGIN(CCL); Type=CCE_GRAPH; } ;
	I_firstccl_cce_lower : Lower { BEGIN(CCL); Type=CCE_LOWER; } ;
	//I_firstccl_cce_print : Print { BEGIN(CCL); Type=CCE_PRINT; } ;
	//I_firstccl_cce_punct : Punct { BEGIN(CCL); Type=CCE_PUNCT; } ;
	I_firstccl_cce_space : Space { BEGIN(CCL); Type=CCE_SPACE; } ;
	I_firstccl_cce_upper : Upper { BEGIN(CCL); Type=CCE_UPPER; } ;
	//I_firstccl_cce_xdigit : Xdigit { BEGIN(CCL); Type=CCE_XDIGIT; } ;

	I_firstccl_cce_neg_alnum : '^' Alnum  { BEGIN(CCL); Type=CCE_ALNUM; } ;
	I_firstccl_cce_neg_alpha : '^' Alpha  { BEGIN(CCL); Type=CCE_ALPHA; } ;
	I_firstccl_cce_neg_blank : '^' Blank { BEGIN(CCL); Type=CCE_BLANK; } ;
	//I_firstccl_cce_neg_cntrl : '^' Cntl { BEGIN(CCL); Type=CCE_CNTRL; } ;
	I_firstccl_cce_neg_digit : '^' Digit { BEGIN(CCL); Type=CCE_DIGIT; } ;
	//I_firstccl_cce_neg_graph : '^' Graph { BEGIN(CCL); Type=CCE_GRAPH; } ;
	I_firstccl_cce_neg_lower : '^' Lower { BEGIN(CCL); Type=CCE_LOWER; } ;
	//I_firstccl_cce_neg_print : '^' Print { BEGIN(CCL); Type=CCE_PRINT; } ;
	//I_firstccl_cce_neg_punct : '^' Punct { BEGIN(CCL); Type=CCE_PUNCT; } ;
	I_firstccl_cce_neg_space : '^' Space { BEGIN(CCL); Type=CCE_SPACE; } ;
	I_firstccl_cce_neg_upper : '^' Upper { BEGIN(CCL); Type=CCE_UPPER; } ;
	//I_firstccl_cce_neg_xdigit : '^' Xdigit { BEGIN(CCL); Type=CCE_XDIGIT; } ;

	Icll_expr : Ccl_expr {
			format_synerr(
				"bad character class expression: %s"
				+ yytext );
			BEGIN(CCL); Type=CCE_ALNUM;
			} ;

mode GROUP_MINUS_PARAMS;

    I_group_minus_params_colon : ':' { BEGIN(SECT2); } -> skip ;
    I_group_minus_params_i : 'i' { sf_set_case_ins(false); } -> skip ;
    I_group_minus_params_s : 's' { sf_set_dot_all(false); } -> skip ;
    I_group_minus_params_x : 'x' { sf_set_skip_ws(false); } -> skip ;

mode GROUP_WITH_PARAMS;

    I_group_with_params_colon : ':' { BEGIN(SECT2); } -> skip ;
    I_group_with_params_dash : '-'  { BEGIN(GROUP_MINUS_PARAMS); } -> skip ;
    I_group_with_params_i : 'i' { sf_set_case_ins(true); } -> skip ;
    I_group_with_params_s : 's' { sf_set_dot_all(true); } -> skip ;
    I_group_with_params_x : 'x' { sf_set_skip_ws(true); } -> skip ;

mode INITIAL;

	I_initial_upws : Ws // { START_CODEBLOCK(true); }
		-> skip ;
	I_initial_upstartcomment : '/*' // { this.InputStream.LA(-1) == '\n' }?
		{ add_action("/*[\"["); yy_push_state( COMMENT ); } -> skip ;
	I_initial_poundoptwslinews : '#' //	{ this.InputStream.LA(-1) == '\n' }?
		OptWs 'line' Ws { yy_push_state( LINEDIR ); } -> skip ;
	I_initial_percents : '%s' // { this.InputStream.LA(-1) == '\n' }?
		Name? { Type=SCDECL; } ;
	I_initial_percentx : '%x' // { this.InputStream.LA(-1) == '\n' }?
		Name? { Type=XSCDECL; } ;
	I_initial_percentcurly : '%{' // { this.InputStream.LA(-1) == '\n' }?
		.* Nl { START_CODEBLOCK(false); } -> skip ;
	I_initial_top : '%top' // { this.InputStream.LA(-1) == '\n' }?
		Ws? '{' Ws? Nl {
					brace_start_line = linenum;
					++linenum;
					//buf_linedir( &top_buf, infilename?infilename:"<stdin>", linenum);
					brace_depth = 1;
					yy_push_state(CODEBLOCK_MATCH_BRACE);
				} -> skip ;
	I_initial_ws : Ws -> skip ;
	I_initial_perper : '%%' // { this.InputStream.LA(-1) == '\n' }?
		.* {
				sectnum = 2;
				bracelevel = 0;
				mark_defs1();
				line_directive_out(null, 1);
				BEGIN(SECT2PROLOG);
				Type=SECTEND;
		} ;
	I_initial_uppointer_nl : '%pointer' // { this.InputStream.LA(-1) == '\n' }?
		.* Nl { yytext_is_array = false; ++linenum; } ;
	I_initial_uparraynl : '%array' // { this.InputStream.LA(-1) == '\n' }?
		.* Nl	{ yytext_is_array = true; ++linenum; } ;
	I_initial_upoption : '%option' // { this.InputStream.LA(-1) == '\n' }?
		-> type(TOK_OPTION), pushMode(OPTION);
	I_initial_uppercentlexoptoptwsdigitoptwsln : '%' Lexopt OptWs Digit* OptWs Nl { ++linenum; } ;
	I_initial_upname : Name // { this.InputStream.LA(-1) == '\n' }?
		{
			if(yyleng < MAXLINE)
        	{
				strncpy( nmstr, yytext, nmstr.Length );
			}
			else
			{
			   synerr("Definition name too long\n");
			   FLEX_EXIT(EXIT_FAILURE);
			}

			didadef = false;
			BEGIN(PICKUPDEF);
		} ;
	I_initial_scname : Scname { Type=RETURNNAME; } ;
	I_initial_upoptwsnl : OptWs // { this.InputStream.LA(-1) == '\n' }?
		Nl { ++linenum; } ;
	I_initial_optwsnl : OptWs Nl { ACTION_ECHO(); ++linenum; } ;


mode LINEDIR;

	I_linedir_nl : '\n' { yy_pop_state(); } ;
	I_linedir_digits : Digit+ { linenum = myctoi(yytext); } ;
	I_linedir_str : '"' ~('"' | '\n')* '"' {
			free(infilename);
			infilename = xstrdup(yytext + 1);
			//infilename[strlen( infilename ) - 1] = '\0';
		} ;
	I_linedir_dot : . -> skip ;

mode NUM;

	I_num_digit : Digit+ {
			yylval = myctoi( yytext );
			Type=NUMBER;
		} ;
	I_num_comma : ',' { Type=COMMA; } ;
	I_num_cb : '}' {
			BEGIN(SECT2);
			if ( lex_compat || posix_compat )
				Type=END_REPEAT_POSIX;
			else
				Type=END_REPEAT_FLEX;
		} ;

mode OPTION;

	I_option_nl : Nl { ++linenum; BEGIN(INITIAL); } ;
	I_option_ws : Ws { option_sense = true; } ;
	I_option_eq : '=' { Type=EQUAL; } ;
	I_option_no : 'no' { option_sense = ! option_sense; } ;
	I_options_7bit : '7bit'	{ csize = option_sense ? 128 : 256; } ;
	I_options_8bit : '8bit'	{ csize = option_sense ? 256 : 128; } ;
	I_options_align : 'align' { long_align = option_sense; } ;
	I_options_always_interactive : 'always-interactive' {
			ACTION_M4_IFDEF( "M4\"_YY_ALWAYS_INTERACTIVE", option_sense );
            interactive = option_sense;
		} ;
	I_options_array : 'array' { yytext_is_array = option_sense; } ;
	I_options_backup : 'backup' { backing_up_report = option_sense; } ;
	I_options_batch : 'batch' { interactive = ! option_sense; } ;
    I_options_bison_bridge : 'bison-bridge' { bison_bridge_lval = option_sense; } ;
    I_options_bison_locations : 'bison-locations' {
			if((bison_bridge_lloc = option_sense))
				bison_bridge_lval = true;
         } ;
	I_options_cpp : 'c++' { C_plus_plus = option_sense; } ;
	I_options_caseful : 'caseful' | 'case-sensitive' { sf_set_case_ins(!option_sense); } ;
	I_options_caseless : 'caseless' | 'case-insensitive' { sf_set_case_ins(option_sense); } ;
	I_options_debug : 'debug' { ddebug = option_sense; } ;
	I_options_default : 'default' { spprdflt = ! option_sense; } ;
	I_options_ecs : 'ecs' { useecs = option_sense; } ;
	I_options_fast : 'fast' {
			useecs = usemecs = false;
			use_read = fullspd = true;
		} ;
	I_options_full : 'full' {
			useecs = usemecs = false;
			use_read = fulltbl = true;
		} ;
	I_options_input : 'input' { ACTION_IFDEF("YY_NO_INPUT", ! option_sense); } ;
	I_options_interactive : 'interactive' { interactive = option_sense; } ;
	I_options_lex_compat : 'lex-compat' { lex_compat = option_sense; } ;
	I_options_posix_compat : 'posix-compat' { posix_compat = option_sense; } ;
	I_options_line : 'line' { gen_line_dirs = option_sense; } ;
	I_options_main : 'main'	{
			ACTION_M4_IFDEF( "M4\"_YY_MAIN", option_sense);
            /* Override yywrap */
            if( option_sense == true )
                do_yywrap = false;
		} ;
	I_options_meta_ecs : 'meta-ecs' { usemecs = option_sense; } ;
	I_options_never_interactive : 'never-interactive' {
			ACTION_M4_IFDEF( "M4\"_YY_NEVER_INTERACTIVE", option_sense );
            interactive = !option_sense;
		} ;
	I_options_perf_report : 'perf-report' { performance_report += option_sense ? 1 : -1; } ;
	I_options_pointer : 'pointer' { yytext_is_array = ! option_sense; } ;
	I_options_read : 'read' { use_read = option_sense; } ;
    I_options_reentrant : 'reentrant' { reentrant = option_sense; } ;
	I_options_reject : 'reject' { reject_really_used = option_sense; } ;
	I_options_stack : 'stack' { ACTION_M4_IFDEF( "M4\"_YY_STACK_USED", option_sense ); } ;
	I_options_stdinit : 'stdinit' { do_stdinit = option_sense; } ;
	I_options_stdout : 'stdout' { use_stdout = option_sense;  } ;
    I_options_unistd : 'unistd' { ACTION_IFDEF("YY_NO_UNISTD_H", ! option_sense); } ;
	I_options_unput : 'unput' { ACTION_M4_IFDEF("M4\"_YY_NO_UNPUT", ! option_sense); } ;
	I_options_verbose : 'verbose' { printstats = option_sense; } ;
	I_options_warn : 'warn' { nowarn = ! option_sense; } ;
	I_options_yylineno : 'yylineno' { do_yylineno = option_sense; ACTION_M4_IFDEF("M4\"_YY_USE_LINENO", option_sense); } ;
	I_options_yymore : 'yymore' { yymore_really_used = option_sense; } ;
	I_options_yywrapo : 'yywrap' { do_yywrap = option_sense; } ;
	I_options_yy_push_state : 'yy_push_state' { ACTION_M4_IFDEF("M4\"_YY_NO_PUSH_STATE", ! option_sense); } ;
	I_options_yy_pop_state : 'yy_pop_state' { ACTION_M4_IFDEF("M4\"_YY_NO_POP_STATE", ! option_sense); } ;
	I_options_yy_top_state : 'yy_top_state' { ACTION_M4_IFDEF("M4\"_YY_NO_TOP_STATE", ! option_sense); } ;
	I_options_yy_scan_buffer : 'yy_scan_buffer' { ACTION_M4_IFDEF("M4\"_YY_NO_SCAN_BUFFER", ! option_sense); } ;
	I_options_yy_scan_bytes : 'yy_scan_bytes' { ACTION_M4_IFDEF("M4\"_YY_NO_SCAN_BYTES", ! option_sense); } ;
	I_options_yy_scan_string : 'yy_scan_string' { ACTION_M4_IFDEF("M4\"_YY_NO_SCAN_STRING", ! option_sense); } ;
    I_options_yyalloc : 'yyalloc' { ACTION_M4_IFDEF("M4\"_YY_NO_FLEX_ALLOC", ! option_sense); } ;
    I_options_yyrealloc : 'yyrealloc' { ACTION_M4_IFDEF("M4\"_YY_NO_FLEX_REALLOC", ! option_sense); } ;
    I_options_yyfree : 'yyfree' { ACTION_M4_IFDEF("M4\"_YY_NO_FLEX_FREE", ! option_sense); } ;
    I_options_yyget_debug : 'yyget_debug' { ACTION_M4_IFDEF("M4\"_YY_NO_GET_DEBUG", ! option_sense); } ;
    I_options_yyset_debug : 'yyset_debug' { ACTION_M4_IFDEF("M4\"_YY_NO_SET_DEBUG", ! option_sense); } ;
    I_options_yyget_extra : 'yyget_extra' { ACTION_M4_IFDEF("M4\"_YY_NO_GET_EXTRA", ! option_sense); } ;
    I_options_yyset_extra : 'yyset_extra' {    ACTION_M4_IFDEF("M4\"_YY_NO_SET_EXTRA", ! option_sense); } ;
    I_options_yyget_leng : 'yyget_leng' {      ACTION_M4_IFDEF("M4\"_YY_NO_GET_LENG", ! option_sense); } ;
    I_options_yyget_text : 'yyget_text' {      ACTION_M4_IFDEF("M4\"_YY_NO_GET_TEXT", ! option_sense); } ;
    I_options_yyget_column : 'yyget_column' {    ACTION_M4_IFDEF("M4\"_YY_NO_GET_COLUMN", ! option_sense); } ;
    I_options_yyset_column : 'yyset_column' {    ACTION_M4_IFDEF("M4\"_YY_NO_SET_COLUMN", ! option_sense); } ;
    I_options_yyget_lineno : 'yyget_lineno' {    ACTION_M4_IFDEF("M4\"_YY_NO_GET_LINENO", ! option_sense); } ;
    I_options_yyset_lineno : 'yyset_lineno' {    ACTION_M4_IFDEF("M4\"_YY_NO_SET_LINENO", ! option_sense); } ;
    I_options_yyget_in : 'yyget_in' {        ACTION_M4_IFDEF("M4\"_YY_NO_GET_IN", ! option_sense); } ;
    I_options_yyset_in : 'yyset_in' {        ACTION_M4_IFDEF("M4\"_YY_NO_SET_IN", ! option_sense); } ;
    I_options_yyget_out : 'yyget_out' {       ACTION_M4_IFDEF("M4\"_YY_NO_GET_OUT", ! option_sense); } ;
    I_options_yyset_out : 'yyset_out' {       ACTION_M4_IFDEF("M4\"_YY_NO_SET_OUT", ! option_sense); } ;
    I_options_yyget_lval : 'yyget_lval' {      ACTION_M4_IFDEF("M4\"_YY_NO_GET_LVAL", ! option_sense); } ;
    I_options_yyset_lval : 'yyset_lval' {      ACTION_M4_IFDEF("M4\"_YY_NO_SET_LVAL", ! option_sense); } ;
    I_options_yyget_lloc : 'yyget_lloc' {      ACTION_M4_IFDEF("M4\"_YY_NO_GET_LLOC", ! option_sense); } ;
    I_options_yyset_lloc : 'yyset_lloc' {      ACTION_M4_IFDEF("M4\"_YY_NO_SET_LLOC", ! option_sense); } ;
	I_options_extra_type : 'extra-type'	{ Type=TOK_EXTRA_TYPE; } ;
	I_options_outfile : 'outfile' {	Type=TOK_OUTFILE; } ;
	I_options_prefix : 'prefix' { Type=TOK_PREFIX; } ;
	I_options_yyclass : 'yyclass' {	Type=TOK_YYCLASS; } ;
	I_options_header_file : 'header' '-file'? { Type=TOK_HEADER_FILE; } ;
	I_options_tables_file : 'tables-file' { Type=TOK_TABLES_FILE; } ;
	I_options_tables_verify : 'tables-verify'  {
                    tablesverify = option_sense;
                    if(!tablesext && option_sense)
                        tablesext = true;
         } ;
	I_options_string : '"' ~('"' | '\n')* '"'	{
			if(yyleng-1 < MAXLINE)
        	{
				strncpy( nmstr, yytext + 1, nmstr.Length );
			}
			else
			{
			   synerr("Option line too long\n");
			   FLEX_EXIT(EXIT_FAILURE);
			}
			//nmstr[nmstr.Length - 1] = '\0';
			Type=NAME;
		} ;			

mode PICKUPDEF;

	I_pickupdef_ws : Ws -> skip ;
	I_pickupdef_notws : NotWs ~('\r' | '\n')* {
			if(yyleng < MAXLINE)
 		    {
				strncpy( nmdef, yytext, nmdef.Length );
 		    }
 		    else
 		    {
				format_synerr("Definition value for {%s} too long " +  nmstr);
 		        FLEX_EXIT(EXIT_FAILURE);
			}
			/* Skip trailing whitespace. */
			{
			    int i = strlen( nmdef );
			    while (i > 0 && (nmdef[i-1] == ' ' || nmdef[i-1] == '\t'))
			       --i;
			    //nmdef[i] = '\0';
			}
			ndinstal( nmstr, nmdef );
			didadef = true;
		} -> skip ;
	I_pickupdef_nl : Nl {
			if ( ! didadef )
				synerr("incomplete name definition");
			BEGIN(INITIAL);
			++linenum;
		} -> skip;

mode PERCENT_BRACE_ACTION;
I_percent_brace_action : ;

mode RECOVER;

	I_recover_bl : .* Nl { ++linenum; BEGIN(INITIAL); } ;

mode SC;

	I_sc_optwsnloptws : OptWs Nl OptWs { ++linenum; } ;
	I_sc_comst : (',' | '*') { Type=yytext[0]; } ;
	I_sc_gt : '>' { BEGIN(SECT2); Type='>'; } ;
	I_sc_gto : '>' '/^' { BEGIN(CARETISBOL); Type='>'; } ;
	I_sc_scname : Name { RETURNNAME(); } ;
	I_sc_dot : . {
			format_synerr("bad <start condition>: " +
				yytext );
		} ;




mode SECT2PROLOG;

	I_sect2prolog_peropen : '%{' { this.InputStream.LA(-1) == '\n' }? { ++bracelevel; yyless( 2 );	/* eat only %{ */ } ;
	I_sect2prolog_perclose : '%}' { this.InputStream.LA(-1) == '\n' }? { --bracelevel; yyless( 2 );	/* eat only %{ */ } ;
	I_sect2prolog_sb : Ws { this.InputStream.LA(-1) == '\n' }? { START_CODEBLOCK(true); /* indented code in prolog */ } ;
	I_sect2prolog_notws : NotWs { this.InputStream.LA(-1) == '\n' }? .* {
			/* non-indented code */
			if ( bracelevel <= 0 )
			{
				/* not in %{ ... %} */
				yyless( 0 );	/* put it all back */
				yy_set_bol( 1 );
				mark_prolog();
				BEGIN(SECT2);
			} else {
				START_CODEBLOCK(true);
			}
		} ;
	I_sect2prolog_dot : . { ACTION_ECHO(); } ;
	I_sect2prolog_eof : EOF {
			mark_prolog();
			sectnum = 0;
			yyterminate(); /* to stop the parser */
			} ;


mode SECT2;

	I_sect2_optwsln : OptWs { this.InputStream.LA(-1) == '\n' }? Nl { ++linenum; /* allow blank lines in section 2 */ } ;
	I_sect2_optwsperop : OptWs { this.InputStream.LA(-1) == '\n' }? '%{' {
			indented_code = false;
			doing_codeblock = true;
			bracelevel = 1;
			BEGIN(PERCENT_BRACE_ACTION);
		} ;
	I_sect2_optwslt : OptWs { this.InputStream.LA(-1) == '\n' }? '<' {
            /* Allow "<" to appear in (?x) patterns. */
            if (!sf_skip_ws())
                BEGIN(SC);
            Type='<';
        } ;
	I_sect2_optwsup :  OptWs { this.InputStream.LA(-1) == '\n' }? '^' { Type='^'; } ;
	I_sect2_dq : '"' { BEGIN(QUOTE); Type= '"'; } ;
	I_sect2_ocdigit : '{/' Digit {
			BEGIN(NUM);
			if ( lex_compat || posix_compat )
				Type= BEGIN_REPEAT_POSIX;
			else
				Type= BEGIN_REPEAT_FLEX;
		} ;
	I_sect2_dolblanknl : '$/' (Blank | Nl) { Type= '$'; } ;
	I_sect2_wsperoc : Ws '%{' {
			bracelevel = 1;
			BEGIN(PERCENT_BRACE_ACTION);
			if ( in_rule )
			{
				doing_rule_action = true;
				in_rule = false;
				Type= '\n';
			}
		} ;
	I_sect2_wsbar : Ws '"' .* Nl {
            if (sf_skip_ws()){
                /* We're in the middle of a (?x: ) pattern. */
                /* Push back everything starting at the "|" */
                int amt = 0;// (int) (strchr (yytext, '|') - yytext);
                yyless(amt);
            }
            else {
                add_action("]\"]");
                continued_action = true;
                ++linenum;
                Type= '\n';
            }
        } ;
	I_sect2_wscom : Ws { this.InputStream.LA(-1) == '\n' }? '/*' {
            if (sf_skip_ws()){
                /* We're in the middle of a (?x: ) pattern. */
                yy_push_state(COMMENT_DISCARD);
            }
            else{
                yyless( yyleng - 2 );	/* put back '/', '*' */
                bracelevel = 0;
                continued_action = false;
                BEGIN(ACTION);
            }
		} ;
	I_sect2_upws : Ws { this.InputStream.LA(-1) == '\n' }? { /* allow indented rules */ ; } ;
	I_sect2_ws : Ws {
        if (sf_skip_ws()){
            /* We're in the middle of a (?x: ) pattern. */
        }
        else{
            /* This rule is separate from the one below because
                * otherwise we get variable trailing context, so
                * we can't build the scanner using -{f,F}.
                */
            bracelevel = 0;
            continued_action = false;
            BEGIN(ACTION);

            if ( in_rule )
                {
                doing_rule_action = true;
                in_rule = false;
                Type= '\n';
                }
	        }
		} ;
	I_sect2_optwsnl : OptWs Nl {
            if (sf_skip_ws()){
                /* We're in the middle of a (?x: ) pattern. */
                ++linenum;
            }
            else{
                bracelevel = 0;
                continued_action = false;
                BEGIN(ACTION);
                unput( '\n' );	/* so <ACTION> sees it */

                if ( in_rule )
                    {
                    doing_rule_action = true;
                    in_rule = false;
                    Type= '\n';
                    }
            }
		} ;
	I_sect2_upoptwseof : OptWs* EOF { Type=TokenConstants.EOF; } ;

	I_sect2_perper : '%%' { this.InputStream.LA(-1) == '\n' }? .* {
			sectnum = 3;
			BEGIN(no_section3_escape ? SECT3_NOESCAPE : SECT3);
			outn("/* Begin user sect3 */");
			yyterminate(); /* to stop the parser */
		} ;
	I_sect2_bigfatthing : '[' ( First_ccl_char | Ccl_expr )
		( Ccl_char | Ccl_expr )* {
			int cclval;
			if(yyleng < MAXLINE)
			{
				strncpy( nmstr, yytext, nmstr.Length );
			}
			else
			{
				synerr("Input line too long\n");
				FLEX_EXIT(EXIT_FAILURE);
			}
			/* Check to see if we've already encountered this
			 * ccl.
			 */
			if (false /* <--- This "0" effectively disables the reuse of a
                   * character class (purely based on its source text).
                   * The reason it was disabled is so yacc/bison can parse
                   * ccl operations, such as ccl difference and union.
                   */
                &&  (cclval = ccllookup( nmstr )) != 0 )
				{
				if ( input() != ']' )
					synerr("bad character class");

				yylval = cclval;
				++cclreuse;
				Type= PREVCCL;
			}
			else
			{
				/* We fudge a bit.  We know that this ccl will
				 * soon be numbered as lastccl + 1 by cclinit.
				 */
				cclinstal( nmstr, lastccl + 1 );

				/* Push back everything but the leading bracket
				 * so the ccl can be rescanned.
				 */
				yyless( 1 );

				BEGIN(FIRSTCCL);
				Type= '[';
			}
		} ;
	I_sect2_minus : '{-}' {  Type=CCL_OP_DIFF; } ;
	I_sect2_plus : '{+}' { Type=CCL_OP_UNION; } ;

    /* Check for :space: at the end of the rule so we don't
     * wrap the expanded regex in '(' ')' -- breaking trailing
     * context.
     */
	I_sect2_name : '{' Name '}' Space? {
			string nmdefptr;
            int end_is_ws;
			char end_ch;

            end_ch = yytext[yyleng-1];
            end_is_ws = end_ch != '}' ? 1 : 0;

 			if(yyleng-1 < MAXLINE)
			{
				strncpy( nmstr, yytext + 1, nmstr.Length );
 			}
 			else
 			{
 				synerr("Input line too long\n");
 				FLEX_EXIT(EXIT_FAILURE);
 			}
			//nmstr[yyleng - 2 - end_is_ws] = '\0';  /* chop trailing brace */

			if ( (nmdefptr = ndlookup( nmstr )) == null )
				format_synerr(
				 "undefined definition " + nmstr );

			else
			{ /* push back name surrounded by ()'s */
				int len = strlen( nmdefptr );
                if (end_is_ws != 0)
                    unput(end_ch);

				if ( lex_compat || nmdefptr[0] == '^' ||
				     (len > 0 && nmdefptr[len - 1] == '$')
                     || (end_is_ws != 0 && trlcontxt && !sf_skip_ws()))
					{ /* don't use ()'s after all */
					PUT_BACK_STRING(nmdefptr, 0);

					if ( nmdefptr[0] == '^' )
						BEGIN(CARETISBOL);
				}
				else
				{
					unput(')');
					PUT_BACK_STRING(nmdefptr, 0);
					unput('(');
				}
			}
		} ;
	I_sect2_opencomment : '/*' {
			if (sf_skip_ws())
				yy_push_state(COMMENT_DISCARD);
            else
			{
				/* Push back the "*" and return "/" as usual. */
				yyless(1);
				Type='/';
            }
        } ;
	I_sect2_opqp : '(?#' {
			if (lex_compat || posix_compat){
				/* Push back the "?#" and treat it like a normal parens. */
				yyless(1);
				sf_push(); 
				Type='(';
			}
			else
				yy_push_state(EXTENDED_COMMENT);
		} ;
	I_sect2_opq : '(?' {
			sf_push();
			if (lex_compat || posix_compat)
				/* Push back the "?" and treat it like a normal parens. */
				yyless(1);
			else
				BEGIN(GROUP_WITH_PARAMS);
			Type='(';
		} ;
	I_sect2_op : '(' { sf_push(); Type='('; } ;
	I_sect2_cp : ')' {
			if (_sf_top_ix > 0) {
				sf_pop();
				Type= ')';
			} else
				synerr("unbalanced parenthesis");
		} ;
	I_sect2_end : ('/' | '|' | '*' | '+' | '?' | '.' | '(' | ')' | '{' | '}') { Type=yytext[0]; } ;
	I_sect2_dot : .	{ RETURNCHAR(); } ;

mode SECT3;

	I_sect3_m4qstart : M4qstart { /* fputs(escaped_qstart, yyout); */ } ;
	I_sect3_m4qend : M4qend { /* fputs(escaped_qend, yyout); */ } ;
	I_sect3_echo1 : ('^' | '[' | ']')* { ECHO(); } ;
	// Unclear what [][] means.

mode SECT3_NOESCAPE;

	I_sect3_noescape_m4qstart : M4qstart { /* ffprintf(yyout, "[""[%s]""]", escaped_qstart); */ } ;
	I_sect3_noescape_m4qend : M4qend { /* fprintf(yyout, "[""[%s]""]", escaped_qend); */ } ;
	// Unclear what [][] means.
