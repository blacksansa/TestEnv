#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#Include 'Totvs.ch'
#INCLUDE "TBICONN.CH"

//TEMPLATE BEGIN
User Function ORTR813H()

	Local aArea   := GetArea()
	Local oReport := Nil
	Local aRet    := {}
	Local c_Titulo := "Relatorio de Cobol vs Protheus"

	// Local aTipo   := {'TODOS', 'PA', 'PI', 'MD', 'MT', 'TC'}
	//Local aSegm   := {'1-INDUSTRIAL', '2-COMERCIAL', '3-FRANQUIAS', '4-TODOS'}
	Local aPergs  :=  {}

	Private cProDe, cProdAte      := ""
	Private cGrupoDe, cGrupoAte        := ""
	Private cSubGrupoDe, cSubGrupoAte  := ""

	//Private cTipo                    := ""
	//Private cSegm                    := ""
	Private eDivergent                 := .F.

// Adicione a nova pergunta no topo, como você queria.
	aadd(aPergs, {1, "Semana consulta:", Space(GetSX3Cache("DA0_CODTAB", "X3_TAMANHO")), , , "DA0", , 50, .T.})

	aadd(aPergs, {1, "Produto de: " , Space(GetSX3Cache("B1_COD", "X3_TAMANHO")) , , "MV_PAR02 <= MV_PAR03", "SB1", , 80, .F.})
	aadd(aPergs, {1, "Produto Até: " , Replicate("Z",GetSX3Cache("B1_COD", "X3_TAMANHO")) , , "MV_PAR02 <= MV_PAR03", "SB1", , 80, .F.})
	aadd(aPergs, {1, "Grupo de: " , Space(GetSX3Cache("BM_GRUPO", "X3_TAMANHO")) , , "MV_PAR04 <= MV_PAR05", "SBM", , 50, .F.})
	aadd(aPergs, {1, "Grupo Até: "  , Replicate("Z",GetSX3Cache("BM_GRUPO", "X3_TAMANHO")), , "MV_PAR04 <= MV_PAR05", "SBM", , 50, .F.})
	aadd(aPergs, {1, "SubGrupo de: " , Space(GetSX3Cache("BM_XSUBGRU", "X3_TAMANHO")) , , "MV_PAR06 <= MV_PAR07", "ZA" , , 50, .F.})
	aadd(aPergs, {1, "SubGrupo Até: ", Replicate("Z",GetSX3Cache("BM_XSUBGRU", "X3_TAMANHO")) , , "MV_PAR06 <= MV_PAR07", "ZA" , , 50, .F.})
	aadd(aPergs, {3, "Considerar Apenas Produtos com Divergencia ", 2 , {"SIM","NÃO"} , 100, , .F.})

	If !Parambox( aPergs, c_Titulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTR835" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
		MsgStop("Emissão do relatorio cancelada.","Atenção")
		Return
	else
		cSemanaCons := aRet[1] // Nova variável para a semana
		cProDe := aRet[2] // Ajustado para a nova posição
		cProdAte  := aRet[3] // Ajustado para a nova posição
		cGrupoDe   := aRet[4] // Ajustado para a nova posição
		cGrupoAte := aRet[5] // Ajustado para a nova posição
		cSubGrupoDe := aRet[6] // Ajustado para a nova posição
		cSubGrupoAte := aRet[7] // Ajustado para a nova posição
		//  cTipo        := aRet[8]
		//  cSegm        := aRet[9]
		lDiferenca  := IIF(aRet[8] = 2,.F.,.T.) // Ajustado para a nova posição
	EndIf

	oReport := fRodaRelat(UPPER(c_Titulo))
	oReport:PrintDialog()

	RestArea(aArea)

Return
//TEMPLATE BEGIN

Static Function fRodaRelat(cTitulo)

	Local oReport		:= Nil
	Local oSection1 	:= Nil

	oReport := TReport():New("ORTP813",cTitulo,"ORTP813",{|oReport| fExecRel(oReport)},UPPER(cTitulo)+" - ORTOBOM UNIDADE "+cEmpAnt)

	oReport:SetTotalInLine(.T.)         //Imprime total em Colunas
	oReport:NoUserFilter()              //Sem filtro
	oReport:HideParamPage()            //Sem tela de parametros
	oReport:SetLandScape()              //oReport:SetLandScape()
	oReport:oPage:setPaperSize(9)      //oReport:oPage:setPaperSize(12)

	//--------------------------------
	//Primeira Seçao do relatório
	//--------------------------------
	oSection1 := TRSection():New(oReport,"DADOS")
	oSection1:SetHeaderBreak(.T.)
	oSection1:SetLinesBefore(1)
	oSection1:lAutoSize := .F.
	oSection1:lBold := .T.

	TRCell():New(oSection1,"B1_COD",,"CODIGO")
	oSection1:Cell("B1_COD"):SetAutoSize(.F.)
	oSection1:Cell("B1_COD"):SetSize(20)

	TRCell():New(oSection1,"B1_DESC",,"DESCRICAO")
	oSection1:Cell("B1_DESC"):SetAutoSize(.T.)
	oSection1:Cell("B1_DESC"):SetSize(40)

	TRCell():New(oSection1,"B1_XMED",,"MEDIDAS")
	oSection1:Cell("B1_XMED"):SetAutoSize(.T.)
	oSection1:Cell("B1_XMED"):SetSize(40)

	TRCell():New(oSection1,"B1_TIPO",,"TIPO")
	oSection1:Cell("B1_TIPO"):SetAutoSize(.T.)
	oSection1:Cell("B1_TIPO"):SetSize(40)

	TRCell():New(oSection1,"B1_GRUPO",,"GRUPO")
	oSection1:Cell("B1_GRUPO"):SetAutoSize(.T.)
	oSection1:Cell("B1_GRUPO"):SetSize(40)

	TRCell():New(oSection1,"DA1_XMARCS",,"PREÇO CUSTO COBOL")
	oSection1:Cell("DA1_XMARCS"):SetAutoSize(.T.)
	oSection1:Cell("DA1_XMARCS"):SetSize(40)

	TRCell():New(oSection1,"DA1_XCUSTO",,"PREÇO CUSTO PROTHEUS")
	oSection1:Cell("DA1_XCUSTO"):SetAutoSize(.T.)
	oSection1:Cell("DA1_XCUSTO"):SetSize(40)

    TRCell():New(oSection1,"DA1_XMARPR",,"PREÇO VENDA COBOL")
	oSection1:Cell("DA1_XMARPR"):SetAutoSize(.T.)
	oSection1:Cell("DA1_XMARPR"):SetSize(40)
	
	TRCell():New(oSection1,"DA1_XPRCVEN",,"PREÇO VENDA PROTHEUS")
	oSection1:Cell("DA1_XPRCVEN"):SetAutoSize(.T.)
	oSection1:Cell("DA1_XPRCVEN"):SetSize(40)



	//oBreak := TRBreak():New(oSection1,{||         },"Total",.F.)
	//TRFunction():New(oSection1:Cell("XX_REVISAO")  , , "COUNT", oBreak, , "@E 99999999999999999" , , .F., .F.)
	//RFunction():New(oSection1:Cell("XX_PONTUACAO"), , "SUM"  , oBreak, , "@E 999,999,999,999.9999", , .F., .F.)

	oSection1:SetPageBreak(.T.)
Return oReport

Static Function fExecRel(oReport)

	Local _aArea      := GetArea()
	Local cQry      := ""
	Local oSection1 := oReport:Section(1)
	Private oBreak

	//U_ORTCHKPLA("ORTP226",cEmpAnt,oReport:nDevice)

	// Query para o relatório simplificado
	cQry := " SELECT "
	cQry += "        B1_COD,"
	cQry += "        B1_DESC,"
	cQry += "        B1_XMED,"
	cQry += "        B1_TIPO,"
	cQry += "        B1_GRUPO,"
	cQry += "        BM_DESC,"
	cQry += "        B1_XMARKUP,"
	cQry += "        DA1_PRCVEN,"
	cQry += "        DA1_XCUSTO,"
	cQry += "        DA1_XMARPR,"
	cQry += "        DA1_XMARCS"
	cQry += "  FROM SIGA.DA1030 DA1"
	cQry += "      INNER JOIN SIGA.SB1030 SB1 ON B1_COD = DA1_CODPRO "
	cQry += "                   AND SB1.B1_FILIAL = ' '"
	cQry += "                   AND SB1.D_E_L_E_T_ = ' '"
	cQry += "      INNER JOIN SIGA.SBM200 SBM ON BM_FILIAL = ' '"
	cQry += "                   AND BM_GRUPO = B1_GRUPO"
	cQry += "                   AND SBM.D_E_L_E_T_ = ' '"
	cQry += "    WHERE DA1_FILIAL = ' ' AND"
	cQry += "     DA1.D_E_L_E_T_ = ' ' AND"
	cQry += "     DA1_CODTAB = '" + cSemanaCons + "'"
	cQry += " AND B1_GRUPO >= '" + cGrupoDe + "'"
	cQry += " AND B1_GRUPO <= '" + cGrupoAte + "'"
	cQry += " AND B1_COD >= '" + cProDe + "'"
	cQry += " AND B1_COD <= '" + cProdAte + "'"
	cQry += " AND DA1_DTUMOV = ' '"
	If lDiferenca

	    cQry += " and (DA1_PRCVEN <> DA1_XMARPR or DA1_XCUSTO <> DA1_XMARCS)"
	EndIf
	cQry += "    ORDER BY B1_COD"

    U_ORTQUERY(cQry, "ORTP813")

	ORTP813->(dbgotop())

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)

	While !("ORTP813")->(EOF())

		oReport:IncMeter()

		If oReport:Cancel()
			Exit
		EndIf
		oSection1:Cell("B1_COD" ):SetValue( ORTP813->B1_COD )
		oSection1:Cell("B1_DESC" ):SetValue( ORTP813->B1_DESC )
		oSection1:Cell("B1_XMED" ):SetValue( ORTP813->B1_XMED )
		oSection1:Cell("B1_TIPO" ):SetValue( ORTP813->B1_TIPO )
		oSection1:Cell("B1_GRUPO" ):SetValue( ORTP813->B1_GRUPO )
		oSection1:Cell("DA1_XPRCVEN" ):SetValue( ORTP813->DA1_PRCVEN )
		oSection1:Cell("DA1_XCUSTO" ):SetValue( ORTP813->DA1_XCUSTO )
		oSection1:Cell("DA1_XMARPR" ):SetValue( ORTP813->DA1_XMARPR )
		oSection1:Cell("DA1_XMARCS" ):SetValue( ORTP813->DA1_XMARCS )
		oSection1:PrintLine()
		ORTP813->(dbskip())

	Enddo
	oReport:SkipLine(2)
	oSection1:Finish()
	ORTP813->(DbCloseArea())
	oReport:EndPage()

	RestArea(_aArea)

Return(.T.)
