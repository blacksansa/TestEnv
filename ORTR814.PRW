#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"
#INCLUDE "TBICONN.CH"

 
User Function ORTR814()
	Local aPergs      := {}
	Local aRet        := {}
	Private cTitulo   := "Geracao Marfil"
	Private cSemana   := ""
	Private cCongela  := ""
	Private cTipo     := ""
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

	aAdd( aPergs ,{1,"Semana         :" ,U_ORTP169A(),"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .T.   })
	aAdd( aPergs ,{2,"Segmento		 :" ,"Geral"	 ,{"Geral","Industrial","Comercial","Franquia",} , 80, .F.,.F.})
	aAdd( aPergs ,{2,"Tipo de Produto:" ,'SEMI-ACABADO'   ,{'ACABADO','SEMI-ACABADO','MATERIA-PRIMA'}      , 80, .F.,.F.})

	aAdd( aPergs ,{1,"Grupo de"         , cGrupoDe	, ""	  , ".T." , 'SBM', '.T.', 50,.F.})
	aAdd( aPergs ,{1,"Grupo Ate"        , cGrupoAte	, ""    , ".T."	, 'SBM', '.T.', 50,.T.})
	aAdd( aPergs ,{1,"Produto de"       , cProdDe	  , ""	  , ".T." , 'SB1', '.T.', 50,.F.})
	aAdd( aPergs ,{1,"Produto Ate"      , cProdAte	, ""    , ".T."	, 'SB1', '.T.', 50,.T.})

	aAdd( aPergs ,{2,"Visualizar     :" ,"Simulacao",{"Simulacao","Gerados"}                        , 80, .F.,.F.})
	aAdd( aPergs ,{2,"Exibe Variacao?:" ,"Sim"	    ,{"Sim","Nao",} , 80, .F.,.F.})
	aAdd( aPergs ,{2,"Fora de linha?:"  ,"Não"	    ,{"Sim","Nao",} , 80, .F.,.F.})
	aAdd( aPergs ,{1,"Tabela anterior:" ,U_ORTP169A(),"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .F.   })
	aAdd( aPergs ,{2,"Variação?:"  ,"Custo"	    ,{"Custo","Venda",} , 80, .F.,.F.})

	If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTR852" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
		Return
	EndIf 

	cSemana   := PadL( MV_PAR01, 3, "0" )
	cSegmen   := MV_PAR02
	cTipo     := MV_PAR03

	cGrupoDe  := MV_PAR04
	cGrupoAte := MV_PAR05
	cProdDe   := MV_PAR06
	cProdAte  := MV_PAR07

	cCalculo  := MV_PAR08
	cVaria    := MV_PAR09
	
	lForLin   := iif( MV_PAR10 == "Sim", .T., .F.)
	
	cTabAnt   := MV_PAR11
	cTpVaria  := MV_PAR12

	If cVaria == "Sim"
		lVaria := .T.
	Endif

	iF Empty(cTabAnt)
		If VAL(cSemana)-1 <= 0
			cTabAnt := '052'
		Else
			cTabAnt := STRZERO(VAL(cSemana)-1,3)
		Endif
	EndIf

	Processa( {|| Relatorio() }, "Aguarde...", "Gerando relatorio...",.F.)

Return

Static Function Relatorio()
	Local cQry    := ""
	Local cTabGer := cSemana
	Local aReport := {}
	Local aReport2 := {}
	Local nCtVetl := 1

	If cTipo == 'SEMI-ACABADO' .OR. cTipo == 'MATERIA-PRIMA' .OR. cTipo == 'SEMI-ACABADO e MATERIA-PRIMA'
		cTabGer := "Z"+substr(cSemana,02,02)
	Endif

	ProcRegua(0)

	cAlias := U_ORTQUERY("SELECT MAX(DA1_DTUMOV) as quando FROM SIGA.PREDA1030 WHERE DA1_CODTAB = '"+cTabGer+"'")
	_cLastData := (cAlias)->quando
	(cAlias)->(DBCLOSEAREA())

	If cCalculo == "Simulacao"
		cTitulo   := "Geracao Marfil ("+cSemana+") - Data do Calculo: " + dtoc(stod(_cLastData))
	Else
		cTitulo   := "Geracao Marfil ("+cSemana+") " + iif(lForLin, "FORA DE LINHA", "")
	Endif

	cQry += "SELECT *
	cQry += "          FROM (SELECT CASE
	cQry += "                         WHEN B1_TIPO = 'MP' OR
	cQry += "                              LENGTH(TRIM(LEADING 0 FROM B1_COD)) <= 5 THEN
	cQry += "                          '3-MATERIA-PRIMA'
	cQry += "                         WHEN B5_XSEMIAC = '1' OR (SELECT COUNT(*) AS REGISTROS
	cQry += "                                 FROM SIGA.SG1030 SG
	cQry += "                                WHERE SG.G1_COMP = B1_COD
	cQry += "                                  AND SG.D_E_L_E_T_ = ' '
	cQry += "                                  AND SG.G1_FILIAL = '02') > 0 OR (B1_TIPO IN ('MD', 'MB') AND B1_XMODELO = '999999' )THEN
	cQry += "                          '2-SEMI-ACABADO'
	cQry += "                         ELSE
	cQry += "                          '1-ACABADO'
	cQry += "                       END AS TIPO,
	cQry += "                       B1_XSEGMEN,
	cQry += "                       B1_GRUPO,
	cQry += "                       BM_DESC,
	cQry += "                       B1_TIPO,
	cQry += "                       B1_COD,
	cQry += "                       B1_DESC,
	cQry += "                       B1_XALT,
	cQry += "                       B1_XLARG,
	cQry += "                       B1_XCOMP,
	cQry += "                       B1_XQTDEMB,
	cQry += "                       BM_MARKUP AS MARKUP,
	cQry += "                       BM_XORDMIX,
	cQry += "                       RMZA.ORDEM AS ORDEM_LINHA,
	cQry += "                       RMZD.ORDEM AS ORDEM_MODELO,
	cQry += "                       AGRU.ORDEM AS ORDEM_AGRUPAMENTO,	
	cQry += "                       BM_XSUBGRU,
	cQry += "                       RMZA.DESCRI AS LINHA,
	cQry += "                       B1_XMODELO,
	cQry += "                       RMZD.DESCRI AS MODELO,
	cQry += "                       da1_codtab,
	cQry += "                       DA1_PRCVEN,
	cQry += "                       DA1_XCUSTO,
	cQry += "                       B1_XFORLIN, 
	cQry += "                       BM_XAGRP AS AGRUPAMENTO,	
	cQry += "                       AGRU.DESCRI AS AGRU_DESC
	cQry += "                  FROM SIGA.SB1030    B1,
	cQry += "                       SIGA.SBM200    SBM,
	cQry += "                       SIGA.SB5030    SB5,
	cQry += "                       SIGA.REGRASMAR RMZD,
	cQry += "                       SIGA.REGRASMAR RMZA,
	cQry += "                       SIGA.REGRASMAR AGRU,
	If cCalculo == "Simulacao"
		cQry += "                       SIGA.PREDA1030 DA1
	Else
		cQry += "                       SIGA.DA1030 DA1
	Endif
	cQry += "                 WHERE B1_FILIAL = '  '
	cQry += "                   AND B1.D_E_L_E_T_ = ' '
	cQry += "                   AND SB5.D_E_L_E_T_ (+)= ' '
	cQry += "                   AND B1_MSBLQL <> '1'
	cQry += "                   AND B5_FILIAL = '02'
	
	If lForLin

		cQry += "                   AND B1_XFORLIN <> ' ' 
	
	else
	
		cQry += "                   AND B1_XFORLIN = ' '
	
	ENDIF
	cQry += "                   AND B1_XCODBAS = ' '  
	cQry += "                   AND B5_COD (+)= B1_COD  
	cQry += "                   AND BM_GRUPO = B1_GRUPO
	cQry += "                   AND RMZD.D_E_L_E_T_ = ' '
	cQry += "                   AND RMZD.TABELA = 'ZD'
	cQry += "                   AND RMZD.CHAVE = B1_XMODELO
	cQry += "                   AND RMZA.D_E_L_E_T_ = ' '
	cQry += "                   AND RMZA.TABELA = 'ZA'
	cQry += "                   AND RMZA.CHAVE = BM_XSUBGRU
	cQry += "                   AND DA1_CODPRO = B1_COD
	cQry += "                   AND AGRU.D_E_L_E_T_ = ' '
	cQry += "                   AND AGRU.TABELA = 'AG'
	cQry += "                   AND AGRU.CHAVE = BM_XAGRP
	cQry += "                   AND DA1_XCUSTO > 0
	cQry += "                   and da1_codtab = '"+cTabGer+"'
	If cCalculo == "Simulacao"
		cQry += "                   and DA1_DTUMOV = '"+_cLastData+"'
	Else
		cQry += "                   and DA1.d_e_l_e_t_ = ' '
	
	Endif
	cQry += "                   AND EXISTS (SELECT 'X'
	cQry += "                          FROM SIGA.REGRASMAR RM
	cQry += "                         WHERE RM.TABELA = 'SBM'
	cQry += "                           AND RM.D_E_L_E_T_ = ' '
	cQry += "                           AND RM.CHAVE = B1_GRUPO
	cQry += "                           AND RM.MARFIL = 'S')
	
	cQry += " UNION
	cQry += "       SELECT '1-ACABADO' AS TIPO,
	cQry += "                      B1_XSEGMEN,
	cQry += "                      B1_GRUPO,
	cQry += "                      BM_DESC,
	cQry += "                      B1_TIPO,
	cQry += "                      B1_COD,
	cQry += "                      B1_DESC,
	cQry += "                      B1_XALT,
	cQry += "                      B1_XLARG,
	cQry += "                      B1_XCOMP,
	cQry += "                      B1_XQTDEMB,
	cQry += "                      BM_MARKUP AS MARKUP,
	cQry += "                      BM_XORDMIX,
	cQry += "                      RMZA.ORDEM AS ORDEM_LINHA,
	cQry += "                      RMZD.ORDEM AS ORDEM_MODELO,
	cQry += "                      AGRU.ORDEM AS ORDEM_AGRUPAMENTO,
	cQry += "                      BM_XSUBGRU,
	cQry += "                      RMZA.DESCRI AS LINHA,
	cQry += "                      B1_XMODELO,
	cQry += "                      RMZD.DESCRI AS MODELO,
	cQry += "                      '"+cTabGer+"' da1_codtab,
	cQry += "                      PRECO_VENDA DA1_PRCVEN,
	cQry += "                      CUSTO DA1_XCUSTO,
	cQry += "                      B1_XFORLIN,
	cQry += "                      BM_XAGRP AS AGRUPAMENTO,
	cQry += "                      AGRU.DESCRI AS AGRU_DESC
	cQry += "                 FROM SIGA.SB1030    B1,
	cQry += "                      SIGA.SBM200    SBM,
	cQry += "                      SIGA.SB5030    SB5,
	cQry += "                      SIGA.REGRASMAR RMZD,
	cQry += "                      SIGA.REGRASMAR RMZA,
	cQry += "                      SIGA.REGRASMAR AGRU,
	cQry += "                      SIGA.TERCEIROS_MARFIL
	cQry += "                WHERE B1_FILIAL = '  '
	cQry += "                  AND B1.D_E_L_E_T_ = ' '
	cQry += "                  AND SB5.D_E_L_E_T_(+) = ' '
	cQry += "                  AND B1_MSBLQL <> '1'
	cQry += "                  AND B5_FILIAL = '02'
	cQry += "                  AND B1_XFORLIN = ' '
	cQry += "                  AND B1_XCODBAS = ' '
	cQry += "                  AND PRODUTO = B1_COD
	cQry += "                  AND B5_COD(+) = B1_COD
	cQry += "                  AND BM_GRUPO = B1_GRUPO
	cQry += "                  AND RMZD.D_E_L_E_T_ = ' '
	cQry += "                  AND RMZD.TABELA = 'ZD'
	cQry += "                  AND RMZD.CHAVE = B1_XMODELO
	cQry += "                  AND RMZA.D_E_L_E_T_ = ' '
	cQry += "                  AND RMZA.TABELA = 'ZA'
	cQry += "                  AND RMZA.CHAVE = BM_XSUBGRU
	cQry += "                  AND AGRU.D_E_L_E_T_ = ' '
	cQry += "                  AND AGRU.TABELA = 'AG'
	cQry += "                  AND AGRU.CHAVE = BM_XAGRP
	cQry += "                  AND CUSTO > 0
	cQry += "                  AND EXISTS (SELECT 'X'
	cQry += "                         FROM SIGA.REGRASMAR RM
	cQry += "                        WHERE RM.TABELA = 'SBM'
	cQry += "                          AND RM.D_E_L_E_T_ = ' '
	cQry += "                          AND RM.CHAVE = B1_GRUPO
	cQry += "                          AND RM.MARFIL = 'S' ) )
	cQry += " WHERE 1=1
	If cTipo == 'ACABADO'
		cQry += "   AND (TIPO = '1-ACABADO' OR (B1_XMODELO = '000011' AND B1_TIPO <> 'PI' ))
	Endif
	If cTipo == 'SEMI-ACABADO'
		cQry += "   AND TIPO = '2-SEMI-ACABADO'
	Endif
	If cTipo == 'MATERIA-PRIMA'
		cQry += "   AND TIPO = '3-MATERIA-PRIMA'
	Endif
	If cTipo == 'SEMI-ACABADO e MATERIA-PRIMA'
		cQry += "   AND TIPO in ('3-MATERIA-PRIMA', '2-SEMI-ACABADO')
	Endif
	If cSegmen == "Industrial"
		cQry += "  AND B1_XSEGMEN IN ('1')
	Endif
	If cSegmen == "Comercial"
		cQry += "  AND B1_XSEGMEN IN ('2')
	Endif
	If cSegmen == "Franquia"
		cQry += "  AND B1_XSEGMEN IN ('3','4')
	Endif
	cQry += "  AND B1_GRUPO >= '"+cGrupoDe+"'
	cQry += "  AND B1_GRUPO <= '"+cGrupoAte+"'
	cQry += "  AND B1_COD >= '"+cProdDe+"'
	cQry += "  AND B1_COD <= '"+cProdAte+"'
	cQry += "         ORDER BY decode(ORDEM_AGRUPAMENTO, 0 , 1000, ORDEM_AGRUPAMENTO), ORDEM_LINHA,
	cQry += "                  AGRUPAMENTO, TIPO,
	cQry += "                  B1_GRUPO,
	cQry += "                  B1_XSEGMEN,
	cQry += "                  BM_XORDMIX,
	cQry += "                  ORDEM_MODELO,
	//cQry += "                  ORDEM_LINHA, 
	
	cQry += "                  B1_XALT,
	cQry += "                  B1_XLARG,
	cQry += "                  B1_COD

	U_ORTQUERY(cQry, "OTR814")

	cGrupo := ""
	cAgrupa:= ""
	cLinha := ""
	While OTR814->(!EOF())
		// TO-DO
		IncProc()

		If Padr(OTR814->AGRU_DESC,20) <> cAgrupa
			
			AADD(aReport,{  "AGRUPAMENTO:",;
				Alltrim(OTR814->AGRU_DESC),;
				'',;
				'',;
				'',;
				'',;
				'',;
				''})
		Endif		

		If Padr(OTR814->LINHA,20) <> cLinha
			
			AADD(aReport,{  "LINHA:",;
				Alltrim(OTR814->LINHA),;
				'',;
				'',;
				'',;
				'',;
				'',;
				''})
		Endif

		If Padr(OTR814->B1_GRUPO,10) <> cGrupo

			aSobMed := getSZV(cTabGer,cGrupo, IIF(cCalculo == "Simulacao",.T.,.F.))

			If len(aSobMed) > 0
				If aSobMed[2] > 0
					AADD(aReport,{  "SOB-MEDIDA",;
						'',;
						'',;
						Transform(aSobMed[2],"@E 99,999.99"),;
						Transform(aSobMed[1],"@E 99,999.99"),;
						'',;
						'' ,;
						''})
				Endif
			Endif

			AADD(aReport,{  "GRUPO:" + OTR814->B1_GRUPO,;
				Alltrim(OTR814->BM_DESC),;
				'',;
				'',;
				'',;
				'',;
				'',;
				''})
		Endif
		
		cAgrupa	 := Padr(OTR814->AGRU_DESC,20)
		cGrupo 	 := Padr(OTR814->B1_GRUPO,10)
		cDGrupo	 := Alltrim(OTR814->BM_DESC)
		cProduto := Padr(Alltrim(OTR814->B1_COD) + "-" + Alltrim(OTR814->B1_DESC),40)
		cMedida	 := Padr(Alltrim(STR(OTR814->B1_XALT)) + "/" + Alltrim(Str(OTR814->B1_XLARG)) + "/" + Alltrim(Str(OTR814->B1_XCOMP)),15)
		cMarcacao:= Transform(OTR814->MARKUP,"@E 9,999.99")
		cLinha 	 := Padr(Alltrim(OTR814->LINHA),20)
		cModelo	 := Padr(Alltrim(OTR814->MODELO),20)
		cPrcVen	 := Transform(OTR814->DA1_PRCVEN,"@E 99,999.99")
		cCusto	 := Transform(OTR814->DA1_XCUSTO,"@E 99,999.99")
		cVaria	 := space(08)
		cForlin  := DTOC(STOD(OTR814->B1_XFORLIN ) )

		If lVaria
			aRet	 := retDa1(cTabAnt,OTR814->B1_COD)
			If aRet[1] > 0

				If cTpVaria == 'Custo'

					cVaria	 := Padr(Transform(fDif(aRet[1],OTR814->DA1_XCUSTO),"@E 9999.99"),08)			
				Else

					cVaria	 := Padr(Transform(fDif(aRet[2],OTR814->DA1_PRCVEN),"@E 9999.99"),08)			

				EndIf
			Endif
		Endif			

		//OTR814->B1_TIPO
		//OTR814->B1_XQTDEMB
		//OTR814->BM_XSUBGRU
		//OTR814->B1_XMODELO
		//OTR814->DA1_CODTAB
		
		If lForLin 

			// ate 165 chars
			AADD(aReport,{  cProduto,;
				cMedida,;
				cMarcacao,;
				cPrcVen,;
				cCusto,;
				cVaria ,;
				cForlin, ;
				cLinha})

		else

			// ate 165 chars
			AADD(aReport,{  cProduto,;
				cMedida,;
				cMarcacao,;
				cPrcVen,;
				cCusto,;
				cVaria ,;
				"",;
				cLinha})
			
		EndIf

		OTR814->(dbSkip())
	EndDo
	If !empty(cGrupo )
		aSobMed := getSZV(cTabGer,cGrupo, IIF(cCalculo == "Simulacao",.T.,.F.))

		If len(aSobMed) > 0
			If aSobMed[2] > 0
				AADD(aReport,{  "SOB-MEDIDA",;
					'',;
					'',;
					Transform(aSobMed[2],"@E 99,999.99"),;
					Transform(aSobMed[1],"@E 99,999.99"),;
					'',;
					'',;
					'' })
			Endif
		Endif
	Endif

	If lForLin

		aCabRel := {"Produto", "Medida", "Marcacao", "Prc.Venda","Prc.Custo","Var.Cust%", "Dt.For.l"}
	
	else
	
		If cTpVaria == 'Custo'

			aCabRel := {"Produto", "Medida", "Marcacao", "Prc.Venda","Prc.Custo","Var.Custo.%"}
		Else

			aCabRel := {"Produto", "Medida", "Marcacao", "Prc.Venda","Prc.Custo","Var.Venda.%"}

		EndIf

		For nCtVetl := 1 to len(aReport)
			
			aadd(aReport2, { aReport[nCtVetl][1],aReport[nCtVetl][2],  aReport[nCtVetl][3], aReport[nCtVetl][4], aReport[nCtVetl][5], aReport[nCtVetl][6] , ' ', aReport[nCtVetl][8]})

		Next

		aReport := aReport2

	EndIf

	IF Len(aReport) > 0
		fImpMar("ORTR814", cTitulo, aCabRel , aReport, .T., .T.)		
	Else
		Alert("Não foram encontrados registros com os dados informados.Certifique-se de que a operacao de gerar tenha sido realizada.")
	Endif

Return

Static Function getSZV(cTab,cGrupo,lSimula)
	Local cQry    := ""
	Local _nCusto := 0
	Local _nVenda := 0
	Local cAlias  := ""
	Local _cLastData:= ""

	cAlias := U_ORTQUERY("SELECT MAX(ZV_DTUMOV) as quando FROM SIGA.PRESZV030 WHERE ZV_TABELA = '"+cTab+"'","R814ZVD")
	_cLastData := (cAlias)->quando
	(cAlias)->(DBCLOSEAREA())

	If !lSimula
		cQry := "SELECT ZV_VENDA, ZV_CUSTO FROM SIGA.SZV030 WHERE D_E_L_E_T_ = ' ' AND ZV_FILIAL = '"+xFilial("SZV")+"' AND ZV_TABELA = '"+cTab+"' AND ZV_GRUPO = '"+cGrupo+"'
	Else
		cQry := "SELECT ZV_VENDA, ZV_CUSTO FROM SIGA.PRESZV030 WHERE ZV_TABELA = '"+cTab+"' AND ZV_GRUPO = '"+cGrupo+"' AND ZV_DTUMOV = '"+_cLastData+"'
	Endif
	cAlias := U_ORTQUERY(cQry, "retszv")

	_nCusto := (cAlias)->ZV_CUSTO
	_nVenda := (cAlias)->ZV_VENDA

Return {_nCusto,_nVenda}

Static Function fDif(nVal1,nVal2)
Return 100-((nVal1/nVal2)*100)


Static Function retDa1(cTab,cProd)
	Local cQry    := ""
	Local _nCusto := 0
	Local _nVenda := 0
	Local cAlias  := ""

	cQry := "SELECT DA1_XCUSTO, DA1_PRCVEN FROM SIGA.DA1030 WHERE D_E_L_E_T_ = ' ' AND DA1_FILIAL = '"+xFilial("DA1")+"' AND DA1_CODTAB = '"+cTab+"' AND DA1_CODPRO = '"+cProd+"'
	cAlias := U_ORTQUERY(cQry, "retda1")

	_nCusto := (cAlias)->DA1_XCUSTO
	_nVenda := (cAlias)->DA1_PRCVEN

Return {_nCusto,_nVenda}


Static Function fImpMar(cProg, cCab, aHead, aItens, lBox, lRetr, aObj, lPdf, cCaminho, lCSV)
Private titulo   := cCab
Private nomeprog := cProg
Private _aHead	 := aHead
Private _aItens	 := aItens
Private lImpBox  := lBox   // indica se imprime os boxes ou nao
Private lRetrato := lRetr  // indica se imprime no formato retrato ou nao
// ===============================
Private oPrn,oFontM,oFontP
Private cHora 		:= Time()
Private lprimeira   := .T.
Private nPag	   	:= 0
Private cNomFil		:= ""
Private nEsp 		:= 50   // altura de cada linha
Private aBox1 		:= {}
Private aCab1 		:= {}
Private cLogo := "lgrl" + cEmpAnt + ".bmp"


Private nLin       	:= 3500
Private nHTam		:= 2380 // limite horizontal da pagina no modo paisagem
Private nLimite 	:= 3200 // limite onde irá ocorrer a quebra de pagina no modo paisagem
Private aObjt		:= {}
Private nPdf	    := 0

Default aObj		:= {}
Default lPdf		:= .F.
Default cCaminho    := ""
Default lCSV		:= .F.

aObjt := aObj

If lPdf
	nEsp 		:= 10
	nPdf	    := 2
Else
	nEsp 		:= 50
	nPdf	    := 0
EndIF

if !lRetrato
	nLin       	:= 3500
	If lPdf
		nHTam   	:= 825
	    nLimite 	:= 560  // limite onde irá ocorrer a quebra de pagina no modo paisagem		
	Else
		nHTam		:= 3384 // limite horizontal da pagina no modo paisagem
		nLimite 	:= 2200 // limite onde irá ocorrer a quebra de pagina no modo paisagem		
	EndIF


endif
//-

If !File(cLogo)
	cLogo := "lgrl" + cFilAnt + ".bmp"
EndIf

if len(_aHead) == 0 .or. len(_aItens) == 0 
	alert("Não a dados a serem impressos")
	return
endif

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilAnt)
cNomFil  := SM0->M0_FILIAL

// ===============================

If lPdf
	oFontM	:= TFont():New('Courier New',, 10,, .T.,,,,,.F.,.F.)
Else
	oFontM	:= TFont():New('Courier New',, 11,, .T.,,,,,.F.,.F.)
EndIF
	
oFontP	:= TFont():New('Courier New',, 10,, .T.,,,,,.F.,.F.)

If lPdf

	MAKEDIR(cCaminho)
	lPreview := .F.
	oPrn := FWMSPrinter():New(nomeprog,6,.F.,,.T.)
	oPrn:SetPortrait()
	oPrn:SetPaperSize(9)
	oPrn:SetMargin(30,60,30,60)
	oPrn:SetViewPDF(lPreview)
	oPrn:cPathPDF := cCaminho   //DIRETORIO PARA ENVIO DO PDF		
	GrR(oPrn,lpdf)
	oPrn:EndPage()
	oPrn:Print()

Else	                                             
	If lCSV //.and. U_ORTCHKPLAN("ORTR814",cEmpAnt) //Desativado em 02/07/2025 para teste
		Processa({||PrintCSV(aHead, aItens, cCaminho, cProg)},'Gerando arquivo CSV...')
	Else
		oPrn := TReport():New(nomeprog,Titulo,,{|oPrn|GrR(oPrn, lPdf)  },Titulo)
	
		oPrn:SetPortrait()
		if !lRetrato
			oPrn:SetLandscape()
		endif
		oPrn:SetEdit(.F.)         // Bloqueia personalizar
		oPrn:NoUserFilter()       // nao permite criar Filtro de usuario
		oPrn:DisableOrietation()  // não permite alterar a orientação da pagina
		oPrn:HideHeader()         // oculta o cabeçalho padrão
		oPrn:HideFooter()
		
		oPrn:PrintDialog()	
	EndIf
EndIf
IF lPdf .and. .F.
	//CRIA DIRETORIO CASO NAO EXISTA
	MAKEDIR(cCaminho)
	oPrn:nDevice := 6
	oPrn:cPathPDF := cCaminho   //DIRETORIO PARA ENVIO DO PDF		
	GrR(oPrn,lpdf)
	
	//Processa({|oPrn|GrR(oPrn)  },"Gerando PDF!","Processando...")	

EndIF
If !lCSV
	FreeObj(oPrn)
Endif
oPrn := Nil

Ms_Flush()

Return

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function GrR(oPrn,lpdf)

oPrn:SetPortrait()
if !lRetrato
	oPrn:SetLandscape()
endif

If !lpdf

	if oPrn:nDevice == 6
		
		oFontM	:= TFont():New('Courier new',, 10,, .T.,,,,,.F.,.F.)
		oFontP	:= TFont():New('Courier new',, 09,, .T.,,,,,.F.,.F.)
		oPrn:Init()
		oPrn:oprint:nMargLeft   := 40
		oPrn:oPrint:lPDFasPNG 	:= .T.
		oPrn:oPrint:nPageWidth 	:= 2380
		oPrn:nPageWidth 		:= 2380
		oPrn:oPrint:lServer 	:= .T.
		nHTam		:= 2380 // limite horizontal da pagina no modo paisagem
		if !lRetrato
			oPrn:oPrint:nPageWidth 	:= 3380
			oPrn:nPageWidth 		:= 3380
			nHTam		:= 3384 // limite horizontal da pagina no modo paisagem
		endif
	Endif
EndIF

FscFillBox(_aHead,_aItens)

RptStatus({|| GeraRel(oPrn,lpdf) },Titulo)

Return

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function GeraRel(oPrn,lpdf)
Local h
Local i
Local lLin := .F.


//U_ORTCHKPLAN("ORTR814",cEmpAnt,oPrn:nDevice) //Desativado em 02/07/2025 para teste

SetRegua(len(_aItens))
        
cLinPro := _aItens[1][8]

For i:=1 to len(_aItens)
	
	If nLin > nLimite // Salto de Página.
		nLin := fImpCab("1", oPrn,lpdf)
	Endif                                
	IF EMPTY(_aItens[i])
		nLin := 30000
		LOOP
	ENDIF     

	If  alltrim(_aItens[i][1])  == 'AGRUPAMENTO:'   

		aAgru := {}
		aAgru := _aItens[i]

		If alltrim(_aItens[i+1][1])  == 'LINHA:'  .AND. i > 10   

			Loop

		EndIf

	ElseIf alltrim(_aItens[i][1])  == 'LINHA:'    .AND. i > 10       
	    
		nLin := fImpCab("1", oPrn,lpdf)
	
		If lImpBox
			//FscPrintBox(aBox1,50)
			FscPrintBox(aBox1,nEsp)
		endif	

		for h:=1 to len(_aHead)
			if h == 1
				oPrn:Say ( nLin+IIf(lPdf,07,10), 10, aAgru[1] , oFontM)
			else
				oPrn:Say ( nLin+IIf(lPdf,07,10), aBox1[h-1]+IIf(lPdf,05,10), aAgru[h] , oFontM)
			endif
		next h

		nLin += nEsp
	
		If lImpBox
			//FscPrintBox(aBox1,50)
			FscPrintBox(aBox1,nEsp)
		endif	

		for h:=1 to len(_aHead)
			if h == 1
				oPrn:Say ( nLin+IIf(lPdf,07,10), 10, _aItens[i][1] , oFontM)
			else
				oPrn:Say ( nLin+IIf(lPdf,07,10), aBox1[h-1]+IIf(lPdf,05,10), _aItens[i][h] , oFontM)
			endif
		next h

		nLin += nEsp
		
		loop
	
	EndIf

	lLin := .T.
	
	IncRegua()

	If lImpBox
		//FscPrintBox(aBox1,50)
		FscPrintBox(aBox1,nEsp)
	endif	
	
	for h:=1 to len(_aHead)
		if h == 1
			oPrn:Say ( nLin+IIf(lPdf,07,10), 10, _aItens[i][1] , oFontM)
		else
			oPrn:Say ( nLin+IIf(lPdf,07,10), aBox1[h-1]+IIf(lPdf,05,10), _aItens[i][h] , oFontM)
		endif
	next h
	
/*	if lImpBox
		FscPrintBox(aBox1,50)
	endif*/
	
	nLin += nEsp
Next

MS_FLUSH()
Return


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-
Static Function fImpCab(cTp, oPrn,lpdf)
Local cb
nPag	+= 1

If nPag > 1
	oPrn:EndPage()
EndIf

oPrn:StartPage()

oPrn:SetPortrait()
if !lRetrato
	oPrn:SetLandscape()
endif
If lpdf
	nLin := 30
	oPrn:SetPaperSize(9)
Else
	nLin := 10
EndIF


//oPrn:Box ( [ nRow], [ nCol], [ nBottom], [ nRight] )
/*oPrn:Box( 10, 01, 155, nHTam )
oPrn:Box( 09, 00, 154, nHTam )*/

oPrn:Box( nLin, 01, nLin+nEsp*3+nPdf, nHTam)
//oPrn:Box( nLin-1, 00, nLin+nEsp*3-1, nHTam )

If lPdf
	nLin += nEsp
EndIF

// Lado Esquerdo
oPrn:Say ( nLin, 10, "Hora: " + cHora + " - (" + nomeprog + ")"     , oFontM)
oPrn:Say ( nLin+nEsp*2, 10, "Empresa: " + cEmpAnt + " / Filial: " + cNomFil, oFontM)

// Centro
oPrn:Say ( nLin+nEsp , 10, PADC(AllTrim(Upper(titulo)), 119 ), oFontM)

// Lado Direito
nTam := IIf(lPdf,05,20)*( Len("Emissão:" + Dtos(Date())) )+IIf(lPdf,10,40)
oPrn:Say ( nLin, nHTam-nTam, "Folha: " + AllTrim(Str(nPag)), oFontM)
oPrn:Say ( nLin+nEsp*2, nHTam-nTam, "Emissão:" + DtoC(Date()), oFontM)

If lPdf
	nLin += nEsp*2
Else
	nLin += nEsp*3
EndIF
//nLin	:= 170        

if len(aObjt) > 0                      
	oPrn:Box(nLin+nPdf,01,nLin+nEsp*len(aObjt)+nPdf,nHTam)	
	If lPdf
		nLin += nEsp
	EndIf
	For cb:=1 to len(aObjt)
		oPrn:Say(nLin,010,alltrim(aObjt[cb]),oFontM)
		nLin += nEsp 
	next cb 
ElseIf lPdf
	nLin += nEsp
endif

FscPrintCab(aCab1,aBox1,lpdf)

// ------------------
nLin += nEsp

Return(nLin)

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-|
// Função criada para retornar o posicionamento do box |
// de acordo com o tamanho da string enviada           |
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-|
Static Function FscRetTam(nLen, lDesconta)

Local nTam	  := 0
Local nMedida := 20 // para fontes 09

if oPrn:nDevice == 6
	nMedida := 19 // para fontes 09
endif

If nLen > 0
	nTam := 10+((nLen-1)*nMedida)+12
Else
	nTam := 00
EndIf

If lDesconta
	nTam -= 05 // 07
EndIf

Return nTam


//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-|
// Função criada para retornar um array com as posicoes|
// das colunas, para posicionar grid ou texto          |
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-|
Static Function FscRetBox(cMascara)
*---------------------------------*
local aBox 		:= {}
local aGrid		:= {}
local ncontar 	:= 0
local nvalor	:= 0
local za

aBox := Separa(cMascara, "|")

For za:=1 to len(aBox)
	ncontar += len(aBox[za])+1
	nvalor 	:= FscRetTam(ncontar, .t.)
	aadd(aGrid, nvalor)
	nvalor 	:= 0
Next ii

return aGrid


//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-|
// Função criada para imprimir o cabeçalho a partir de |
// um array com os nomes de cada coluna e outro com    |
// as posições geradas pela funcao FscRetBox           |
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-|
Static Function FscPrintCab(aCab,aBox,lpdf)
*------------------------------------*
local ii

oPrn:Line(nLin  , 00, nLin  , nHTam )
If !lpdf
	oPrn:Line(nLin+2, 00, nLin+2, nHTam )
	oPrn:Line(nLin+4, 00, nLin+4, nHTam )
EndIF

oPrn:Box( nLin, 0, nLin+65, aBox[len (aBox)] )

For ii := 1 to len (aBox)
	oPrn:Line(nLin, aBox[ii], nLin+65, aBox[ii] ) //
Next ii

nLin += 15

For ii := 1 to len (aCab)
	If ii == 1
		oPrn:Say ( nLin , 040,aCab[1], oFontM)
	Else
		oPrn:Say ( nLin , aBox[ii-1]+IIf(lPdf,05,10),aCab[ii], oFontM)
	EndIf
Next ii

nLin += nEsp

oPrn:Line(nLin  , 00, nLin  , nHTam )
If !lpdf
	oPrn:Line(nLin+2, 00, nLin+2, nHTam )
	oPrn:Line(nLin+4, 00, nLin+4, nHTam )
EndIF

Return

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-|
// Função criada para realizar a impressão das caixas  |
// de separação entre cada coluna/registro             |
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-|
*-------------------------------------*
Static Function FscPrintBox(aBox,nTam)
*-------------------------------------*

local ii
Default nTam := 50

If lImpBox
	oPrn:Box( nLin, 0, nLin+nTam, aBox[len (aBox)] )
	
	For ii := 1 to len (aBox)
		oPrn:Line(nLin, aBox[ii], nLin+nTam, aBox[ii] ) //
	Next ii
EndIf

Return

*---------------------------------------*
Static Function FscFillBox(aHead,aItens)
*---------------------------------------*
local cFinal := ""
local aColuna:= {}
local iy, ix

For ix:=1 to Len(aHead)
	aColuna := {}
	
	For iy:=1 to Len(aItens)
		if empty(aItens[iy])
			loop
		endif            
		aadd(aColuna, aItens[iy][ix])
	Next iy
	
	aSort(aColuna,,,{ |x,y| Len(x) > Len(y) })
	cFinal += Replicate("x", Len(aColuna[1]))
	
	If ix <> len(aHead)
		cFinal += "|"
	Endif
	
Next ix

aBox1 := FscRetBox(cFinal)
aCab1 := aHead

Return

//====================================
Static Function PrintCSV(aHead,aDados,cCaminho, cProg)
Local cNomeCSV	:= cProg + "_" + StrTran(DToS(Date()) + "_" + Time(), ":", "") + ".CSV"
Local cArquivo	:= cCaminho + cNomeCSV
Local cLinha	:= ""
Local i,z

FwMakeDir( cCaminho, .T. )

If File( cArquivo )
	FErase( cArquivo )
End If

cArqRef := MsFCreate( cArquivo )

ProcRegua(len(aDados))

// GRAVA CABECALHO
For i:=1 TO Len(aHead)
	cLinha += aHead[i]+";"
Next i

cLinha += CRLF
FWrite( cArqRef, cLinha )
cLinha := ""

// GRAVA DADOS
For i:=1 TO Len(aDados)
	
	IncProc()
	
	For z:=1 TO Len(aDados[i])             
		cLinha += Alltrim(aDados[i][z])+";"
	Next z
	
	cLinha += CRLF
	FWrite( cArqRef, cLinha )
	cLinha := ""
Next i

FClose( cArqRef )

Aviso( "Atenção", "Foi criado o arquivo abaixo." + CRLF + cArquivo, { "Ok" } )
ShellExecute("open", cNomeCSV, "", cCaminho, 1)

Return
