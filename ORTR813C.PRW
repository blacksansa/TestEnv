#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWBROWSE.CH"
#Include 'Totvs.ch'

User Function ORTR813C()

	Local aPergs      := {}
	Local aRet        := {}
	Private cTitulo   := "SUGESTA DE PRECO - COMERCIAL | "
	Private cSemana   := ""
	Private cAgru     := ""
	Private cCongela  := ""
	Private cCalculo  := ""
	Private cGrupoDe  := space(4)
	Private cGrupoAte := "ZZZZ"
	Private cProdDe   := space(15)
	Private cProdAte  := "ZZZZZZZZZZZZZZZ"
	Private cVaria    := ""
	Private lVaria    := .F.
	Private cTabAnt	  := ""
	Private lForLin   := .F.
	Default lSobMed   := .F.


	// Adicionar parametrizacao de grupo de/ate / produto de/ate

	aAdd( aPergs ,{1,"Semana         :",U_ORTP169A(),"@!"	,".T." 	 ,\'DA0\' ,".T."                  , 80, .T.   })
aAdd( aPergs ,{1,"Grupo de"		, cGrupoDe	, "" 	  , ".T." 	 ,\'SBM\', '.T.', 50,.F.})
aAdd( aPergs ,{1,"Grupo Ate"		, cGrupoAte	, "" 		, ".T." 	 ,\'SBM\', '.T.', 50,.T.})
aAdd( aPergs ,{1,"Produto de"	, cProdDe	  , "" 	  , ".T." 	 ,\'SB1\', '.T.', 50,.F.})
aAdd( aPergs ,{1,"Produto Ate"	, cProdAte	, "" 		, ".T." 	 ,\'SB1\', '.T.', 50,.T.})
aAdd( aPergs ,{2,"Visualizar     :", "Gerados",{"Gerados", "Simulacao"}						, 80, .F.,.F.})
aAdd( aPergs ,{2,"Visualizar     :","Relatorio Completo",{"Relatorio Completo", "Comercial","Dirigida 05", "Dirigida 06", "Dirigida 11", "Vendas Web", "Hotelaria","Casas Bahia"}						, 80, .F.,.F.})
	
	If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTR852" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
		Return
	EndIf 

	cSemana 	:= PadL( MV_PAR01, 3, "0" )
	cGrupoDe	:= MV_PAR02
	cGrupoAte	:= MV_PAR03
	cProdDe 	:= MV_PAR04
	cProdAte	:= MV_PAR05
	cCalculo	:= MV_PAR06
	cAgru 		:= MV_PAR07

	cAgrupamento(cAgru)
	oReport 	:= fRodaRelat(UPPER(cTitulo))
	oReport:PrintDialog()

Return

static function cAgrupamento(Agrupamento)
	DO CASE
		CASE Agrupamento == "Relatorio Completo"
		cTitulo += Agrupamento

		CASE Agrupamento == "Comercial"
		cAgru := "000300"
		cTitulo += Agrupamento 

		CASE Agrupamento == "Dirigida 5"
		cAgru := "000005"
		cTitulo += Agrupamento 

		CASE Agrupamento == "Dirigida 6"
		cAgru := "000006"
		cTitulo += Agrupamento 

		CASE Agrupamento == "Dirigida 11"
		cAgru := "000011"
		cTitulo += Agrupamento 

		CASE Agrupamento == "Dirigida 26"
		cAgru := "000026"
		cTitulo += Agrupamento 

		CASE Agrupamento == "Vendas Web"
		cAgru := "000121"
		cTitulo += Agrupamento 


		CASE Agrupamento == "Casas Bahia"
		cAgru := "000121"
		cTitulo += Agrupamento 

		CASE Agrupamento == "Hotelaria"
		cAgru := "000108"
		cTitulo += Agrupamento 

	EndCASE
	
return

Static Function fRodaRelat(cTitulo)

	Local oReport		:= Nil
	Local oSectionAgru 	:= Nil
	Local oSectionDetail 	:= Nil

	oReport 	:= TReport():New("ORTR813C",cTitulo,"ORTR813C",{|oReport| fExecRel(oReport)},UPPER(cTitulo)+" - ORTOBOM UNIDADE "+cEmpAnt)

	oReport:SetTotalInLine(.T.)
	oReport:NoUserFilter()
	oReport:HideParamPage()
	oReport:SetLandScape()
	oReport:oPage:setPaperSize(9)

	//--------------------------------
	// Seçao de Agrupamento
	//--------------------------------
	oSectionAgru 	:= TRSection():New(oReport,"AGRUPAMENTO")
	TRCell():New(oSectionAgru,"AGRU_DESC_CELL",,"AGRUPAMENTO")
    oSectionAgru:Cell("AGRU_DESC_CELL"):SetAutoSize(.T.)
    oSectionAgru:Cell("AGRU_DESC_CELL"):SetSize(100)
    oSectionAgru:lBold := .T.

	//--------------------------------
	// Seçao de Detalhe
	//--------------------------------
	oSectionDetail 	:= TRSection():New(oReport,"DADOS")
	oSectionDetail:SetHeaderBreak(.T.)
	oSectionDetail:SetLinesBefore(1)
	oSectionDetail:lAutoSize 		:= 	.F.
	oSectionDetail:lBold 		:= 	.F. // Details are not bold

	TRCell():New(oSectionDetail,"BM_GRUPO",,"GRUPO")
	oSectionDetail:Cell("BM_GRUPO"):SetAutoSize(.T.)
	oSectionDetail:Cell("BM_GRUPO"):SetSize(20)

	TRCell():New(oSectionDetail,"B1_COD",,"CODIGO")
	oSectionDetail:Cell("B1_COD"):SetAutoSize(.T.)
	oSectionDetail:Cell("B1_COD"):SetSize(20)

	TRCell():New(oSectionDetail,"MEDIDA",,"MEDIDA")
	oSectionDetail:Cell("MEDIDA"):SetAutoSize(.T.)
	oSectionDetail:Cell("MEDIDA"):SetSize(20)

	TRCell():New(oSectionDetail,"A_VISTA",,"A VISTA")
	oSectionDetail:Cell("A_VISTA"):SetAutoSize(.T.)
	oSectionDetail:Cell("A_VISTA"):SetSize(20)

	TRCell():New(oSectionDetail,"A30_DD",,"30 DD")
	oSectionDetail:Cell("A30_DD"):SetAutoSize(.T.)
	oSectionDetail:Cell("A30_DD"):SetSize(20)

	TRCell():New(oSectionDetail,"A60_DD",,"60 DD")
	oSectionDetail:Cell("A60_DD"):SetAutoSize(.T.)
	oSectionDetail:Cell("A60_DD"):SetSize(20)

	TRCell():New(oSectionDetail,"A90_DD",,"90 DD")
	oSectionDetail:Cell("A90_DD"):SetAutoSize(.T.)
	oSectionDetail:Cell("A90_DD"):SetSize(20)

	TRCell():New(oSectionDetail,"B1_XESPACO",,"ESP")
	oSectionDetail:Cell("B1_XESPACO"):SetAutoSize(.T.)
	oSectionDetail:Cell("B1_XESPACO"):SetSize(20)

Return oReport

Static Function fExecRel(oReport)

	Local _aArea 		:= GetArea()
	Local cQry 		:= ""
	Local oSectionAgru 	:= oReport:Section("AGRUPAMENTO")
	Local oSectionDetail 	:= oReport:Section("DADOS")
    Local cLastAgruDesc     := ""

	Local cTabGer 	:= cSemana

	cAlias 		:= U_ORTQUERY("SELECT MAX(DA1_DTUMOV) as quando FROM SIGA.PREDA1030 WHERE DA1_CODTAB = '"+cTabGer+"' ")
	_cLastData 	:= (cAlias)->quando
	(cAlias)->(DBCLOSEAREA())

	
	If cCalculo == "Simulacao"
		cTitulo 	:= cTitulo + " - Simulacao Semana: " + cTabGer + " "  
	Else
		cTitulo 	:= cTitulo + " - Semana : " + cTabGer + " "
	Endif
	
	cQry 		:= " SELECT 	RMZA.CHAVE,"
    cQry 		+= "    		RMZA.DESCRI AGRU_DESC,"
    cQry 		+= "    		RMZA.ORDEM,"
    cQry 		+= "    		BM_GRUPO,"
	cQry 		+= "    		BM_DESC GRUPO,"
	cQry 		+= "    		B1_COD,"
	cQry 		+= "    		B1_XCOMP,"
	cQry 		+= "    		B1_XLARG,"
	cQry 		+= "    		B1_XALT,"
	cQry 		+= "    		DA1_PRCVEN * 0.90 A_VISTA,"
	cQry 		+= "    		DA1_PRCVEN * 0.92 A30_DD, "
	cQry 		+= "    		DA1_PRCVEN * 0.96 A60_DD, "
	cQry 		+= "    		DA1_PRCVEN A90_DD , "
	cQry 		+= "    		B1_XESPACO

	If cCalculo == "Simulacao"

		cQry 		+= "   FROM SIGA.PREDA1030 DA1

	Else

		cQry 		+= "   FROM SIGA.DA1030 DA1

	Endif

	cQry 		+= "    		INNER JOIN SIGA.SB1030 SB1 ON B1_FILIAL = ' '"
    cQry 		+= "    		   AND B1_COD = DA1_CODPRO"
    cQry 		+= "    		   AND B1_XSEGMEN = '2' "
    cQry 		+= "    		   AND SB1.D_E_L_E_T_ = ' '"
    cQry 		+= "    		   AND SB1.D_E_L_E_T_ = ' '"
 	cQry 		+= "    		INNER JOIN SIGA.SBM200 SBM ON BM_FILIAL = ' '"
    cQry 		+= "    		                       AND BM_GRUPO = B1_GRUPO"
    cQry 		+= "    		                       AND SBM.D_E_L_E_T_ = ' '"

    cQry 		+= "    		                       INNER JOIN SIGA.REGRASMAR RMZA ON RMZA.TABELA = 'ZA'"
    cQry 		+= "    		                                                  AND RMZA.CHAVE = BM_XSUBGRU"

    cQry 		+= "    		                       LEFT JOIN SIGA.REGRASMAR AGRU ON AGRU.TABELA = 'AG'"
    cQry 		+= "    		                       AND AGRU.CHAVE = BM_XAGRP"
    cQry 		+= "    		                       AND AGRU.D_E_L_E_T_ = ' '"

   If cCalculo == "Simulacao"
cQry 		+= "    		WHERE "
Else
cQry 		+= "    		WHERE DA1_FILIAL = ' ' AND"
	cQry 		+= "    		    DA1.D_E_L_E_T_ = ' ' AND"
Endif

    cQry 		+= "    		 DA1_CODTAB = '"+cTabGer+"' "
    cQry 		+= "    		   AND SUBSTR(B1_COD, 1, 1) <> '2'"
      
    
	
	If cCalculo == "Simulacao"
cQry 		+= "                   and DA1_DTUMOV = '"+_cLastData+"'
	Else
cQry 		+= "                   and DA1.d_e_l_e_t_ = ' '    
	Endif

	cQry 		+= "  AND B1_GRUPO >= '"+cGrupoDe+"'
	cQry 		+= "  AND B1_GRUPO <= '"+cGrupoAte+"'
	cQry 		+= "  AND B1_COD >= '"+cProdDe+"'
	cQry 		+= "  AND B1_COD <= '"+cProdAte+"'
	cQry 		+= "  AND B1_XFORLIN = ' '"
	cQry 		+= "  AND B1_XCODBAS = ' '"

	if(cAgru <> "Relatorio Completo")
		cQry 		+= "  AND BM_XAGRP = '"+cAgru+"'
	endif

	cQry 		+= "  AND RMZA.DESCRI != 'TERCEIROS'"
	cQry 		+= "    		ORDER BY RMZA.ORDEM, BM_DESC"
	U_ORTQUERY(cQry, "OTR814")

    OTR814->(DbSort("AGRU_DESC+GRUPO"))

	OTR814->(dbgotop())

	oSectionAgru:Init()
	oSectionDetail:Init()

	While !("OTR814")->(EOF())

		oReport:IncMeter()

		If oReport:Cancel()
			Exit
		EndIf

        If OTR814->AGRU_DESC != cLastAgruDesc
            oSectionAgru:Cell("AGRU_DESC_CELL"):SetValue(OTR814->AGRU_DESC)
            oSectionAgru:PrintLine()
            cLastAgruDesc := OTR814->AGRU_DESC
        Endif

		oSectionDetail:Cell("BM_GRUPO" ):SetValue( OTR814->BM_GRUPO )
		oSectionDetail:Cell("B1_COD" ):SetValue( OTR814->B1_COD )
		oSectionDetail:Cell("MEDIDA" ):SetValue( Alltrim(STR(OTR814->B1_XLARG)) + "X" + Alltrim(Str(OTR814->B1_XCOMP)) + "/" + Alltrim(Str(OTR814->B1_XALT)) )
		oSectionDetail:Cell("A_VISTA" ):SetValue( OTR814->A_VISTA )
		oSectionDetail:Cell("A30_DD" ):SetValue( OTR814->A30_DD )
		oSectionDetail:Cell("A60_DD" ):SetValue( OTR814->A60_DD )
		oSectionDetail:Cell("A90_DD" ):SetValue( OTR814->A90_DD )
		oSectionDetail:Cell("B1_XESPACO" ):SetValue( OTR814->B1_XESPACO )
		oSectionDetail:PrintLine()

		OTR814->(dbskip())

	Enddo

	oSectionAgru:Finish()
	oSectionDetail:Finish()
	OTR814->(DbCloseArea())
	oReport:EndPage()

	RestArea(_aArea)

Return(.T.)
