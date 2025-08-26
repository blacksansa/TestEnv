#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"
#INCLUDE "TBICONN.CH"

User Function ORTR813(cModelo)
Default cModelo := "A"

If cModelo == "A"
	ORTR813A()
Endif

If cModelo == "B"
	ORTR813B()
Endif

If cModelo == "C"
	ORTR813C()
Endif

Return 

Static Function ORTR813B()

Local cQry		:= ""
Private aPergs   	:= {}
Private aRet	   	:= {}
Private cTitulo		:= "Produtos Vs. Grupos"
Private nomeprog    := "ORTR813"
Private cGrupoDe  := space(4)
Private cGrupoAte := "ZZZZ"
Private cProdDe   := space(10)
Private cProdAte  := "ZZZZZZZZZZ"
Private aReport		:= {}

	if cEmpAnt <> "03"
		MsgBox("O Acesso a esta rotina é exclusivo da unidade 03", "Unidade Invalida", "INFO")
		return
	endif
  
// PERGUNTAS
aAdd( aPergs ,{1,"Grupo de"           , cGrupoDe	, ""	  , ".T." , 'SBM', '.T.', 50,.F.})
aAdd( aPergs ,{1,"Grupo Ate"          , cGrupoAte	, ""    , ".T."	, 'SBM', '.T.', 50,.T.})
aAdd( aPergs ,{1,"Produto de"         , cProdDe	  , ""	  , ".T." , 'SB1', '.T.', 50,.F.})
aAdd( aPergs ,{1,"Produto Ate"        , cProdAte	, ""    , ".T."	, 'SB1', '.T.', 50,.T.})
aAdd( aPergs ,{4,"Somente Sem Grupo"  ,.F.,"",50,".T.",.F.})
aAdd( aPergs ,{4,"Somente PA"	  	  ,.T.,"",50,".T.",.F.})

If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, nomeprog + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
	Return
EndIf

cGrupoDe  := MV_PAR01
cGrupoAte := MV_PAR02
cProdDe   := MV_PAR03
cProdAte  := MV_PAR04
lSemGrupo := MV_PAR05
lSomenPA  := MV_PAR06

cQry := "SELECT B1_GRUPO, B1_TIPO, B1_COD, B1_DESC, BM_DESC
cQry += "  FROM SIGA.SB1030 B1
cQry += "  LEFT JOIN SIGA.SBM200 SBM ON BM_GRUPO = B1_GRUPO
cQry += "                           AND BM_FILIAL = '  '
cQry += "                           AND SBM.D_E_L_E_T_ = ' '
cQry += " WHERE B1_FILIAL = '  '
cQry += "   AND B1.D_E_L_E_T_ = ' '
cQry += "   AND B1_MSBLQL <> '1'
cQry += "   AND B1_XFORLIN = ' '
cQry += "   AND B1_XCODBAS = ' '
If lSomenPA
	cQry += "   AND B1_TIPO IN ('PA')
Else
	cQry += "   AND B1_TIPO NOT LIKE 'C%'	
   	cQry += "   AND B1_TIPO NOT LIKE 'G%'   
   	cQry += "   AND B1_TIPO NOT LIKE 'I%'   
   	cQry += "   AND B1_GRUPO NOT LIKE 'C%'
	cQry += "   AND B1_GRUPO NOT IN
    cQry += "      ('5050', '5060', '5010', '5042', '5020', '5011', '5044', '5041',
    cQry += "       '5990', '5021', '5028', '5025', '5029', '5030', '5040', '5080',
    cQry += "       '5100', '5502', '5300', '7433', '7434', '7435', '7436', '6132',
    cQry += "       '688 ', '5022', '2343', '2344', '2345', '2353', '2626', '6644',
    cQry += "       '6645', '7432', '7447', '7449', '7452', '7902')
Endif
cQry += "   AND B1_COD >= '"+cProdDe+"'
cQry += "   AND B1_COD <= '"+cProdAte+"'
cQry += "   AND B1_GRUPO >= '"+cGrupoDe+"'
cQry += "   AND B1_GRUPO <= '"+cGrupoAte+"'
If lSemGrupo
	cQry += "   AND B1_GRUPO = ' '
Else	
	cQry += "   AND SUBSTR(B1_DESC, 1, 5) <> SUBSTR(BM_DESC, 1, 5)
Endif

cQry += " ORDER BY B1_TIPO, B1_GRUPO, B1_COD

U_ORTQUERY(cQry, "OTR813")

While OTR813->(!EOF())

    _cCpo01 := Padr(OTR813->B1_GRUPO,10)
    _cCpo02 := Padr(OTR813->B1_TIPO	,05)    
    _cCpo03 := Padr(OTR813->B1_COD	,15)
    _cCpo04 := Padr(OTR813->B1_DESC	,55)    
	_cCpo05 := Padr(OTR813->BM_DESC ,55)    	
	
	// ate 165 chars
	AADD(aReport,{  _cCpo01,;
					_cCpo02,;
					_cCpo03,;
					_cCpo04,;
					_cCpo05})
	
	OTR813->(dbSkip())
EndDo

IF Len(aReport) > 0
	U_ORTR538("ORTR813", cTitulo, {"Grupo", "Tipo", "Codigo", "Descricao Produto","Descricao Grupo"}, aReport, .T., .F., {"Objetivo: Mostrar os produtos cuja descricão difere do seu grupo, ou que estejam sem grupo associado."})
	
Else
	Alert("Não foram encontrados registros com os dados informados.")	
Endif

Return

Static Function ORTR813A()
Local cQry		:= ""
Private aPergs   	:= {}
Private aRet	   	:= {}
Private cTitulo		:= "Insumos com problemas"
Private nomeprog    := "ORTR813"
Private cGrupoDe  := space(4)
Private cGrupoAte := "ZZZZ"
Private cProdDe   := space(10)
Private cProdAte  := "ZZZZZZZZZZ"
Private dDatDe		:= ctod("  /  /  ")
Private dDatAte		:= ddatabase
Private aReport		:= {}

	if cEmpAnt <> "03"
		MsgBox("O Acesso a esta rotina é exclusivo da unidade 51", "Unidade Invalida", "INFO")
		return
	endif
  
// PERGUNTAS
aAdd( aPergs ,{1,"Grupo de"           , cGrupoDe	, ""	  , ".T." , 'SBM', '.T.', 50,.F.})
aAdd( aPergs ,{1,"Grupo Ate"          , cGrupoAte	, ""    , ".T."	, 'SBM', '.T.', 50,.T.})
aAdd( aPergs ,{1,"Produto de"         , cProdDe	  , ""	  , ".T." , 'SB1', '.T.', 50,.F.})
aAdd( aPergs ,{1,"Produto Ate"        , cProdAte	, ""    , ".T."	, 'SB1', '.T.', 50,.T.})
aadd( aPergs ,{1,"Fora de Linha de"   , dDatDe	  , "@d"  , ''	  ,	     , '.T.', 40,.F.})
aadd( aPergs ,{1,"Fora de Linha Ate"  , dDatAte   , "@d"  , ''	  ,	     , '.T.', 40,.F.})

If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, nomeprog + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
	Return
EndIf

cGrupoDe  := MV_PAR01
cGrupoAte := MV_PAR02
cProdDe   := MV_PAR03
cProdAte  := MV_PAR04
dDatDe    := MV_PAR05
dDatAte   := MV_PAR06


cQry := "SELECT DISTINCT G1_COMP,
cQry += "                BCOMP.B1_DESC,
cQry += "                BCOMP.B1_XFORLIN,
cQry += "                BCOMP.B1_XDECOMP,
cQry += "                ZZM_DESC,
cQry += "                ZZM_TOTAL
//cQry += "  FROM SIGA."+RetSqlName("SG1")+" G1, SIGA."+RetSqlName("ZZM")+" ZM, SIGA."+RetSqlName("SB1")+" B1, SIGA."+RetSqlName("SB1")+" BCOMP
cQry += "  FROM SIGA.SG1030 G1, SIGA."+RetSqlName("ZZM")+" ZM, SIGA.SB1030 B1, SIGA.SB1030 BCOMP
cQry += " WHERE B1.B1_FILIAL = '"+xFilial("SB1")+"'
cQry += "   AND B1.B1_XCODBAS = '               '
cQry += "   AND B1.B1_MSBLQL <> '1'
cQry += "   AND (B1.B1_XFORLIN = '        ' OR B1.B1_XFORLIN >= '20200101')
//cQry += "   AND G1_FILIAL = '"+xFilial("SG1")+"'
cQry += "   AND G1_FILIAL = '02'
cQry += "   AND G1.D_E_L_E_T_ = ' '
cQry += "   AND B1.D_E_L_E_T_ = ' '
cQry += "   AND ZM.D_E_L_E_T_(+) = ' '
cQry += "   AND ZZM_COD(+) = G1_COMP
cQry += "   AND G1_COD = B1.B1_COD
cQry += "   AND ZZM_DESC IS NULL
cQry += "   AND BCOMP.B1_COD = G1_COMP

cQry += "   AND BCOMP.B1_GRUPO >= '" + cGrupoDe  + "' "
cQry += "   AND BCOMP.B1_GRUPO <= '" + cGrupoAte + "' "
cQry += "   AND BCOMP.B1_COD >= '" + cProdDe  + "' "
cQry += "   AND BCOMP.B1_COD <= '" + cProdAte + "' "

If !empty(dDatDe)
  cQry += "   AND BCOMP.B1_XFORLIN >= '" + dtos(dDatDe)  + "' "
  cQry += "   AND BCOMP.B1_XFORLIN <= '" + dtos(dDatAte) + "' "
Endif

cQry += "   AND EXISTS (SELECT 'X'
//cQry += "          FROM SIGA."+RetSqlName("SG1")+" SG1
cQry += "          FROM SIGA.SG1030 SG1
//cQry += "         WHERE G1_FILIAL = '"+xFilial("SG1")+"'
cQry += "         WHERE G1_FILIAL = '02'
cQry += "           AND D_E_L_E_T_ = ' '
cQry += "           AND G1_COMP = G1.G1_COMP)
cQry += "   AND NOT EXISTS (SELECT 'X'
//cQry += "          FROM SIGA."+RetSqlName("SG1")+" SG1
cQry += "          FROM SIGA.SG1030 SG1
//cQry += "         WHERE G1_FILIAL = '"+xFilial("SG1")+"'
cQry += "         WHERE G1_FILIAL = '02'
cQry += "           AND D_E_L_E_T_ = ' '
cQry += "           AND G1_COD = G1.G1_COMP)
cQry += " ORDER BY BCOMP.B1_XFORLIN, G1_COMP

U_ORTQUERY(cQry, "OTR813")

While OTR813->(!EOF())
	  cObs := "Insumo sem Custo."
    
    If !empty(OTR813->B1_XFORLIN)
      nDif := DateDiffDay( STOD(OTR813->B1_XFORLIN) , dDatabase )
      cObs := "Insumo sem Custo - Produto fora de linha a "+Alltrim(Str(nDif))+" dias."
    Endif

    _cCpo01 := Padr(OTR813->G1_COMP      ,15)
    _cCpo02 := Padr(OTR813->B1_DESC      ,40)    
    _cCpo03 := Padr(Dtoc(Stod(OTR813->B1_XFORLIN))  ,15)
    _cCpo04 := Padr(cObs ,55)    
	
	// ate 165 chars
	AADD(aReport,{  _cCpo01,;
					_cCpo02,;
					_cCpo03,;
					_cCpo04})
	
	OTR813->(dbSkip())
EndDo

IF Len(aReport) > 0
	U_ORTR538("ORTR813", cTitulo, {"Insumo", "Descrição", "Fora de Linha", "Observacao"}, aReport, .T., .F.)
Else
	Alert("Não foram encontrados registros com os dados informados.")	
Endif

Return

Static Function ORTR813C()

Local cQry		:= ""
Private aPergs   	:= {}
Private aRet	   	:= {}
Private cTitulo		:= "Produtos sem Composicao"
Private nomeprog    := "ORTR813"
Private cGrupoDe  := space(4)
Private cGrupoAte := "ZZZZ"
Private cProdDe   := space(10)
Private cProdAte  := "ZZZZZZZZZZ"
Private aReport		:= {}

	if cEmpAnt <> "03"
		MsgBox("O Acesso a esta rotina é exclusivo da unidade 03", "Unidade Invalida", "INFO")
		return
	endif
  
// PERGUNTAS
aAdd( aPergs ,{1,"Grupo de"           , cGrupoDe	, ""	  , ".T." , 'SBM', '.T.', 50,.F.})
aAdd( aPergs ,{1,"Grupo Ate"          , cGrupoAte	, ""    , ".T."	, 'SBM', '.T.', 50,.T.})
aAdd( aPergs ,{1,"Produto de"         , cProdDe	  , ""	  , ".T." , 'SB1', '.T.', 50,.F.})
aAdd( aPergs ,{1,"Produto Ate"        , cProdAte	, ""    , ".T."	, 'SB1', '.T.', 50,.T.})

If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, nomeprog + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
	Return
EndIf

cGrupoDe  := MV_PAR01
cGrupoAte := MV_PAR02
cProdDe   := MV_PAR03
cProdAte  := MV_PAR04

cQry := "SELECT B1_GRUPO, B1_COD, B1_DESC, B1_TIPO
cQry += "  FROM SIGA.SB1030 SB1, SIGA.REGRASMAR RM
cQry += " WHERE SB1.D_E_L_E_T_ = ' '
cQry += "   AND B1_FILIAL = '  '
cQry += "   AND B1_GRUPO <> ' '
cQry += "   AND B1_XFORLIN = ' '
cQry += "   AND B1_XCODBAS = ' '
cQry += "   AND B1_MSBLQL <> '1'
cQry += "   AND TABELA = 'SBM'
cQry += "   AND RM.MARFIL = 'S'
cQry += "   AND B1_TIPO NOT IN
cQry += "       ('MP', 'CR', 'MB', 'MD', 'TC', 'CF', 'GG', 'ME', 'ML', 'MQ', 'RE', 'PM', 'PI')
cQry += "   AND CHAVE = B1_GRUPO

cQry += "   AND B1_COD >= '"+cProdDe+"'
cQry += "   AND B1_COD <= '"+cProdAte+"'
cQry += "   AND B1_GRUPO >= '"+cGrupoDe+"'
cQry += "   AND B1_GRUPO <= '"+cGrupoAte+"'

cQry += "   AND NOT EXISTS (SELECT 'X'
cQry += "          FROM SIGA.SG1030 G1
cQry += "         WHERE G1_FILIAL = '02'
cQry += "           AND G1_COD = B1_COD
cQry += "           AND G1.D_E_L_E_T_ = ' ')
cQry += " ORDER BY B1_TIPO, B1_GRUPO, B1_COD

U_ORTQUERY(cQry, "OTR813")

While OTR813->(!EOF())

    _cCpo01 := Padr(OTR813->B1_GRUPO,10)
    _cCpo02 := Padr(OTR813->B1_TIPO	,05)    
    _cCpo03 := Padr(OTR813->B1_COD	,15)
    _cCpo04 := Padr(OTR813->B1_DESC	,55)       	
	
	// ate 165 chars
	AADD(aReport,{  _cCpo01,;
					_cCpo02,;
					_cCpo03,;
					_cCpo04})
	
	OTR813->(dbSkip())
EndDo

IF Len(aReport) > 0
	U_ORTR538("ORTR813", cTitulo, {"Grupo", "Tipo", "Codigo", "Descricao Produto"}, aReport, .T., .F., {"Objetivo: Mostrar os produtos cuja composicao não foi cadastrada."})
	
Else
	Alert("Não foram encontrados registros com os dados informados.")	
Endif

Return
