%{
import net.ripe.db.whois.common.rpsl.AttributeParser;
import net.ripe.db.whois.common.rpsl.ParserHelper;
/*
  filename: mp_peer.y

  description:
    Defines the grammar for an RPSLng mp-peer attribute.
    Derived from peer.y.

  notes:
    Defines tokens for the associated lexer, mp_peer.flex.
*/

%}

%token TKN_SIMPLE_PROTOCOL TKN_NON_SIMPLE_PROTOCOL
%token TKN_IPV4 TKN_IPV6 TKN_IPV6DC TKN_RTRSNAME TKN_PRNGNAME
%token TKN_ASNO TKN_SMALLINT
%token KEYW_ASNO KEYW_FLAP_DAMP KEYW_PEERAS
%token <sval> TKN_DNS
%type <sval> domain_name

%%

mp_peer: TKN_SIMPLE_PROTOCOL TKN_IPV4
| TKN_SIMPLE_PROTOCOL TKN_IPV6
| TKN_SIMPLE_PROTOCOL TKN_IPV6DC
| TKN_SIMPLE_PROTOCOL domain_name {
    ParserHelper.validateDomainName($2);
}
| TKN_SIMPLE_PROTOCOL TKN_RTRSNAME
| TKN_SIMPLE_PROTOCOL TKN_PRNGNAME
| TKN_NON_SIMPLE_PROTOCOL TKN_IPV4   bgp_opt
| TKN_NON_SIMPLE_PROTOCOL TKN_IPV6   bgp_opt
| TKN_NON_SIMPLE_PROTOCOL TKN_IPV6DC bgp_opt
| TKN_NON_SIMPLE_PROTOCOL domain_name bgp_opt {
    ParserHelper.validateDomainName($2);
}
| TKN_NON_SIMPLE_PROTOCOL TKN_RTRSNAME bgp_opt
| TKN_NON_SIMPLE_PROTOCOL TKN_PRNGNAME bgp_opt
;

domain_name: TKN_DNS
| domain_name '.' TKN_DNS
;

bgp_opt: KEYW_ASNO '(' TKN_ASNO ')'
| KEYW_ASNO '(' KEYW_PEERAS ')'
| flap_damp ',' KEYW_ASNO '(' TKN_ASNO ')'
| flap_damp ',' KEYW_ASNO '(' KEYW_PEERAS ')'
| KEYW_ASNO '(' TKN_ASNO ')' ',' flap_damp
| KEYW_ASNO '(' KEYW_PEERAS ')' ',' flap_damp
;

flap_damp: KEYW_FLAP_DAMP '(' ')'
| KEYW_FLAP_DAMP '(' TKN_SMALLINT ','
                     TKN_SMALLINT ','
                     TKN_SMALLINT ','
                     TKN_SMALLINT ','
                     TKN_SMALLINT ','
                     TKN_SMALLINT ')'
;

%%

private MpPeerLexer lexer;

private int yylex() {
	int yyl_return = -1;
	try {
		yyl_return = lexer.yylex();
	}
	catch (java.io.IOException e) {
		ParserHelper.log(e);
	}
	return yyl_return;
}

public void yyerror(final String error) {
    String errorMessage = (yylval.sval == null ? error : yylval.sval);
    ParserHelper.parserError(errorMessage);
}

@Override
public Void parse(final String attributeValue) {
	lexer = new MpPeerLexer(new java.io.StringReader(attributeValue), this);
    final int result = yyparse();
	if (result > 0) {
	    throw new IllegalArgumentException("Unexpected parse result: " + result);
	}
	return null;
}
