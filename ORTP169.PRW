#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"
#INCLUDE "TBICONN.CH"

User Function ORTP169(lSobMed)
	Local aPergs     := {}
	Local aRet       := {}
	Private cTitulo  := "Geracao Marfil"
	Private cSemana  := ""
	Private cCongela := ""
	Private cTipo    := ""
	Private cCalculo := ""
	//Private dCusto   := ddatabase
	Default lSobMed  := .F.

	If cEmpAnt <> "03"
		MsgBox("O Acesso a esta rotina é exclusivo da unidade 51", "Unidade Invalida", "INFO")
		Return
	Endif

	aAdd( aPergs ,{1,"Semana         :" ,U_ORTP169A(),"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .T.   })
	aAdd( aPergs ,{2,"Congela Precos :" ,"Nao"       ,{"Nao","Sim","Selecionados"}                   , 80, .F.,.F.})
	aAdd( aPergs ,{2,"Tipo de Produto:" ,'ACABADO'   ,{'ACABADO','SEMI-ACABADO e MATERIA-PRIMA'}      , 80, .F.,.F.})
	aAdd( aPergs ,{2,"Calculo        :" ,"Simulacao" ,{"Simulacao","Geracao"}                        , 80, .F.,.F.})
	aAdd( aPergs ,{2,"Permite redução?:" ,"Nao"       ,{"Nao","Sim"}                   , 80, .F.,.F.})

	//aAdd( aPergs ,{1,"Dta limite Custo:" ,dCusto	 ,"@d"		 ,'',,'.T.',80,.T.})

	If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTR762" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
		Return
	EndIf

	cSemana  := PadL( MV_PAR01, 3, "0" )
	cCongela := MV_PAR02
	cTipo    := MV_PAR03
	cCalculo := MV_PAR04
	cReducao := MV_PAR05
	//dCusto   := MV_PAR06

	If lSobMed
		Processa( {|| SobMedida() }, "Aguarde...", "Calculando valores para os Sob-Medida...",.F.)
	Else
		Processa( {|| u_fMarfil(,,cSemana) }, "Aguarde...", "Calculando valores para a marfil...",.F.)
	Endif

Return

//------------------------
User Function fMarfil(cProduto, cTp)
	Local cAlias  := GetNextAlias()
	Local cQry    := ""
	Local cTabRef := "Z"+substr(cSemana,02,02)
	Local cTabGer := ""
	Local cInsert := ""
	Local cItem   := ""
	Local _cProd  := ""
	Local _nCuba  := 0
	Local _nMark  := 0
	Local _nCusto := 0
	Local _nVenda := 0
	Local _cCount1:= ""
	Local _cCount2:= ""
	Local nCount  := 1
	Local lSemi   := .F.

	DEFAULT cProduto := ""
	DEFAULT cTp    := ""

	If cTp <> ""

		cTipo := cTp

	EndIf

	//==============================================
	// CONGELA PRECOS - COPIA A SEMANA ANTERIOR
	//==============================================
	If cCongela == "Sim"

		alert("Rever")
		If VAL(cSemana)-1 <= 0
			cTab := '053'
		Else
			cTab := STRZERO(VAL(cSemana)-1,3)
		Endif

		If cTipo == 'ACABADO'
			cTabGer := cSemana
			lSemi   := .F.
		Endif
		If cTipo == 'SEMI-ACABADO' .OR. cTipo == 'MATERIA-PRIMA' .OR. cTipo == 'SEMI-ACABADO e MATERIA-PRIMA'
			cTabGer := "Z"+substr(cSemana,02,02)
			lSemi   := .T.
		Endif

		If 'Z' $ cTabGer
			cTab := 'Z'+substr(cSemana,02,02)
		Endif

		cAlias := U_ORTQUERY("SELECT MAX(DA1_DTUMOV) as quando FROM SIGA.PREDA1030 WHERE DA1_CODTAB = '"+cTab+"'")
		_cLastData := (cAlias)->quando
		(cAlias)->(DBCLOSEAREA())

		// BLOCO PRINCIPAL
		BEGIN TRANSACTION

			// Se simulacao deleto a tabela temporaria
			If cCalculo == "Simulacao"
				//IF TcSqlExec("DELETE FROM SIGA.PREDA1030 WHERE DA1_CODTAB = '"+cTabGer+"' AND DA1_DTUMOV = '"+DTOS(DDATABASE)+"' ") <> 0
				IF TcSqlExec("DELETE FROM SIGA.PREDA1030 WHERE DA1_CODTAB = '"+cTabGer+"'  ") <> 0
					alert("Erro ao limpar a tabela temporaria.")
				Endif
			Else

				IF TcSqlExec("DELETE FROM SIGA.PREDA1030 WHERE DA1_CODTAB = '"+cTabGer+"'  ") <> 0
					alert("Erro ao limpar a tabela temporaria.")
				Else

					//u_ORTP169T( .T. )

					dbselectarea("DA1")
					dbOrderNickName("CDA14")
					dbseek(xFilial("DA1")+cTabGer)
					While !EOF() .And. DA1_FILIAL+DA1_CODTAB == xFilial("DA1")+cTabGer
						dbSelectArea("DA1")
						RecLock("DA1",.F.)
						Delete
						msUnLock()
						dbSkip()
						Loop
					EndDo
				Endif
			Endif

			If cCalculo == "Simulacao"
				cInsert := "INSERT INTO SIGA.PREDA1030 (DA1_CODTAB, DA1_ITEM, DA1_CODPRO, DA1_PRCVEN, DA1_XCUSTO, DA1_DTUMOV, DA1_HRUMOV) SELECT '"+cTabGer+"' AS DA1_CODTAB, DA1_ITEM, DA1_CODPRO, DA1_PRCVEN, DA1_XCUSTO, '"+dtos(dDatabase)+"' AS DA1_DTUMOV, '"+time()+"' AS DA1_HRUMOV FROM SIGA.PREDA1030 WHERE DA1_CODTAB = '"+cTab+"' AND DA1_DTUMOV = '"+_cLastData+"'
				If TcSqlExec(cInsert) <> 0
					alert("Erro ao inserir registro temporario." + TCSQLError() )
				Endif
			Else
				cInsert := "INSERT INTO SIGA.PREDA1030 (DA1_CODTAB, DA1_ITEM, DA1_CODPRO, DA1_PRCVEN, DA1_XCUSTO, DA1_DTUMOV, DA1_HRUMOV) SELECT '"+cTabGer+"' AS DA1_CODTAB, DA1_ITEM, DA1_CODPRO, DA1_PRCVEN, DA1_XCUSTO, '"+dtos(dDatabase)+"' AS DA1_DTUMOV, '"+time()+"' AS DA1_HRUMOV FROM SIGA.PREDA1030 WHERE DA1_CODTAB = '"+cTab+"' AND DA1_DTUMOV = '"+_cLastData+"'
				If TcSqlExec(cInsert) <> 0
					alert("Erro ao inserir registro temporario." + TCSQLError() )
				Else

					cQry := "SELECT * FROM SIGA.PREDA1030  WHERE DA1_CODTAB = '"+cTabGer+"' AND DA1_DTUMOV = '"+dtos(dDatabase)+"'
					cAlias := U_ORTQUERY(cQry,cAlias)
					Do While  !(cAlias)->(EOF())

						reclock("DA1",.T.)
						DA1->DA1_ITEM  := (cAlias)->DA1_ITEM
						DA1->DA1_FILIAL:= xFilial("DA1")
						DA1->DA1_CODTAB:= (cAlias)->DA1_CODTAB
						DA1->DA1_CODPRO:= (cAlias)->DA1_CODPRO
						DA1->DA1_ATIVO := "1"
						DA1->DA1_TPOPER:= "4"
						DA1->DA1_QTDLOT:= 999999.99
						DA1->DA1_INDLOT:= "000000000999999.99"
						DA1->DA1_MOEDA := 1
						DA1->DA1_XCUSTO:= (cAlias)->DA1_XCUSTO
						DA1->DA1_PRCVEN:= (cAlias)->DA1_PRCVEN
						DA1->DA1_PERDES:= 0
						DA1->DA1_DTUMOV:= ddatabase
						DA1->DA1_HRUMOV:= time()
						msunlock()

						(cAlias)->(dbskip())
					EndDo
					(cAlias)->(DBCLOSEAREA())

				Endif

			Endif

		END TRANSACTION

		//==============================================
		// CALCULA OS PRECOS
		//==============================================
	ElseIf cCalculo == "Simulacao"

		//debug
		//
		//cProduto = '0000061214     '
		_cCount1 := " select count(*) as registros from ("
		_cCount2 := " )"

		cQry := "SELECT *
		cQry += "  FROM (SELECT CASE
		cQry += "                 WHEN B1_TIPO = 'MP' OR
		cQry += "                      LENGTH(TRIM(LEADING 0 FROM B1_COD)) <= 5 THEN
		cQry += "                  'MATERIA-PRIMA'
		cQry += "                         WHEN B5_XSEMIAC = '1' OR (SELECT COUNT(*) AS REGISTROS
		cQry += "                                 FROM SIGA.SG1030 SG
		cQry += "                                WHERE SG.G1_COMP = B1_COD
		cQry += "                                  AND SG.D_E_L_E_T_ = ' '
		cQry += "                                  AND SG.G1_FILIAL = '02') > 0 OR (B1_TIPO IN ('MD', 'MB') AND B1_XMODELO = '999999' ) THEN
		cQry += "                  'SEMI-ACABADO'
		cQry += "                 ELSE
		cQry += "                  'ACABADO'
		cQry += "               END AS TIPO,
		cQry += "               B1_XSEGMEN,
		cQry += "               B1_GRUPO,
		cQry += "               B1_TIPO,
		cQry += "               B1_COD,
		cQry += "               B1_DESC,
		cQry += "               B1_XALT,
		cQry += "               B1_XLARG,
		cQry += "               B1_XCOMP,
		cQry += "               B1_XQTDEMB,
		cQry += "               BM_MARKUP AS MARKUP, " //RMBM.PERCENTUAL
		cQry += "               BM_XCONGP    AS CONGELA,
		cQry += "               BM_XORDMIX,
		cQry += "               NVL( RMZA.ORDEM, 0 ) AS ORDEM_LINHA,
		cQry += "               RMZD.ORDEM AS ORDEM_MODELO,
		cQry += "               BM_XSUBGRU,
		cQry += "               NVL(RMZA.DESCRI, 0) AS LINHA,
		cQry += "               B1_XMODELO,
		cQry += "               RMZD.DESCRI AS MODELO
		cQry += "          FROM SIGA.SB1030    B1,
		cQry += "               SIGA.SBM200    SBM,
		cQry += "               SIGA.SB5030    SB5,
		cQry += "               SIGA.REGRASMAR RMZD,
		cQry += "               SIGA.REGRASMAR RMZA
		cQry += "         WHERE B1_FILIAL = '  '
		cQry += "           AND B1.D_E_L_E_T_ = ' '
		cQry += "           AND SB5.D_E_L_E_T_ (+) = ' '
		cQry += "           AND B5_FILIAL (+) = '02'
		cQry += "           AND B1_MSBLQL <> '1'
		cQry += "           AND B5_COD (+) = B1_COD
		cQry += "           AND (B1_XFORLIN = ' ' OR  B1_XFORLIN >= TO_CHAR(ADD_MONTHS(SYSDATE, -12),'YYYYMMDD') )
		cQry += "           AND B1_XCODBAS = ' '
		cQry += "           AND BM_GRUPO = B1_GRUPO
		cQry += "           AND SBM.D_E_L_E_T_ = ' '
		cQry += "           AND BM_FILIAL = '  '
		cQry += "           AND RMZD.D_E_L_E_T_ = ' '
		cQry += "           AND RMZD.TABELA = 'ZD'
		cQry += "           AND RMZD.CHAVE = B1_XMODELO
		cQry += "           AND RMZA.D_E_L_E_T_ (+)= ' '
		cQry += "           AND RMZA.TABELA (+)= 'ZA'
		cQry += "           AND RMZA.CHAVE (+)= BM_XSUBGRU

		If cProduto <> ''

			If cTp == 'A'
				// DEBUG
				cQry += "           AND B1_COD = '"+cProduto+"'
				//
			else

				cQry += "           AND B1_COD in '"+cProduto+"'

			EndIf
		EndIf

		cQry += "           AND EXISTS (SELECT 'X'
		cQry += "                  FROM SIGA.REGRASMAR RM
		cQry += "                 WHERE RM.TABELA = 'SBM'
		cQry += "                   AND RM.D_E_L_E_T_ = ' '
		cQry += "                   AND RM.CHAVE = B1_GRUPO
		cQry += "                   AND RM.MARFIL = 'S'))
		cQry += " WHERE 1=1

		If cTipo == 'ACABADO'
			cQry += "   AND TIPO = 'ACABADO' OR B1_XMODELO = '000011'
		Endif
		If cTipo == 'SEMI-ACABADO'
			cQry += "   AND TIPO = 'SEMI-ACABADO'
		Endif
		If cTipo == 'MATERIA-PRIMA'
			cQry += "   AND TIPO = 'MATERIA-PRIMA'
		Endif
		If cTipo == 'SEMI-ACABADO e MATERIA-PRIMA'
			cQry += "   AND TIPO in ('MATERIA-PRIMA', 'SEMI-ACABADO')
		Endif

		cQry += " ORDER BY TIPO,
		cQry += "          B1_XSEGMEN,
		cQry += "          BM_XORDMIX,
		cQry += "          ORDEM_MODELO,
		cQry += "          ORDEM_LINHA,
		cQry += "          B1_GRUPO,
		cQry += "          B1_XLARG,
		cQry += "          B1_COD

		// Contagem de registros para a barra de progresso
		cAlias := U_ORTQUERY(_cCount1+cQry+_cCount2,cAlias)
		ProcRegua((cAlias)->registros)
		(cAlias)->(DBCLOSEAREA())

		// Executa a query principal
		cAlias := U_ORTQUERY(cQry,cAlias)

		// definir o codigo da tabela a ser salvo, semi-acabados e materias primas ficam na serie Z da da1
		If cTipo == 'ACABADO'
			cTabGer := cSemana
			lSemi   := .F.
		Endif
		If cTipo == 'SEMI-ACABADO' .OR. cTipo == 'MATERIA-PRIMA' .OR. cTipo == 'SEMI-ACABADO e MATERIA-PRIMA'
			cTabGer := "Z"+substr(cSemana,02,02)
			lSemi   := .T.
		Endif

		// SEMANA ANTERIOR PARA OS CONGELADOS
		If VAL(substr(cSemana,02,02))-1 <= 0
			cTab := '052'
		Else
			cTab := STRZERO(VAL(substr(cSemana,02,02))-1,3)
		Endif

		If 'Z' $ cTabGer
			cTab := 'Z'+substr(cSemana,02,02)
		Endif

		// BLOCO PRINCIPAL
		BEGIN TRANSACTION

			If cProduto == ''
				// Se simulacao deleto a tabela temporaria
				IF TcSqlExec("DELETE FROM SIGA.PREDA1030 WHERE DA1_CODTAB = '"+cTabGer+"'  ") <> 0
					alert("Erro ao limpar a tabela temporaria.")
				Endif

			else // individual

				aVetor := {cProduto}

				//STRBREAK(cProduto, ";", @aVetor)

				For nCount := 1 to len(aVetor)

					IF TcSqlExec("DELETE FROM SIGA.PREDA1030 WHERE DA1_CODTAB = '"+cTabGer+"' AND DA1_CODPRO = '"+ aVetor[nCount] +"' ") <> 0
						alert("Erro ao limpar a tabela temporaria.")
					Endif

				Next

			ENDIF
			// Sequencia dos itens
			cItem 	:= "0000"
			cItemDA1:= "0000"

			ntmp := 0
			Do While  !(cAlias)->(EOF())
			/*
			ntmp++
			If ntmp > 100
				exit
			EndIf
			*/
				IncProc()

				cItem   := soma1(cItem)
				_cProd  := (cAlias)->B1_COD
				_nCuba  := (cAlias)->B1_XALT*(cAlias)->B1_XLARG*(cAlias)->B1_XCOMP
				_nMark  := (cAlias)->MARKUP

				IF _nMark == 0
					_nMark := 1
				Endif

				_nCusto  := U_ORTP169C(_cProd, cTabRef, lSemi, .F., 0, cCalculo)
				_nVenda  := 0

				//mbcFab
				If (cAlias)->BM_XSUBGRU $ ("10006L|10001L|10003L|10004L") // ARTE|OURO|MASTER|FASHION
					lGrpExc := .T.
					buscMark := U_BuscaRegra(_cProd,(cAlias)->BM_XSUBGRU) // Ressarcimento, Marcação, Guelta (Retorna a Marcação somente!)
					If buscMark <> 0 .And. buscMark <> NIL
						_nMark := buscMark
					EndIf
				Endif

				If cTipo == 'ACABADO'
					_nVenda  := _nCusto*_nMark
					//_nVenda  := Round(_nCusto+_nVenda,2)
					_nVenda  := Round(_nVenda,2)
				Else
					If _nCusto == 0
						_nCusto:= ExistZZM(_cProd, "0"+substr(cTabRef,02,02))
					Endif
				Endif

				If cReducao == "Nao"
					// PEGO O PRECO DA ULTIMA TABELA
					/*
					aPrc := retDa1(cTab,_cProd)
					If _nCusto < aPrc[1]
						_nCusto := aPrc[1]
						_nVenda := aPrc[2]
					Endif
					*/
				Endif
				//==============================================
				// SE CONGELA PRECOS DE SELECIONADOS APENAS
				//==============================================
				If cCongela == "Selecionados"
					// VERIFICA SE O PRODUTO ESTA NA LISTA DOS CONGELADOS
					If (cAlias)->CONGELA == "S"

						// PEGO O PRECO DA ULTIMA TABELA
						aPrc := retDa1(cTab,_cProd)
						_nCusto := aPrc[1]
						_nVenda := aPrc[2]

					Endif
				Endif

				If _nCusto > 0

					cInsert := "INSERT INTO SIGA.PREDA1030 (DA1_CODTAB, DA1_ITEM, DA1_CODPRO, DA1_PRCVEN, DA1_XCUSTO, DA1_DTUMOV, DA1_HRUMOV) VALUES ('"+cTabGer+"','"+cItem+"','"+_cProd+"', "+Alltrim(Str(_nVenda))+", "+Alltrim(Str(_nCusto))+", '"+dtos(dDatabase)+"', '"+time()+"')"
					If TcSqlExec(cInsert) <> 0
						alert("Erro ao inserir registro temporario." + TCSQLError() )
					Endif

				Endif

				(cAlias)->(dbskip())
			EndDo

			(cAlias)->(DBCLOSEAREA())

			// inclui produtos de terceiros

			If cTipo == 'ACABADO'

				cQuery := "SELECT PRODUTO ,      "
				cQuery += "       PRECO_VENDA ,     "
				cQuery += "       CUSTO  , "	  "
				cQuery += "       DATA_INC  , R_E_C_N_O_ RECMAR "
				cQuery += "  FROM SIGA.TERCEIROS_MARFIL   "
				cQuery += " WHERE D_E_L_E_T_ = ' ' "
				cQuery += " ORDER BY 1, 2     "

				cAlias := U_ORTQUERY(cQuery, "A768")

				Do While  (cAlias)->(!EOF())


					cItem := soma1(cItem)

					cInsert := "INSERT INTO SIGA.PREDA1030 (DA1_CODTAB, DA1_ITEM, DA1_CODPRO, DA1_PRCVEN, DA1_XCUSTO, DA1_DTUMOV, DA1_HRUMOV) VALUES ('"+cTabGer+"','"+cItem+"','"+(cAlias)->PRODUTO+"', "+Alltrim(Str((cAlias)->PRECO_VENDA))+", "+Alltrim(Str((cAlias)->CUSTO))+", '"+dtos(dDatabase)+"', '"+time()+"')"
					If TcSqlExec(cInsert) <> 0
						alert("Erro ao inserir registro temporario." + TCSQLError() )
					Endif

					(cAlias)->(dbskip())
				EndDo

				(cAlias)->(DBCLOSEAREA())

			EndIf

		END TRANSACTION

	ElseIf cCalculo <> "Simulacao"
		UPDATEDA1(cSemana) //cTabGer := cSemana | Não esta puxando semana correta | 028 semana atual
	Endif

	msgInfo("Processo finalizado!","Sucesso")

Return

//------------------------
Static Function SobMedida()
	Local cQry   := ""
	Local cAlias := ""

	/*
	cálculo sob-medida versao simplificada 

	volume =  comprimento X largura x altura
	---------------
	VALOR DE CUSTO
	vl.custo =   ( vl.custo acabado /  volume do acabado ) * 1,15
	arredondar para cima
	-------------------------
	VALOR DE VENDA
	vl.venda =    vl.custo  * marcação do acabado
	arredondar para cima
	*/

	If cCongela == "Sim"
		If VAL(cSemana)-1 <= 0
			cTab := '052'
		Else
			cTab := STRZERO(VAL(cSemana)-1,3)
		Endif

		cAlias := U_ORTQUERY("SELECT MAX(ZV_DTUMOV) as quando FROM SIGA.PRESZV030 WHERE ZV_TABELA = '"+cTab+"'")
		_cLastData := (cAlias)->quando
		(cAlias)->(DBCLOSEAREA())

		// Se simulacao deleto a tabela temporaria
		If cCalculo == "Simulacao"
			IF TcSqlExec("DELETE FROM SIGA.PRESZV030 WHERE ZV_TABELA = '"+cSemana+"' AND ZV_DTUMOV = '"+DTOS(DDATABASE)+"' ") <> 0
				alert("Erro ao limpar a tabela temporaria.")
			Endif
		Else
			IF TcSqlExec("DELETE FROM SIGA.PRESZV030 WHERE ZV_TABELA = '"+cSemana+"' AND ZV_DTUMOV = '"+DTOS(DDATABASE)+"' ") <> 0
				alert("Erro ao limpar a tabela temporaria.")
			Else
				dbselectarea("SZV")
				dbOrderNickName("CSZV1")
				dbseek(xFilial("SZV")+cSemana)
				While !EOF() .And. ZV_FILIAL+ZV_TABELA == xFilial("SZV")+cSemana
					dbSelectArea("SZV")
					RecLock("SZV",.F.)
					Delete
					msUnLock()
					dbSkip()
					Loop
				EndDo
			Endif
		Endif

		If cCalculo == "Simulacao"
			cInsert := "INSERT INTO SIGA.PRESZV030 (ZV_TABELA, ZV_GRUPO, ZV_VENDA, ZV_CUSTO, ZV_VENAME, ZV_DTUMOV, ZV_HRUMOV) SELECT '"+cSemana+"' AS ZV_TABELA, ZV_GRUPO, ZV_VENDA, ZV_CUSTO, ZV_VENAME, '"+dtos(dDatabase)+"' AS ZV_DTUMOV, '"+time()+"' AS ZV_HRUMOV FROM SIGA.PRESZV030 WHERE ZV_TABELA = '"+cTab+"' AND ZV_DTUMOV = '"+_cLastData+"'
			If TcSqlExec(cInsert) <> 0
				alert("Erro ao inserir registro temporario." + TCSQLError() )
			Endif
		Else
			cInsert := "INSERT INTO SIGA.PRESZV030 (ZV_TABELA, ZV_GRUPO, ZV_VENDA, ZV_CUSTO, ZV_VENAME, ZV_DTUMOV, ZV_HRUMOV) SELECT '"+cSemana+"' AS ZV_TABELA, ZV_GRUPO, ZV_VENDA, ZV_CUSTO, ZV_VENAME, '"+dtos(dDatabase)+"' AS ZV_DTUMOV, '"+time()+"' AS ZV_HRUMOV  FROM SIGA.PRESZV030 WHERE ZV_TABELA = '"+cTab+"' AND ZV_DTUMOV = '"+_cLastData+"'
			If TcSqlExec(cInsert) <> 0
				alert("Erro ao inserir registro temporario." + TCSQLError() )
			Else

				cQry := "SELECT * FROM SIGA.PRESZV030  WHERE ZV_TABELA = '"+cSemana+"' AND ZV_DTUMOV = '"+dtos(dDatabase)+"'
				cAlias := U_ORTQUERY(cQry,cAlias)
				Do While  !(cAlias)->(EOF())

					RecLock("SZV",.T.)
					SZV->ZV_FILIAL	:= xFilial("SZV")
					SZV->ZV_GRUPO	:= (cAlias)->ZV_GRUPO
					SZV->ZV_TABELA	:= (cAlias)->ZV_TABELA
					SZV->ZV_CUSTO	:= (cAlias)->ZV_CUSTO
					SZV->ZV_VENDA	:= (cAlias)->ZV_VENDA
					SZV->ZV_VENAME	:= (cAlias)->ZV_VENAME
					MsUnLock()

					(cAlias)->(dbskip())
				EndDo
				(cAlias)->(DBCLOSEAREA())

			Endif

		Endif

	ELSE

		cQry := " SELECT DISTINCT CHAVE, CONGELA FROM SIGA.REGRASMAR WHERE TABELA = 'SBM' AND SOBMED = 'S' AND D_E_L_E_T_ = ' ' "
		cAlias := U_ORTQUERY(cQry)

		// BLOCO PRINCIPAL
		BEGIN TRANSACTION

			// Se simulacao deleto a tabela temporaria
			If cCalculo == "Simulacao"
				IF TcSqlExec("DELETE FROM SIGA.PRESZV030 WHERE ZV_TABELA = '"+cSemana+"' AND ZV_DTUMOV = '"+DTOS(DDATABASE)+"' ") <> 0
					alert("Erro ao limpar a tabela temporaria.")
				Endif
			Else
				IF TcSqlExec("DELETE FROM SIGA.PRESZV030 WHERE ZV_TABELA = '"+cSemana+"' AND ZV_DTUMOV = '"+DTOS(DDATABASE)+"' ") <> 0
					alert("Erro ao limpar a tabela temporaria.")
				Else
					dbselectarea("SZV")
					dbOrderNickName("CSZV1")
					dbseek(xFilial("SZV")+cSemana)
					While !EOF() .And. ZV_FILIAL+ZV_TABELA == xFilial("SZV")+cSemana
						dbSelectArea("SZV")
						RecLock("SZV",.F.)
						Delete
						msUnLock()
						dbSkip()
						Loop
					EndDo
				Endif
			Endif

			Do While  !(cAlias)->(EOF())

				_cGrupo    := (cAlias)->CHAVE

				cQry := "	SELECT *
				cQry += "  FROM (SELECT B1_GRUPO,
				cQry += "               B1_COD,
				cQry += "               B1_DESC,
				cQry += "               B1_XMED,
				cQry += "               B1_XLARG * B1_XALT * B1_XCOMP AS VOLUME,
				cQry += "               DA1_XCUSTO,
				cQry += "               ROUND((DA1_XCUSTO / (B1_XLARG * B1_XALT * B1_XCOMP)) * 1.15) AS CUSTO_M3,
				cQry += "               ceil(((DA1_XCUSTO / (B1_XLARG * B1_XALT * B1_XCOMP)) * 1.15)*PERCENTUAL) AS VENDA_M3,
				cQry += "               ROWNUM AS LINHA
				cQry += "          FROM SIGA.SB1030 SB1, SIGA.DA1030 DA1, SIGA.REGRASMAR
				cQry += "         WHERE SB1.D_E_L_E_T_ = ' '
				cQry += "           AND B1_FILIAL = '  '
				//cQry += "           AND B1_TIPO   = 'PA'
				cQry += "           AND B1_GRUPO <> ' '
				cQry += "           AND B1_XFORLIN = ' '
				cQry += "           AND B1_XCODBAS = ' '
				cQry += "           AND DA1.D_E_L_E_T_  = ' '
				cQry += "           AND DA1_FILIAL 	    = '  '
				cQry += "           AND DA1_CODPRO      = B1_COD
				cQry += "           AND DA1.DA1_CODTAB	= '"+cSemana+"'
				cQry += "           AND B1_GRUPO 		= '"+_cGrupo+"'
				cQry += "           AND DA1_XCUSTO > 0
				cQry += "           AND B1_XLARG * B1_XALT * B1_XCOMP > 0
				cQry += "           AND TABELA = 'SBM'
				cQry += "           AND SOBMED = 'S'
				cQry += "           AND CHAVE = B1_GRUPO
				cQry += "         ORDER BY B1_GRUPO, 5)
				cQry += " WHERE LINHA = 1

				cAlias2 := U_ORTQUERY(cQry, "ORTP169M")
				_nCusto := (cAlias2)->CUSTO_M3
				_nVenda := (cAlias2)->VENDA_M3

				If cCongela == "Selecionados"
					// VERIFICA SE O PRODUTO ESTA NA LISTA DOS CONGELADOS
					If (cAlias)->CONGELA == "S"
						// PEGO O PRECO DA ULTIMA TABELA
						aPrc := retSZV(cTab,cGrupo)
						_nCusto := aPrc[1]
						_nVenda := aPrc[2]
					Endif
				Endif

				If _nCusto > 0

					If cCalculo == "Simulacao"
						cInsert := "INSERT INTO SIGA.PRESZV030 (ZV_TABELA, ZV_GRUPO, ZV_VENDA, ZV_CUSTO, ZV_VENAME, ZV_DTUMOV, ZV_HRUMOV) VALUES ('"+cSemana+"','"+_cGrupo+"', "+Alltrim(Str(_nVenda))+","+Alltrim(Str(_nCusto))+","+Alltrim(Str(_nVenda))+",'"+dtos(dDatabase)+"', '"+time()+"')
						If TcSqlExec(cInsert) <> 0
							alert("Erro ao inserir registro temporario." + TCSQLError() )
						Endif
					Else
						cInsert := "INSERT INTO SIGA.PRESZV030 (ZV_TABELA, ZV_GRUPO, ZV_VENDA, ZV_CUSTO, ZV_VENAME, ZV_DTUMOV, ZV_HRUMOV) VALUES ('"+cSemana+"','"+_cGrupo+"', "+Alltrim(Str(_nVenda))+","+Alltrim(Str(_nCusto))+","+Alltrim(Str(_nVenda))+",'"+dtos(dDatabase)+"', '"+time()+"')
						If TcSqlExec(cInsert) <> 0
							alert("Erro ao inserir registro temporario." + TCSQLError() )
						Else
							RecLock("SZV",.T.)
							SZV->ZV_FILIAL	:= xFilial("SZV")
							SZV->ZV_GRUPO	:= _cGrupo
							SZV->ZV_TABELA	:= cSemana
							SZV->ZV_CUSTO	:= _nCusto
							SZV->ZV_VENDA	:= _nVenda
							SZV->ZV_VENAME	:= _nVenda
							MsUnLock()
						Endif

					Endif

				Endif

				(cAlias)->(dbskip())
			EndDo

			(cAlias)->(DBCLOSEAREA())

		END TRANSACTION
	Endif

	msgInfo("Processo finalizado!","Sucesso")

Return

// ==========================================================================
// Esta funcao recebe um codigo de produto e faz o calculo baseado nas regras
// definidas e comentadas no fonte
// cProd   - Codigo do produto a ser calculado o custo
// cTabRef - codigo da tabela de referencia para comparacao
// lComp   - Indica se o produto esta dentro de uma composicao ou nao
// lReport - Gera um TXT com o detalhamento da composicao
// ==========================================================================
User Function ORTP169C(cProd, cTabRef, lComp, lReport, nRecursivo, cCalculo)
	Local cQry       := ""
	Local cAlias     := "OTP169C" //GetNextAlias()
	Local nQuebra    := 1.05
	Local _nCUSTOFIN := 0
	Local aDados     := {}
	Local _cCodigo   := ""
	Local _cCodCom   := ""
	Local _cDescri   := ""
	Local _cDecomp   := ""
	Local _nQuanti   := 0
	Local _dDtCust   := dDataBase
	Local _nImpost   := 0
	Local _nCusto    := 0
	Local _nCusMar   := 0
	Local _cMatriz   := ""
	Local _nCalcNovo := 0
	Local _nCalcAnti := 0
	Local _nRet      := 0
	Local _cModelo   := ""
	Default nRecursivo := 0
	Default lComp    := .F.
	Default lReport  := .F.
	//Default dCusto	 := ddatabase

	If nRecursivo > 0
		cAlias     := "OTP169S"+STRZERO(nRecursivo,2)
		nRecursivo++
	Endif

	If Empty(cProd) .or. Empty(cTabRef)
		Return 0
	Endif

	// pega o modelo do produto, alguns calculos dependem desta informacao
	//_cModelo := POSICIONE("SB1", 1, XFilial("SB1")+cProd,"B1_XMODELO")
	_cModelo := GetAdvFVal("SB1","B1_XMODELO",xFilial("SB1")+cProd,1,"      ")

	cQry := "SELECT G1_COD,
	cQry += "       G1_COMP,
	cQry += "       B1_DESC,
	cQry += "       B1_UM,
	cQry += "       B1_XDECOMP,
	cQry += "       G1_QUANT,
	cQry += "       ZZM_DATA,
	cQry += "       ZZM_UM,
	cQry += "       ZZM_PICM,
	cQry += "       ZZM_TOTAL,
	cQry += "       DA1_XCUSTO,
	cQry += "       ZZM_MATRIZ,
	cQry += "       G1_QUANT * ZZM_TOTAL as CustoCalculado,
	cQry += "       G1_QUANT * DA1_XCUSTO AS CustoMarfil
	cQry += "  FROM (SELECT DISTINCT G1_COD,
	cQry += "               G1_COMP,
	cQry += "               B1_DESC,
	cQry += "               B1_UM,
	cQry += "               B1_SEGUM,
	cQry += "               CASE
	cQry += "                 WHEN DECOMPOE > 0 AND B1_XDECOMP <> 'N' THEN
	cQry += "                  'S'
	cQry += "                 ELSE
	cQry += "                  B1_XDECOMP
	cQry += "               END AS B1_XDECOMP,
	cQry += "               G1_QUANT,
	cQry += "               ZZM_DATA,
	cQry += "               ZZM_UM,
	cQry += "               ZZM_PICM,
	cQry += "               ZZM_TOTAL,
	cQry += "               DA1_PRCVEN,
	cQry += "               DA1_XCUSTO,
	cQry += "               DECOMPOE,
	cQry += "               ZZM_MATRIZ,
	cQry += "               RANK() OVER(PARTITION BY G1_COMP ORDER BY ZZM_DATA DESC, ZZM_PICM DESC) AS RNK
	cQry += "          FROM (SELECT G1_COD,
	cQry += "                       G1_COMP,
	cQry += "                       B1_DESC,
	cQry += "                       B1.B1_UM,
	cQry += "                       B1.B1_SEGUM,
	cQry += "                       B1_XDECOMP,
	cQry += "                       G1_QUANT,
	cQry += "                       ZZM_DATA,
	cQry += "                       ZZM_UM,
	cQry += "                       ZZM_PICM,
	cQry += "                       ZZM_TOTAL,
	cQry += "                       DA1_CODTAB,
	cQry += "                       DA1_PRCVEN,
	cQry += "                       DA1_XCUSTO,
	cQry += "                       (SELECT COUNT(*)
	cQry += "                          FROM SIGA.SG1030 GC
	cQry += "                         WHERE GC.G1_COD = G1.G1_COMP
	cQry += "                           AND GC.D_E_L_E_T_ = ' '
	cQry += "                           AND GC.G1_FILIAL = '02') AS DECOMPOE,
	cQry += "                       ZZM_MATRIZ
	cQry += "                  FROM SIGA.SG1030 G1
	cQry += "                  LEFT JOIN SIGA.ZZM030 ZZM ON ZZM_COD = G1_COMP
	cQry += "                                           AND ZZM.D_E_L_E_T_ = ' '
	cQry += "                                           AND ZZM_FILIAL = '  '
	cQry += "                                           AND ZZM_ANOTAB = '" + alltrim(str(Year(dDataBase))) + "' "
	cQry += "                                           AND ZZM_CODTAB = '0"+substr(cTabRef,02,02)+"' "
	cQry += "                  LEFT JOIN "
	If cCalculo == "Simulacao"
		cQry += "                       SIGA.PREDA1030 DA1 ON
		cQry += "                                           DA1_CODPRO = G1_COMP
		cQry += "                                           AND DA1_CODTAB LIKE '"+cTabRef+"'

	Else
		cQry += "                       SIGA.DA1030 DA1 ON  DA1_FILIAL = '  '
		cQry += "                                           AND DA1.D_E_L_E_T_ = ' '
		cQry += "                                           AND DA1_CODPRO = G1_COMP
		cQry += "                                           AND DA1_CODTAB LIKE '"+cTabRef+"'

	Endif

	cQry += "                  JOIN SIGA.SB1030 B1 ON B1_COD = G1_COMP
	cQry += "                                     AND B1.D_E_L_E_T_ = ' '
	cQry += "                                     AND B1_FILIAL = '  '
	cQry += "                 WHERE G1_FILIAL = '02'
	cQry += "                   AND G1_COD = '"+cProd+"'
	cQry += "                   AND G1.D_E_L_E_T_ = ' '
	cQry += "                 ORDER BY G1_COD, B1_XDECOMP, G1_COMP, ZZM_DATA DESC)
	cQry += "         ORDER BY G1_COD, G1_COMP, ZZM_DATA) A
	cQry += " WHERE RNK = 1 ORDER BY B1_DESC

	cAlias := U_ORTQUERY(cQry,cAlias,,.F.)

	//MemoWrite("C:\Analistas\marcela.coimbra\orta169C.txt", cQry)

	Do While  !(cAlias)->(EOF())
		_cCodigo    := (cAlias)->G1_COD
		_cCodCom    := (cAlias)->G1_COMP
		_cDescri    := (cAlias)->B1_DESC
		_cDecomp    := (cAlias)->B1_XDECOMP
		_nQuanti    := (cAlias)->G1_QUANT
		_dDtCust    := stod((cAlias)->ZZM_DATA)
		_nImpost    := (cAlias)->ZZM_PICM
		_nCusto     := (cAlias)->ZZM_TOTAL
		_nCusMar    := (cAlias)->DA1_XCUSTO
		_cMatriz    := (cAlias)->ZZM_MATRIZ
		_nCalcNovo  := (cAlias)->CustoCalculado
		_nCalcAnti  := (cAlias)->CustoMarfil

		if alltrim(_cCodigo)=='2010112570'
			c := 'p'
		EndIf

		If _cDecomp == 'S' // se o produto deve ser decomposto, chamo a funcao recursivamente para calculo

			_nRet   := U_ORTP169C(_cCodCom, cTabRef, .T., .F., iif(nRecursivo == 0,1,nRecursivo))

			If _nRet == 0 // caso na decomposicao o valor seja 0, vou assumir o valor inicialmente calculado
				_nRet := _nCalcNovo
			Else
				_nRet := _nRet*_nQuanti
			Endif
		else
			If _nCusto = 0 // se o produto nao é decomposto e nao tiver custo cadastrado, envio o alerta e assumo o custo da tabela de referencia.
				//Alert("O produto: " + _cCodCom + " foi marcado para nao ser decomposto, porém nao possui custo cadastrado.")
				_nRet := _nCalcAnti
			Else
				_nRet := _nCalcNovo      // preco calculado baseado na tabela de custo
			Endif
		Endif
		If _nRet == 0
			_nRet:= ExistZZM(_cCodCom, "0"+substr(cTabRef,02,02))*_nQuanti
		Endif

		_nCUSTOFIN += _nRet // totalizador

		// linha para geracao do relatorio
		aadd(aDados, {_cCodigo,_cCodCom,_cDescri,_cDecomp,Alltrim(StrTran(Str(_nQuanti), '.', ',')),dtoc(_dDtCust),Alltrim(Str(_nImpost)),Alltrim(StrTran(Str(_nCusto), '.', ',')) ,Alltrim(StrTran(Str(_nCusMar), '.', ',')),_cMatriz,Alltrim(StrTran(Str(_nRet), '.', ',')),Alltrim(StrTran(Str(_nCalcAnti), '.', ','))})

		(cAlias)->(dbskip())
	EndDo

	(cAlias)->(DBCLOSEAREA())

// se o produto nao for um item de composicao (semi-acabado), acrescento o % de quebra e adiciono ao relatorio
	If !lComp
		aadd(aDados, {'','','','','','','','','','',Alltrim(StrTran( Str(_nCUSTOFIN), '.', ',')),'  '})
		_nCUSTOFIN := _nCUSTOFIN*nQuebra
		aadd(aDados, {'','','','','','','','','','',Alltrim(StrTran( Str(_nCUSTOFIN), '.', ',')),' (QUEBRA ADICIONADO) '})
	Endif

// se for bloco, é preciso pegar o peso e adicionar nova quebra
	If _cModelo == "000011"
		// busco o peso
		_nPeso := POSICIONE("SB1", 1, XFilial("SB1")+cProd,"B1_XQTDEMB")
		aadd(aDados, {'','','peso',Alltrim(Str(_nPeso)),'','','','','','','',''})

		_nCUSTOFIN := (_nCUSTOFIN/_nPeso)
		// divido o custo geral pelo peso e adiciono a quebra para poder chegar ao valor correto
		aadd(aDados, {'','','','','','','','','','',Alltrim(StrTran( Str(_nCUSTOFIN), '.', ',')),'  '})
		_nCUSTOFIN := _nCUSTOFIN*nQuebra
		aadd(aDados, {'','','','','','','','','','',Alltrim(StrTran( Str(_nCUSTOFIN), '.', ',')),' (QUEBRA ADICIONADO) '})
	Endif

// se parametro de gerar calculo, gero csv na pasta


	If lReport //.and. U_ORTCHKPLAN("ORTP169",cEmpAnt) //Desativado em 02/07/2025 para teste
		PrintCSV({"Codigo","Cod.Composicao","Produto","Decompoe","Quantidade","Data_Custo","Imposto","Custo","Custo_Marfil","CustoMatriz?","Custo_Calculado","Custo_Marfil"}, aDados, "C:\marfil\"+cProd+"\", "ORTP169")
	Endif

	aDados := {}


Return Round(_nCUSTOFIN,2)

Static Function ExistZZM(cCod, cTabela)
	Local cQry  := ""
	Local nCust := 0
	//Default dCusto := ddatabase

	cQry  := "SELECT ZZM_TOTAL
	cQry  += "  FROM (SELECT ZZM_COD, ZZM_DESC, ZZM_DATA, ZZM_TOTAL, ROWNUM AS LINHA
	cQry  += "          FROM (SELECT *
	cQry  += "                  FROM SIGA.ZZM030 ZZM
	cQry  += "                 WHERE ZZM.D_E_L_E_T_ = ' '
	cQry  += "                   AND ZZM_FILIAL = '  '
	cQry  += "                   AND ZZM_COD = '"+cCod+"'
	cQry  += "                   AND ZZM_ANOTAB = '"+ alltrim(str(Year(dDataBase))) + "' "
	cQry  += "                   AND ZZM_CODTAB = '"+cTabela+"'
	cQry  += "                 ORDER BY ZZM_COD, ZZM_DATA DESC, ZZM_PICM DESC, R_E_C_N_O_))
	cQry  += " WHERE LINHA = 1

	cAlias := U_ORTQUERY(cQry, "EXZZMT")
	If  !(cAlias)->(EOF())
		nCust := (cAlias)->ZZM_TOTAL
	Endif
	(cAlias)->(DBCLOSEAREA())

Return nCust

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

	// GRAVA CABECALHO
	For i:=1 TO Len(aHead)
		cLinha += aHead[i]+";"
	Next i

	cLinha += CRLF
	FWrite( cArqRef, cLinha )
	cLinha := ""

	// GRAVA DADOS
	For i:=1 TO Len(aDados)

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

Return cCaminho


//
// Cria os registros da tabela DA0
//
User Function ORTP169T(lAtual)
	Local aTabelas 	:= {}
	Local dDia1 	:= ddatabase
	Local dDataDe	:= ddatabase
	Local dDataAte	:= ddatabase
	Local nSemanas	:= 53
	Local i,x		:= 0
	Default lAtual	:= .F.

	If cEmpAnt <> "03"
		MsgBox("O Acesso a esta rotina é exclusivo da unidade 03", "Unidade Invalida", "INFO")
		Return
	Endif

	// Defino o primeiro dia do ano.
	dDia1 := FirstYDate(ddatabase)

	If Month2Str( ddatabase ) == '12' .AND. !lAtual
		dDia1 := FirstYDate(MonthSum(ddatabase,1))
	Endif

	dDataDe := dDia1

	// Acho o primeiro domingo do ano
	If DoW(dDia1) <> 1
		While DoW(dDataDe) <> 1
			dDataDe++
		EndDo
	Endif

	// ==================================================================
	// forcacao de barra quando a franquia quiser q comece em outra data
	// ==================================================================

	If Year(dDataDe) == 2020
		dDataDe := stod("20200101")
	Endif

	If Year(dDataDe) == 2021
		dDataDe := stod("20210104")
	Endif

	// ==================================================================

	For x:=1 to nSemanas
		aadd(aTabelas,x)
	Next x

	For i:=1 to len(aTabelas)
		lSkip := .F.
		If aTabelas[i] > 1
			while dow(dDataDe) <> 1 .or. dDataDe==ctod("01/01/"+str(year(dDia1),4))
				dDataDe++
			enddo
		endif

		dDataAte:=dDatade+10

		dbselectarea("DA0")
		dbOrderNickName("PDA01")
		dbseek(xFilial("DA0")+strzero(aTabelas[i],3))
		If Found()
			lInsere := .F.
			lUpdate := .T.
			If DA0->DA0_DATATE >= ddatabase
				lSkip := .T. // usado para nao apagar as tabelas em vigencia ainda no ano corrente.
			Endif
		Endif

		If year(dDia1) <> year(dDataDe)
			lSkip := .T.
		Else
			//Alert("Tabela:" + Alltrim(Str(aTabelas[i])) + " Vigencia: " + dtoc(dDatade) + " a " + dtoc(dDataAte))
		Endif

		If (lUpdate .or. lInsere) .AND. !lSkip

			If lUpdate
				reclock("DA0",.F.)
			Else
				reclock("DA0",.T.)
			Endif
			DA0->DA0_CODTAB := strzero(aTabelas[i],3)
			DA0->DA0_DESCRI :="TABELA DE PREÇO "+strzero(aTabelas[i],3)+"/0"
			DA0->DA0_DATDE  :=dDataDe
			DA0->DA0_DATATE :=dDataAte
			DA0->DA0_HORADE :="00:00"
			DA0->DA0_HORATE :="23:59"
			DA0->DA0_TPHORA :="1"
			DA0->DA0_ATIVO  :="1"
			msUnlock()

		Endif
		dDataDe++
	Next i

Return

// Retorna 
User Function ORTP169A(lNext,lPrev)
	Local cTab    := space(3)
	Local cQry    := ""
	Local cAlias  := ""
	Default lNext := .F.
	Default lPrev := .F.

	cQry := "SELECT MAX(DA0_CODTAB) as CODTAB FROM SIGA.DA0030 WHERE DA0_DATDE <= '"+dtos(ddatabase)+"' AND DA0_DATATE >= '"+dtos(ddatabase)+"' AND D_E_L_E_T_ = ' '

	cAlias := U_ORTQUERY(cQry)

	If  !(cAlias)->(EOF())
		cTab := (cAlias)->CODTAB
	Endif

	If lNext
		If VAL(cTab)+1 >= 52
			cTab := '001'
		Else
			cTab := STRZERO(VAL(cTab)+1,3)
		Endif
	Endif

	If lPrev
		If VAL(cTab)-1 <= 0
			cTab := '052'
		Else
			cTab := STRZERO(VAL(cTab)-1,3)
		Endif
	Endif

	(cAlias)->(DBCLOSEAREA())

Return cTab


Static Function retDa1(cTab,cProd)
	Local cQry    := ""
	Local _nCusto := 0
	Local _nVenda := 0
	Local cAlias  := ""

	cQry := "SELECT DA1_XCUSTO, DA1_PRCVEN FROM SIGA.DA1030 WHERE D_E_L_E_T_ = ' ' AND DA1_FILIAL = '"+xFilial("DA1")+"' AND DA1_CODTAB = '"+cTab+"' AND DA1_CODPRO = '"+cProd+"'
	cAlias := U_ORTQUERY(cQry,"RETDA1")

	_nCusto := (cAlias)->DA1_XCUSTO
	_nVenda := (cAlias)->DA1_PRCVEN

Return {_nCusto,_nVenda}

Static Function retSZV(cTab,cGrupo)
	Local cQry    := ""
	Local _nCusto := 0
	Local _nVenda := 0
	Local cAlias  := ""

	cQry := "SELECT ZV_VENDA, ZV_CUSTO FROM SIGA.SZV030 WHERE D_E_L_E_T_ = ' ' AND ZV_FILIAL = '"+xFilial("SZV")+"' AND ZV_TABELA = '"+cTab+"' AND ZV_GRUPO = '"+cGrupo+"'
	cAlias := U_ORTQUERY(cQry, "RETSZV")

	_nCusto := (cAlias)->ZV_CUSTO
	_nVenda := (cAlias)->ZV_VENDA

Return {_nCusto,_nVenda}

User Function ORTP169G(cCod)
	Local cQry := ""
	Local cAlias := ""

	cQry := "SELECT * FROM SIGA.SG1030@finreg WHERE G1_COD = '"+cCod+"' AND D_E_L_E_T_ = ' ' AND G1_FILIAL = '02' ORDER BY G1_COD, G1_COMP "

	cAlias := U_ORTQUERY(cQry,"ORTP169G")

	Do While  !(cAlias)->(EOF())

		IF DBSEEK(XFILIAL("SG1")+(cAlias)->G1_COD+(cAlias)->G1_COMP)
			RecLock("SG1",.F.)
		ELSE
			RecLock("SG1",.T.)
		ENDIF

		G1_FILIAL	:= xFilial("SG1")
		G1_COD		:= (cAlias)->G1_COD
		G1_COMP		:= (cAlias)->G1_COMP
		G1_DESC		:= (cAlias)->G1_DESC
		G1_TRT		:= (cAlias)->G1_TRT
		G1_QUANT	:= (cAlias)->G1_QUANT
		G1_PERDA	:= (cAlias)->G1_PERDA
		G1_INI		:= (cAlias)->G1_INI
		G1_FIM		:= (cAlias)->G1_FIM
		G1_FIXVAR	:= (cAlias)->G1_FIXVAR
		MSUnLock()

		(cAlias)->(dbskip())
	EndDo

	(cAlias)->(DBCLOSEAREA())

Return

//ROTINA DE GRAVAÇÃO
Static Function fGeraMov(cTab) 
	Local cQry := ""
	cQry := "SELECT * FROM SIGA.PREDA1030  WHERE DA1_CODTAB = '"+cTab+"' "  //AND DA1_DTUMOV = '"+dtos(dDatabase)+"'

	cAlias := U_ORTQUERY(cQry,cAlias)

	If !(cAlias)->(EOF())
	msgInfo("Tabela possui registros com ctab ")
	EndIf
	
	Do While  !(cAlias)->(EOF())

	    reclock("DA1",.T.)
		
		DA1->DA1_ITEM  := (cAlias)->DA1_ITEM
		DA1->DA1_FILIAL:= xFilial("DA1")
		DA1->DA1_CODTAB:= (cAlias)->DA1_CODTAB
		DA1->DA1_CODPRO:= (cAlias)->DA1_CODPRO
		DA1->DA1_ATIVO := "1"
		DA1->DA1_TPOPER:= "4"
		DA1->DA1_QTDLOT:= 999999.99
		DA1->DA1_INDLOT:= "000000000999999.99"
		DA1->DA1_MOEDA := 1
		DA1->DA1_XMARCS:= (cAlias)->DA1_XCUSTO
		DA1->DA1_XMARPR:= (cAlias)->DA1_PRCVEN
		DA1->DA1_PERDES:= 0
		DA1->DA1_DTUMOV:= ddatabase
		DA1->DA1_HRUMOV:= time()
		
		msunlock()

		(cAlias)->(dbskip())
	EndDo

(cAlias)->(DBCLOSEAREA())

Return


//ROTINA DE ATUALI
Static Function UPDATEDA1(cTab)

	Local cQry        := ""
	Local cChave      := ""
	Local lRecLockOk  := .F.
	Local lEncontrado := .F.
	Local cAlias      := ""


	cQry := "SELECT DA1_CODTAB, DA1_CODPRO, DA1_ITEM, DA1_XCUSTO, DA1_PRCVEN FROM SIGA.PREDA1030 WHERE DA1_CODTAB <= '"+ cTab+"'"
	cAlias := U_ORTQUERY(cQry, cAlias)

	If !(cAlias)->(EOF())
		MsgInfo("Iniciando a atualização das tabelas de preço até a '"+cTab+"'. Por favor, aguarde...")
	Else
		MsgInfo("Nenhum registro encontrado na tabela de origem (PREDA1030) com DA1_CODTAB = '"+cTab+"'.")
		(cAlias)->(dbCloseArea())
		Return
	EndIf


c_CmdExec := " update  "+RetSqlName("DA1")+" da1 "+CRLF
c_CmdExec += " set da1.da1_xmarpr = 0, da1.da1_xmarcs = 0 "+CRLF
c_CmdExec += " where da1.d_e_l_e_t_ = ' ' "+CRLF
c_CmdExec += " and da1.da1_filial = '"+xfilial("DA1")+"' "+CRLF
c_CmdExec += " and da1.da1_codtab = '"+cTab+"' "+CRLF

TCSQLExec(c_CmdExec)


c_CmdExec := " update "+RetSqlName("DA1")+" da1 "+CRLF
c_CmdExec += " set da1.da1_xmarpr = da1.da1_prcven, da1.da1_xmarcs = da1.da1_xcusto "+CRLF
c_CmdExec += " where da1.d_e_l_e_t_ = ' ' "+CRLF
c_CmdExec += " and da1.da1_filial = '"+xfilial("DA1")+"' "+CRLF
c_CmdExec += " and da1.da1_codtab = '"+cTab+"' "+CRLF

TCSQLExec(c_CmdExec)


c_CmdExec := " update "+RetSqlName("DA1")+" da1 "+CRLF
c_CmdExec += " set da1.da1_prcven = 0, da1.da1_xcusto = 0 "+CRLF
c_CmdExec += " where da1.d_e_l_e_t_ = ' ' "+CRLF
c_CmdExec += " and da1.da1_filial = '"+xfilial("DA1")+"' "+CRLF
c_CmdExec += " and da1.da1_codtab = '"+cTab+"' "+CRLF

TCSQLExec(c_CmdExec)	


	Do While !(cAlias)->(EOF())


		// 1. TRIM THE KEY
		cChave := xFilial("DA1") + (cAlias)->DA1_CODTAB + (cAlias)->DA1_CODPRO
		dbSelectArea("DA1")
		dbSetOrder(7)

		lEncontrado := dbSeek(cChave)

		If lEncontrado
			lRecLockOk := RecLock("DA1", .F.)
			If lRecLockOk
				// Converte o valor de texto para número antes de salvar
				DA1->DA1_XCUSTO := (cAlias)->DA1_XCUSTO
				DA1->DA1_PRCVEN := (cAlias)->DA1_PRCVEN
				DA1->(MsUnLock())
			EndIf
		EndIf
		(cAlias)->(dbSkip())
	EndDo

	(cAlias)->(dbCloseArea())

	MsgInfo("Processo de atualização finalizado com sucesso!")

Return

