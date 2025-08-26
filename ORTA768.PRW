#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#include "TopConn.ch"
#Include "SigaWin.Ch"
#INCLUDE "TBICONN.CH"

 
User Function ORTA768()

	Local _cMsg		:= ""


	Private oDlg1
	Private oGrp1
	Private oSay1
	Private oBtn1
	Private oGrp2
	Private oBtn5
	Private oBtn4
	Private oBtn3
	Private oBtn2
	Private oGrp3
	Private oBtn6
	Private oBtn7
	Private oGrp4
	Private oBtn9
	Private oBtn10
	Private oBtn11
	Private oBtn12
	Private oBtn13
	Private oBtn14

	makedir('\cobol\cobol\03\msiga\')

	If cEmpAnt <> "03"
		MsgBox("O Acesso a esta rotina é exclusivo da unidade 03", "Unidade Invalida", "INFO")
		Return
	Endif

	if !U_ORTGRUPO("MARFIL")
	
		_cMsg := "<html><head></head><body>" + CRLF	
		_cMsg += "<br> Prezado(a) " + AllTrim(cUserName) + ",    " + CRLF
		_cMsg += "<br>Você não tem permissão para executar essa ação.<br> " + CRLF
		_cMsg += "Favor solicitar a seu gestor inclusão no grupo de liberação ( MARFIL / A_0114).<br> " + CRLF
		_cMsg += "Obs.: É necessário abertura de SSI para inclusão no grupo de liberação "
		_cMsg += "e a ASSINATURA E LIBERAÇÃO do Audidor da Regional.<br>" + CRLF
		_cMsg += "</body></html>"     + CRLF

		msginfo(_cMsg, "ATENÇÃO  (ORTA768)")
		
		return
	endif
	
	oDlg1      := MSDialog():New( 088,232,470,878,"Marfil - Colchoes",,,.F.,,,,,,.T.,,,.T. )

	oGrp1      := TGroup():New( 002,002,180,380,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1      := TSay():New( 010,007,{||"Nesta - interface voce pode realizar todas as atividades referentes a manutencao de produtos e tabelas de preços"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,017)
	oBtn1      := TButton():New( 010,212,"Sair",oGrp1, {|| oDlg1:end() },035,017,,,,.T.,,"",,,,.F. )

	oGrp2      := TGroup():New( 034,007,076,360," Cadastros ",oGrp1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	// linha 1
	oBtn5      := TButton():New( 044,010,"Custos MP",oGrp2,{|| U_ORTA768X() },050,012,,,,.T.,,"",,,,.F. )
	oBtn4      := TButton():New( 044,070,"Grupos"   ,oGrp2,{|| U_ORTA767()  },050,012,,,,.T.,,"",,,,.F. )
	oBtn3      := TButton():New( 044,130,"Modelos"  ,oGrp2,{|| U_ORTA763()  },050,012,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton():New( 044,190,"Linhas/Sub-Grupos",oGrp2,{|| U_ORTA762()  },050,012,,,,.T.,,"",,,,.F. )
	oBtn14     := TButton():New( 044,250,"Agrupamentos"	    ,oGrp2,{|| U_ORTA776()  }	 ,050,012,,,,.T.,,"",,,,.F. )

	// linha 2 
	oBtn14     := TButton():New( 060,010,"Produtos de terceiros" ,oGrp2,{|| U_ORTA768P()  }	 ,050,012,,,,.T.,,"",,,,.F. )
	oBtn14     := TButton():New( 060,070,"Cadastro de blocos"	 ,oGrp2,{|| U_ORTA768B()  }	 ,050,012,,,,.T.,,"",,,,.F. )
	oBtn14     := TButton():New( 060,130,"Fora de linha"	 	 ,oGrp2,{|| U_ORTA768L()  }	 ,050,012,,,,.T.,,"",,,,.F. )
	//oBtn14     := TButton():New( 060,190,"De x Insumos"	 		 ,oGrp2,{|| U_ORTA768G()  }	 ,050,012,,,,.T.,,"",,,,.F. )

	// linha 3
	oGrp3      := TGroup():New( 080,007,135,380," Relatórios "	,oGrp1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oBtn6      := TButton():New( 090,010,"M.P Sem Custo"    	,oGrp3,{|| U_ORTR813('A') },070,012,,,,.T.,,"",,,,.F. )
	oBtn12     := TButton():New( 090,090,"Prod Vs Grupo"    	,oGrp3,{|| U_ORTR813('B') },070,012,,,,.T.,,"",,,,.F. )
	oBtn8      := TButton():New( 090,170,"Marfil"           	,oGrp3,{|| U_ORTR814() },070,012,,,,.T.,,"",,,,.F. )
	oBtn15     := TButton():New( 090,250,"Prod.Sem Composicao"	,oGrp3,{|| U_ORTR813('C') },070,012,,,,.T.,,"",,,,.F. )
	
	// linha 4
	oBtn15     := TButton():New( 105,010,"Detalha Custo"	,oGrp3,{|| U_ORTA768D(.T.) },070,012,,,,.T.,,"",,,,.F. )	
	oBtn15     := TButton():New( 105,090,"Comercial"      	,oGrp3,{|| U_ORTR813C(.T.) },070,012,,,,.T.,,"",,,,.F. )
	oBtn15     := TButton():New( 105,170,"Franquia"      	,oGrp3,{|| U_ORTR813F(.T.) },070,012,,,,.T.,,"",,,,.F. )
	oBtn15     := TButton():New( 105,250,"Blocos"      		,oGrp3,{|| U_ORTR813D(.T.) },070,012,,,,.T.,,"",,,,.F. )

	// linha 5
	oBtn15     := TButton():New( 120,010,"Industrial"      	,oGrp3,{|| U_ORTR813I(.T.) },070,012,,,,.T.,,"",,,,.F. )
	oBtn15     := TButton():New( 120,90,"Cobol vs Marfil"      	,oGrp3,{|| U_ORTR813H() },070,012,,,,.T.,,"",,,,.F. )

	// linha 6
	oGrp4      := TGroup():New( 141,007,177,380," Operações ",oGrp1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oBtn9      := TButton():New( 157,010,"Gerar Marfil"     ,oGrp4,{|| U_ORTP169() }	,050,012,,,,.T.,,"",,,,.F. )
	oBtn10     := TButton():New( 157,070,"Gerar Sob-Medida" ,oGrp4,{|| U_ORTP169(.T.) }	,050,012,,,,.T.,,"",,,,.F. )
	oBtn13     := TButton():New( 157,130,"Ajustes"		    ,oGrp4,{|| U_ORTA768A()	}	,050,012,,,,.T.,,"",,,,.F. )
	oBtn16     := TButton():New( 157,190,"Fora de linha"		    ,oGrp4,{|| U_ORTR813L()	}	,050,012,,,,.T.,,"",,,,.F. )
	oBtn11     := TButton():New( 157,270,"Exportar"         ,oGrp4,{|| U_ORTA768E() }	,050,012,,,,.T.,,"",,,,.F. )
	oDlg1:Activate(,,,.T.)
Return


// U_ORTA768X()
// CHAMADA VIA X2_ROTINA
User Function ORTA768X ()
	Local cCodTab		:= '000'
	Local aPergs     := {}
	Local aRet       := {}
	Private cTitulo  := "Exportacao Marfil"

	if cEmpAnt <> "03"
		MsgBox("O Acesso a esta rotina é exclusivo da unidade 03", "Unidade Invalida", "INFO")
		return
	endif


	aAdd( aPergs ,{1,"Semana         :" ,U_ORTP169A(),"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .T.   })

	If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTA768" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
		Return
	EndIf

	cCodTab  := PadL( MV_PAR01, 3, "0" )

	U_ORTA768C(cCodTab)

	If MsgYesNo("Deseja processar tabela liberada pela Matriz?")
		Processa( {|| ORTA768X(cCodTab) }, "Aguarde...", "Sincronizando custos oriundos da Matriz...",.F.)
		//Processa( {|| ORTA768Z() }, "Aguarde...", "Importando Custos ",.F.) // DESABILITAR NO FUTURO
	Endif

	U_ORTP115(cCodTab)
	
Return

// replica os custos cadastrados pela matriz 
Static Function ORTA768X(cCodTab)
	
	Local cQuery  		:= ""
	Local lDelete 		:= .F.
	Local lInc    		:= .T.
	Local lExiste 		:= .F.
	Local lResp   		:= .F.
	Local aRepo   		:= {} 
	Local _aNaoConfia	:= {}
	Local lTemNaoConfia := .F.
	
	Private aArea := GetArea()

	//BEGIN TRANSACTION
	cQuery:="SELECT COUNT(*) AS CONTAR FROM SIGA.ZZM030 WHERE ZZM_FILIAL = '  ' AND ZZM_CODTAB = '" + cCodTab + "' AND ZZM_ANOTAB = '" + alltrim(str(Year(dDataBase))) + "' " 
	cAlias := U_ORTQUERY(cQuery, "OT768C")

	ProcRegua((cAlias)->CONTAR)

    If !fStatusZZM(cCodTab)

		Return

	ENDIF

	cQuery := " SELECT ZM.ZZM_FILIAL, "
	cQuery += " ZM.ZZM_COD, "
	cQuery += " ZM.ZZM_DESC, "
	cQuery += " ZM.ZZM_DATA, "
	cQuery += " ZM.ZZM_PTAX, "
	cQuery += " ZM.ZZM_UM, "
	cQuery += " ZM.ZZM_PICM, "
	cQuery += " ZM.ZZM_SICM, "
	cQuery += " ZM.ZZM_VLRANT, "
	cQuery += " ZM.ZZM_PORC, "
	cQuery += " ZM.ZZM_IPI, "
	cQuery += " ZM.ZZM_VLRNOV, "
	cQuery += " ZM.ZZM_VLRUSD, "
	cQuery += " ZM.ZZM_TOTAL, "
	cQuery += " ZM.ZZM_IMPORT, "
	cQuery += " ZM.ZZM_CODTAB, "
	cQuery += " ZM.ZZM_DTFECH, "
	cQuery += " ZM.ZZM_STATUS, "
	cQuery += " ZM.ZZM_ANOTAB, "
	cQuery += " ZM.ZZM_JUSTIF, "
	cQuery += " zm.R_E_C_N_O_, 'S' ZZM_MATRIZ, "
	cQuery += " ZM.d_e_l_e_t_ AS DELETADO, " 
	cQuery += " coalesce(sb1.b1_desc,'INEXISTENTE') b1_desc " 
	cQuery += " FROM SIGA.ZZM030 ZM 
	cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1"
	cQuery += " on sb1.d_e_l_e_t_ =  ' '
	cQuery += " and sb1.b1_FILIAL = '"+xFilial("SB1")+"' 
	cQuery += " and sb1.b1_cod = ZZM_COD
	cQuery += " WHERE ZM.ZZM_FILIAL = '  ' 
	cQuery += "    AND ZM.ZZM_CODTAB = '" + cCodTab + "' "
	cQuery += "    AND ZM.ZZM_STATUS = 'F'
	cQuery += "    AND ZM.ZZM_ANOTAB = '" + alltrim(str(Year(dDataBase))) + "' "
	cQuery += "    AND ZM.ZZM_DATA = (	SELECT MAX(ZZM_DATA) "
	cQuery += "              			FROM  SIGA.ZZM030 ZZX "
	cQuery += "              			WHERE ZZX.ZZM_FILIAL = ' ' "
	cQuery += "              			AND ZZX.D_E_L_E_T_ = ' ' "
	cQuery += "              			AND ZZX.ZZM_CODTAB  = '" +cCodTab+"' "
	cQuery += "              			AND ZZX.ZZM_ANOTAB  = ZM.ZZM_ANOTAB "
	cQuery += "              			AND ZZX.ZZM_COD = ZM.ZZM_COD) "

	cTabAnt := strzero(val(cCodTab ) - 1, 3)
/*
	cQuery += " UNION "

	cQuery += " SELECT ZZM_FILIAL, "
	cQuery += " ZZM_COD, "
	cQuery += " ZZM_DESC, "
	cQuery += " ZZM_DATA, "
	cQuery += " ZZM_PTAX, "
	cQuery += " ZZM_UM, "
	cQuery += " ZZM_PICM, "
	cQuery += " ZZM_SICM, "
	cQuery += " ZZM_VLRANT, "
	cQuery += " ZZM_PORC, "
	cQuery += " ZZM_IPI, "
	cQuery += " ZZM_VLRNOV, "
	cQuery += " ZZM_VLRUSD, "
	cQuery += " ZZM_TOTAL, "
	cQuery += " ZZM_IMPORT, "
	cQuery += " ZZM_CODTAB, "
	cQuery += " ZZM_DTFECH, "
	cQuery += " ZZM_STATUS, "
	cQuery += " ZZM_ANOTAB, "
	cQuery += " ZZM_JUSTIF, "
	cQuery += " R_E_C_N_O_,ZZM_MATRIZ, "
	cQuery += " ZM.d_e_l_e_t_ AS DELETADO "
	cQuery += " FROM SIGA.ZZM510 ZM 
	cQuery += " WHERE ZZM_FILIAL = '  ' 
	cQuery += "    AND ZZM_CODTAB = '" + cTabAnt + "' "
	cQuery += "    AND ZZM_ANOTAB = " + alltrim(str(Year(dDataBase))) + " "
	cQuery += "    AND ZZM_MATRIZ = 'N'
	cQuery += "   AND ZZM_DATA = (SELECT MAX(ZZM_DATA) "
	cQuery += "              FROM  SIGA.ZZM510 ZZX "
	cQuery += "              WHERE ZZX.ZZM_FILIAL = ' ' "
	cQuery += "              AND ZZX.D_E_L_E_T_ = ' ' AND ZZM_MATRIZ = 'N' "
	cQuery += "              AND ZZX.ZZM_CODTAB  = '" +cTabAnt+"' "
	cQuery += "              AND ZZX.ZZM_ANOTAB = ZM.ZZM_ANOTAB "
	cQuery += "              AND ZZX.ZZM_COD = ZM.ZZM_COD) "
*/

	cQuery+=" ORDER BY ZZM_COD, ZZM_DATA"

	U_ORTQUERY(cQuery, "OT768X")

	Do While  !OT768X->(EOF()) 

		IncProc()

		If OT768X->DELETADO == "*"
			lDelete := .T.
		else
			lDelete := .F.
		Endif

		cQuery:="SELECT r_e_c_n_o_ AS RECN FROM SIGA.ZZM030 WHERE ZZM_FILIAL = '  ' AND ZZM_XRECOR = " + Alltrim(Str(OT768X->R_E_C_N_O_)) + " and d_e_l_e_t_ = ' ' "

		cAlias := U_ORTQUERY(cQuery, "OT768G")

		If (cAlias)->(EOF()) 
			lExiste := .F.
			lInc    := .T.
		Else
			lExiste := .T.
			lInc    := .F.
			DbSelectArea("ZZM")
			DbSetOrder(1)
			DbGoTo((cAlias)->RECN)			
		Endif

		_cDescLoc := Alltrim(OT768X->b1_desc)
		/*_
		cDescLoc := POSICIONE("SB1",1,XFILIAL("SB1")+OT768X->ZZM_COD,"B1_DESC")
		If Empty(_cDescLoc)
			_cDescLoc := "INEXISTENTE"
		Endif		
		_cDescMat := alltrim(OT768X->ZZM_DESC)
		*/
		_cDescMat := alltrim(OT768X->ZZM_DESC)

		lResp := .T.

		If _cDescLoc == "INEXISTENTE"
			lResp := .F. // NAO GRAVAR TABELA PARA NAO DAR DIVERGENCIA QUANDO CRIAR
			aadd(aRepo, {OT768X->ZZM_COD,_cDescMat})
		ElseIf alltrim(_cDescLoc) <> _cDescMat
			if !Confia(OT768X->ZZM_COD,_cDescMat)
				lResp := .F. //MsgYesNo("A descrição dos produtos difere entre os sistemas!<br> CODIGO: "+OT768X->ZZM_COD+" <br> Matriz : "+Alltrim(_cDescMat)+" <br> Local: "+Alltrim(_cDescLoc)+" <br>Voce confirma que é o mesmo produto?")
				lTemNaoConfia := .T.
			Endif
		Endif

			//If _cDescLoc <> "INEXISTENTE"
			/*
			_cConf := "INSERT INTO SIGA.CONFZZM (CONF_COD,CONF_DESC,CONF_DATA) VALUES ('"+OT768X->ZZM_COD+"','"+_cDescMat+"','"+dtos(ddatabase)+"')"
			if tcsqlexec(_cConf) <> 0
				alert("erro ao registrar confirmacao.")
			Endif
			*/
			
				_cConf := "UPDATE SIGA.ZZM030 SET ZZM_STATUS = '"+ iIf(lResp,"I" , "E") +"' WHERE R_E_C_N_O_ = " + str(OT768X->R_E_C_N_O_ ) +  " "
				if tcsqlexec(_cConf) <> 0
					alert("erro ao registrar confirmacao.")
				Endif

		if !lResp
			If Alltrim(_cDescLoc) <> 'INEXISTENTE'
				aadd(_aNaoConfia, { OT768X->ZZM_COD, Alltrim(_cDescMat), Alltrim(_cDescLoc) })
			EndIf
		Endif

		//Endif
		OT768X->(dbskip())
	EndDo
	//END TRANSACTION

	If len(aRepo) > 0
		EnvNaoExist(aRepo)
	Endif
	If len(_aNaoConfia) > 0
		EnvNaoConfia(_aNaoConfia)
	Endif

	// Analisa a variacao e notifica por email
	//AnalisaVar()

	If lTemNaoConfia .OR. len(aRepo) > 0
		cMsg1:= ""
		cMsg2:= ""
		If lTemNaoConfia
			cMsg1 := "Alguns registros["+Alltrim(Str(Len(_aNaoConfia)))+"] não foram importados por não estarem na lista de confiabilidade."
		Endif
		If len(aRepo) > 0
			cMsg2 := "Alguns registros["+Alltrim(Str(Len(aRepo)))+"] não foram importados por não existirem no sistema local."
		Endif
		MsgBox(cMsg1+cMsg2, "Atenção", "INFO")
	Endif

	restarea(aArea)
Return()

//
//  !! pre implantacao !! 
// Alimenta a tabela de custos com os custos da marfil informada
// serve para fazer os cadastros dos produtos q nao vem da matriz
//
Static Function ORTA768Z(cTab)
	Local aArea   := GetArea()
	Local cQuery  := ""
	Local lInc    := .T.
	Local cTabela := "Z"+STRZERO(VAL(U_ORTP169A()),2)
	
	Default cTab  := ""

	If !Empty(cTab)
		cTabela := cTab
	Endif

	BEGIN TRANSACTION

		cQuery:=" SELECT COUNT(*) AS CONTAR  FROM SIGA.DA1030 DA1 WHERE DA1_FILIAL = '  ' AND DA1.D_E_L_E_T_ = ' ' AND DA1_CODTAB = '"+cTabela+"' AND NOT EXISTS (SELECT 'X' FROM SIGA.ZZM030 ZM WHERE ZZM_FILIAL = '  ' AND ZM.D_E_L_E_T_ = ' ' AND ZZM_COD = DA1_CODPRO AND ZZM_MATRIZ = 'S')"
		cAlias := U_ORTQUERY(cQuery, "OT768C")

		ProcRegua((cAlias)->CONTAR)

		cQuery:="SELECT * FROM SIGA.DA1030 DA1 WHERE DA1_FILIAL = '  ' AND DA1.D_E_L_E_T_ = ' ' AND DA1_CODTAB = '"+cTabela+"' AND NOT EXISTS (SELECT 'X' FROM SIGA.ZZM030 ZM WHERE ZZM_FILIAL = '  ' AND ZM.D_E_L_E_T_ = ' ' AND TRIM(ZZM_COD) = TRIM(DA1_CODPRO) AND TRIM(ZZM_MATRIZ) = 'S' )"
		U_ORTQUERY(cQuery, "OT768X")

		Do While  !OT768X->(EOF())

			IncProc()

			lInc    := .T.

			If RecLock("ZZM",lInc)
				ZZM->ZZM_FILIAL := XFILIAL("ZZM")
				ZZM->ZZM_COD    := OT768X->DA1_CODPROD
				ZZM->ZZM_DESC	:= Alltrim(POSICIONE("SB1",1,XFILIAL("SB1")+OT768X->DA1_CODPROD,"B1_DESC"))
				ZZM->ZZM_DATA	:= DDATABASE
				ZZM->ZZM_UM	    := Alltrim(POSICIONE("SB1",1,XFILIAL("SB1")+OT768X->DA1_CODPROD,"B1_UM"))
				ZZM->ZZM_PICM   := 0
				ZZM->ZZM_SICM   := 0
				ZZM->ZZM_VLRANT := 0
				ZZM->ZZM_PORC   := 0
				ZZM->ZZM_VLRNOV := OT768X->DA1_XCUSTO
				ZZM->ZZM_IPI    := 0
				ZZM->ZZM_TOTAL  := OT768X->DA1_XCUSTO
				ZZM->ZZM_IMPORT := "N"
				ZZM->ZZM_MATRIZ := "N"
				ZZM->ZZM_CODTAB := StrTran( cTabela, "Z", "0" )//OT768X->DA1_CODTAB
				ZZM->ZZM_ANOTAB := ALLTRIM(STR(YEAR(DdATAbASE)))
				//ZZM->ZZM_XRECOR := OT768X->R_E_C_N_O_
				ZZM->(MsUnLock())
			Endif

			OT768X->(dbskip())
		EndDo
	END TRANSACTION

	restarea(aArea)
Return()

// Analisa a variacao dos custos na tabela de custos
// caso encontre variacoes acima de x% envia por email para a Katia analisar.
Static Function AnalisaVar()
	Local cQuery      := ""
	Local cSQuery     := ""
	Local aProdutos   := {}
	Local cProd       := ""
	Local cDescr      := ""
	Local nVal1       := 0
	Local nVal2       := 0
	Local cEmail      := ""
	Local cData1      := ""
	Local cData2      := ""
	Local i           := 0
	Local lMod		  := .F.
	Local nPercentual := 10

	cQuery := "SELECT ZZM_COD, COUNT(*) AS TOTAL
	cQuery += "  FROM SIGA.ZZM030 ZZM, SIGA.SB1030 SB1
	cQuery += " WHERE ZZM.D_E_L_E_T_ = ' '
	cQuery += "   AND SB1.D_E_L_E_T_ = ' '
	cQuery += "   AND SB1.B1_COD = ZZM.ZZM_COD
	cQuery += "   AND SB1.B1_MSBLQL <> '1'
	cQuery += "   AND ZZM.ZZM_FILIAL = '  '
	cQuery += "   AND SB1.B1_FILIAL  = '  '
	cQuery += "   AND (B1_TIPO = 'MP' OR LENGTH(TRIM(LEADING 0 FROM B1_COD)) <= 5 )
	cQuery += "   AND EXISTS (SELECT 'X'
	cQuery += "          FROM SIGA.ZZM030 ZMD
	cQuery += "         WHERE ZMD.ZZM_DATA >= '"+dtos(ddatabase-10)+"'
	cQuery += "           AND ZMD.D_E_L_E_T_ = ' '
	cQuery += "           AND ZMD.ZZM_COD = ZZM.ZZM_COD)
	cQuery += " GROUP BY ZZM.ZZM_COD
	cQuery += " HAVING COUNT(*) > 1

	U_ORTQUERY(cQuery, "OT768V")

	Do While  !OT768V->(EOF())

		cSQuery:= "SELECT ROWNUM, ZZM_COD, ZZM_DESC, ZZM_DATA, ZZM_PICM, ZZM_TOTAL
		cSQuery+= "  FROM (SELECT ZZM_COD, ZZM_DESC, ZZM_DATA, ZZM_PICM, MAX(ZZM_TOTAL) AS ZZM_TOTAL
		cSQuery+= "          FROM SIGA.ZZM030
		cSQuery+= "         WHERE D_E_L_E_T_ = ' '  AND ZZM_FILIAL = '  '
		cSQuery+= "           AND ZZM_COD = '"+OT768V->ZZM_COD+"' GROUP BY ZZM_COD, ZZM_DESC, ZZM_DATA, ZZM_PICM
		cSQuery+= "         ORDER BY ZZM_COD, ZZM_DATA DESC)

		U_ORTQUERY(cSQuery, "OT768A")
		If OT768A->(!EOF())
			lMod := .F.
			cProd  := OT768A->ZZM_COD
			cDescr := OT768A->ZZM_DESC
			nVal1  := OT768A->ZZM_TOTAL
			cData1 := dtoc(stod(OT768A->ZZM_DATA))
			OT768A->(dbskip())
			nVal2  := OT768A->ZZM_TOTAL
			cData2 := dtoc(stod(OT768A->ZZM_DATA))
			If OT768A->ZZM_DESC <> cDescr
				lMod := .T.
			Endif

			If nVal2 > 0
				nDif := ABS(fDif(nVal1,nVal2))
				If nDif > nPercentual
					aadd(aProdutos, {nVal1,nVal2,nDif, cProd, cDescr,cData1,cData2, lMod})
				Endif
			Endif

		Endif

		OT768V->(dbskip())
	EndDo

	If len(aProdutos) > 0

		cEmail := "Os seguintes produtos tiveram variacao no custo acima de " + Alltrim(Str(nPercentual)) + "%:<br>"  + CRLF

		cEmail +="<table>
		cEmail +=" <thead>
		cEmail +="  <tr>
		cEmail +="    <th>Produto</th>
		cEmail +="    <th>Descricao</th>
		cEmail +="    <th>Variacao</th>
		cEmail +="    <th>Custo Novo</th>
		cEmail +="    <th>Data</th>
		cEmail +="    <th>Custo Anterior</th>
		cEmail +="    <th>Data </th>
		cEmail +="  </tr>
		cEmail +="</thead>
		cEmail +="<tbody>" 

		For i:=1 to len(aProdutos)
			cEmail +=" <tr>
			cEmail +="    <td>"+aProdutos[i][4] + iif(aProdutos[i][8],'(*)','') + "</td>
			cEmail +="    <td>"+Alltrim(aProdutos[i][5])+"</td>
			cEmail +="    <td>"+Alltrim(Str(aProdutos[i][3]))+"</td>
			cEmail +="    <td>"+Alltrim(Str(aProdutos[i][1]))+"</td>
			cEmail +="    <td>"+Alltrim(aProdutos[i][6])+"</td>
			cEmail +="    <td>"+Alltrim(Str(aProdutos[i][2]))+"</td>
			cEmail +="    <td>"+Alltrim(aProdutos[i][7])+"</td>
			cEmail +=" </tr>
		Next i

		cEmail +="</tbody>
		cEmail +="</table>
		cEmail += " (*) Indica que houve alguma alteracao na descrição do produto informada pela Matriz.<br>"  + CRLF

		lRet := U_ORTA584("rafael.mattos@ortobom.com.br", "[SIGO] VARIACAO NO CUSTO IMPORTADO DA MATRIZ", cEmail, {}, "")
		//->lRet := U_ORTA584("estatistica@ortobom.com.br", "[SIGO] VARIACAO NO CUSTO IMPORTADO DA MATRIZ", cEmail, {}, "marcela.coimbra@ortobom.com.br;rafael.melo@ortobom.com.br")
		
		If lRet
			U_JobCInfo("ORTA768.PRW", "[SUCESSO] Envio do email de notificacao", 1)
		Else
			U_JobCInfo("ORTA768.PRW", "[ERRO]Erro no envio do email de notificacao", 1)
		Endif

	Endif

Return

// Envia a relacao de produtos que nao existem no ERP e tem codigos lancados com preco para a Katia analisar e solicitar o cadastro a matriz.
Static Function EnvNaoExist(aProdutos)
	Local cEmail      := ""
	Local i           := 0
	Local lRet		  := .F.
	If len(aProdutos) > 0

		cEmail := "Os seguintes produtos existentes na tabela da Matriz não existem no sistema local e não foram importados.<br>"  + CRLF

		cEmail +="<table>
		cEmail +=" <thead>
		cEmail +="  <tr>
		cEmail +="    <th>Produto</th>
		cEmail +="    <th>Descricao</th>
		cEmail +="  </tr>
		cEmail +="</thead>
		cEmail +="<tbody>

		For i:=1 to len(aProdutos)
			cEmail +=" <tr>
			cEmail +="    <td>"+Alltrim(aProdutos[i][1])+" -</td>
			cEmail +="    <td>"+Alltrim(aProdutos[i][2])+"</td>
			cEmail +=" </tr>
		Next i

		cEmail +="</tbody>
		cEmail +="</table>

		lRet := U_ORTA584("rafael.mattos@ortobom.com.br", "[SIGO] PRODUTOS NAO EXISTENTES NO SISTEMA LOCAL", cEmail, {}, "")
		//->lRet := U_ORTA584("estatistica@ortobom.com.br", "[SIGO] PRODUTOS NAO EXISTENTES NO SISTEMA LOCAL", cEmail, {}, "fabio.costa@ortobom.com.br")		

		If lRet
			U_JobCInfo("ORTA768.PRW", "[SUCESSO] Envio do email de notificacao", 1)
		Else
			U_JobCInfo("ORTA768.PRW", "[ERRO]Erro no envio do email de notificacao", 1)
		Endif

	Endif

Return

// Envia a relacao de produtos cuja descricao difere entre os sistemas e solicitar a correcao dos mesmos.
Static Function EnvNaoConfia(aDados)
	Local cEmail      := ""
	Local i           := 0
	Local lRet		  := .F.
	If len(aDados) > 0

		cEmail := "Os seguintes produtos possuem descricoes diferentes e não foram reconhecidos para importacao no sistema de custos.<br>"  + CRLF

		cEmail +="<table>
		cEmail +=" <thead>
		cEmail +="  <tr>
		cEmail +="    <th>Produto</th>
		cEmail +="    <th>Descricao Matriz</th>
		cEmail +="    <th>Descricao Regional</th>
		cEmail +="  </tr>
		cEmail +="</thead>
		cEmail +="<tbody>

		For i:=1 to len(aDados)
			cEmail +=" <tr>
			cEmail +="    <td>"+Alltrim(aDados[i][1])+" -</td>
			cEmail +="    <td>"+Alltrim(aDados[i][2])+"</td>
			cEmail +="    <td>"+Alltrim(aDados[i][3])+"</td>
			cEmail +=" </tr>
		Next i

		cEmail +="</tbody>
		cEmail +="</table>
		
		lRet := U_ORTA584("rafael.mattos@ortobom.com.br", "[SIGO] PRODUTOS COM DESCRICAO DIVERGENTES E NAO IMPORTADOS", cEmail, {}, "")
		//->lRet := U_ORTA584("estatistica@ortobom.com.br", "[SIGO] PRODUTOS COM DESCRICAO DIVERGENTES E NAO IMPORTADOS", cEmail, {}, "fabio.costa@ortobom.com.br,gabriel.rezende@ortobom.com.br,michele@matrizsp.com.br,rodolfo.paulelo@matrizsp.com.br,felipe.baptistao@matrizsp.com.br")

		If lRet
			U_JobCInfo("ORTA768.PRW", "[SUCESSO] Envio do email de notificacao", 1)
		Else
			U_JobCInfo("ORTA768.PRW", "[ERRO]Erro no envio do email de notificacao", 1)
		Endif

	Endif

Return

// Retorna a variacao percentual entre 2 numeros
Static Function fDif(nVal1,nVal2)
Return 100-((nVal1/nVal2)*100)


// Exporta nas Fabricas VIA RPC
User Function ORTA768E()
	Local aPergs     := {}
	Local aRet       := {}
	Local nX         := 1
	Private aUnids   := {}
	Private cTitulo  := "Exportacao Marfil"
	Private cSemana  := ""
	Private cResposta:= ""
	Private cInic    := substr(getmv("MV_XMFDTRE"), 1, 8)
	Private cFin     := dtos(dDataBase)

	If cEmpAnt <> "03"
		MsgBox("O Acesso a esta rotina é exclusivo da unidade 51", "Unidade Invalida", "INFO")
		Return
	Endif

	aAdd( aPergs ,{1,"Semana         :" ,U_ORTP169A(),"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .T.   })

	If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTA768" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
		Return
	EndIf

	cSemana  := PadL( MV_PAR01, 3, "0" )

	If !MsgYesNo("Voce tem certeza de que deseja distribuir a tabela marfil nas unidades?")
		alert("Ok, a operacao foi cancelada.")
		Return
	Endif

	alert("Processo encerrado até a homologacao da rotina.Os dados nao serão enviados as unidades.")
//RETURN

	aAdd(aUnids, "04")

/*
	aAdd(aUnids, "03")
	
	aAdd(aUnids, "18")
	aAdd(aUnids, "02")

	aAdd(aUnids, "04")

	aAdd(aUnids, "05")
	aAdd(aUnids, "06")
	aAdd(aUnids, "07")
	aAdd(aUnids, "08")
	aAdd(aUnids, "09")
	aAdd(aUnids, "10")
	aAdd(aUnids, "11")
	aAdd(aUnids, "15")
	aAdd(aUnids, "26")
    */
	/*
    aAdd(aUnids, "21")
    aAdd(aUnids, "22")
    aAdd(aUnids, "23")
    aAdd(aUnids, "24")
    */

	For nX := 1 To Len(aUnids)
		lLocal := .F.

		//If aUnids[nX] $ "03"
		//    lLocal := .T.
		//Endif

			If MsgYesNo("Deseja gravar a marfil na unidade: " + aUnids[nX] + "?")

			If !lLocal
				Processa( {|| cResposta	:= U_ORTXRPC(aUnids[nX], "U_ORTA768T", {cSemana, cInic, cFin}, .T., "homologmg") }, "Aguarde...", "Gravando Marfil na unidade " + aUnids[nX] + "...",.F.)
			Else
				Processa( {|| cResposta	:= U_ORTA768T(cSemana) }, "Aguarde...", "Gravando Marfil na unidade " + aUnids[nX] + "...",.F.)
			Endif

			If ValType(cResposta) <> "C"
				alert("Erro ao efetuar a gravacao na unidade:" + aUnids[nX])
			EndIf
		EndIf
	Next nX

Return

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// ESSA FUNCAO É CHAMADA VIA RPC PARA LEVAR OS DADOS APROVADOS
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
User Function ORTA768T(cSemana, cDtIni, cDtFin)
	Local cQueryA0 := ""
	Local cQueryA1 := ""
	Local dbLink   := ""
	Local lUpdate  := .F.




	U_JobCInfo("ORTA768T.PRW", "INICIO")

	If cEmpAnt $ "02|04|05|06|07|08|09|10|11|15|26|21|22|23|24"
		dbLink:="@DB03"
	Endif

	// Seleciono a DA0 na empresa 51
	cQueryA0 := "SELECT * FROM SIGA.DA0030"+dbLink+" WHERE DA0_CODTAB = '"+cSemana+"' AND D_E_L_E_T_ = ' ' AND DA0_FILIAL = '  '"
	
	U_JobCInfo("ORTA768T.PRW", "cQueryA0: " + cQueryA0 )

	U_ORTQUERY(cQueryA0, "ORTA768T")

	Do While .f. .and. !ORTA768T->(EOF())
		lUpdate := .F.

		/*
		dbselectarea("DA0")
		dbOrderNickName("PDA01")
		dbseek(xFilial("DA0")+cSemana)
		If Found()
			lUpdate := .T.
		Endif

		If lUpdate
			reclock("DA0",.F.)
			
			
		Else
			reclock("DA0",.T.)
		Endif
		*/
		reclock("DA0",.T.)
		DA0->DA0_FILIAL := 'MB'//xFilial("DA0")
		DA0->DA0_CODTAB := '999'//ORTA768T->DA0_CODTAB
		DA0->DA0_DESCRI := ORTA768T->DA0_DESCRI
		DA0->DA0_DATDE  := stod(ORTA768T->DA0_DATDE)
		DA0->DA0_DATATE := stod(ORTA768T->DA0_DATATE)
		DA0->DA0_HORADE := ORTA768T->DA0_HORADE
		DA0->DA0_HORATE := ORTA768T->DA0_HORATE
		DA0->DA0_TPHORA := ORTA768T->DA0_TPHORA
		DA0->DA0_ATIVO  := ORTA768T->DA0_ATIVO
		DA0->(MsUnlock())

		ORTA768T->(dbskip())
	EndDo

	// -------------------------------------------------------

	dbselectarea("DA1")
	dbOrderNickName("CDA14")
	dbseek(xFilial("DA1")+cSemana)
/*
	While !EOF() .And. DA1_FILIAL+DA1_CODTAB == xFilial("DA1")+cSemana
		dbSelectArea("DA1")
		RecLock("DA1",.F.)
		Delete
		msUnLock()
		dbSkip()
		Loop
	EndDo
	cSemana := substr(cSemana,02,02)

	While !EOF() .And. DA1_FILIAL+DA1_CODTAB == xFilial("DA1")+"Z"+cSemana
		dbSelectArea("DA1")
		RecLock("DA1",.F.)
		Delete
		msUnLock()
		dbSkip()
		Loop
	EndDo
*/
	// Seleciono a DA1 na empresa 03
	cQueryA1 := "SELECT * FROM SIGA.DA1030"+dbLink+" WHERE DA1_CODTAB LIKE '%"+cSemana+"%' AND D_E_L_E_T_ = ' ' AND DA1_FILIAL = '  ' AND ROWNUM < 500 ORDER BY DA1_CODTAB, DA1_ITEM "
	U_ORTQUERY(cQueryA1, "ORTA768T")

	Do  While  .f. .and. !ORTA768T->(EOF())
		reclock("DA1",.T.)
		DA1->DA1_FILIAL:= 'MB'//xFilial("DA1")
		DA1->DA1_ITEM  := ORTA768T->DA1_ITEM
		DA1->DA1_CODTAB:= '999'//ORTA768T->DA1_CODTAB
		DA1->DA1_CODPRO:= ORTA768T->DA1_CODPRO
		DA1->DA1_ATIVO := ORTA768T->DA1_ATIVO
		DA1->DA1_TPOPER:= ORTA768T->DA1_TPOPER
		DA1->DA1_QTDLOT:= ORTA768T->DA1_QTDLOT
		DA1->DA1_INDLOT:= ORTA768T->DA1_INDLOT
		DA1->DA1_MOEDA := ORTA768T->DA1_MOEDA
		DA1->DA1_XMARCS:= ORTA768T->DA1_XMARCS
		DA1->DA1_XMARPR:= ORTA768T->DA1_XMARPR //ALTERADO PARA TESTE DA MARFIL
		DA1->DA1_PERDES:= ORTA768T->DA1_PERDES //ALTERADO PARA TESTE DA MARFIL
		msunlock()
		ORTA768T->(dbskip())
	EndDo

	cQuery := " SELECT * "
	cQuery += " FROM SIGA.SG1030@db03 " 
	cQuery += " WHERE D_E_L_E_T_ = ' ' " 
	cQuery += " AND G1_FILIAL = '02' "
	cQuery += " AND G1_DTCRIA BETWEEN '"+cDtIni+"' AND  '"+cDtFin+"' " 
	cQuery += " ORDER BY G1_COD, G1_COMP "

	
	U_JobCInfo("ORTA768T.PRW", "cQuery: " + cQuery )

	cAlias := U_ORTQUERY(cQuery,"ORTP169G")

	Do While  !(cAlias)->(EOF())
		
		/*
		IF DBSEEK(XFILIAL("SG1")+(cAlias)->G1_COD+(cAlias)->G1_COMP)
			RecLock("SG1",.F.)
		ELSE
			RecLock("SG1",.T.)
		ENDIF
		*/
		RecLock("SG1",.T.)
		G1_FILIAL	:= 'MB'//xFilial("SG1")
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

	// Seleciono a SZV(SOBMEDIDA) na empresa 51
/*
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

	// Seleciono a DA1 na empresa 51
	cQueryA1 := "SELECT * FROM SIGA.SZV510"+dbLink+" WHERE ZV_TABELA = '"+cSemana+"' AND D_E_L_E_T_ = ' ' AND ZV_FILIAL = '  ' ORDER BY ZV_TABELA, ZV_GRUPO "
	U_ORTQUERY(cQueryA1, "ORTA768T")

	Do While  !ORTA768T->(EOF())
		RecLock("SZV",.T.)
		SZV->ZV_FILIAL	:= xFilial("SZV")
		SZV->ZV_GRUPO	:= ORTA768T->ZV_GRUPO
		SZV->ZV_TABELA	:= ORTA768T->ZV_TABELA
		SZV->ZV_CUSTO	:= ORTA768T->ZV_CUSTO
		SZV->ZV_VENDA	:= ORTA768T->ZV_VENDA
		SZV->ZV_VENAME	:= ORTA768T->ZV_VENAME
		MsUnLock()
		ORTA768T->(dbskip())
	EndDo
*/
Return


User Function ORTA768A()
	Local aPergs      := {}
	Local aRet        := {}
	Private cTitulo   := "Geracao Marfil"
	Private cCadastro := "Tabela Marfil"
	Private aRotina   := {}
	Private cString   := "DA1"
	Private cSemana   := ""
	Private bFiltraBrw := { || } //Determina a Expressao do Filtro

	aRotina := {{"Alterar"       ,"AxAltera"    ,0,1},;
		{"Detalha Custo" ,"U_ORTA768D"  ,0,1}}

	dbSelectArea("DA1")
	dbsetorder(1)

	If cEmpAnt <> "03"
		MsgBox("O Acesso a esta rotina é exclusivo da unidade 51", "Unidade Invalida", "INFO")
		Return
	Endif
	aAdd( aPergs ,{1,"Semana         :" ,U_ORTP169A(),"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .T.   })

	If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTR762" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
		Return
	EndIf

	cSemana  := PadL( MV_PAR01, 3, "0" )

	aIndex	:= {}
	cFiltro	:= "SubStr(DA1_CODTAB,2,2) = '"+SubStr(cSemana,2,2)+"' .And. SubStr(DA1_CODPRO,1,1) <> '0' .And. DA1_ATIVO = '1'" //Expressao do Filtro
	bFiltraBrw := { || FilBrowse("DA1",@aIndex,@cFiltro)} //Determina a Expressao do Filtro

	Eval( bFiltraBrw )  // Efetiva o Filtro antes da Chamada a mBrowse

	mBrowse( 6,1,22,75,"DA1")

EndFilBrw("DA1",@aIndex)

Return

User Function ORTA768D(lParam)
	Local aPergs      := {}
	Local aRet        := {}
	Private cTitulo   := "Detalha Custo"
	Private cSemana   := DA1->DA1_CODTAB
	Private cTipo     := ""
	Private cProduto  := Alltrim(DA1->DA1_CODPRO)
	Private dCusto    := DA1->DA1_DTUMOV
	Private lComp     := .F.
	Default lParam := .F.

	If lParam
		cProduto := space(10)
		aAdd( aPergs ,{1,"Produto        :" ,cProduto	 ,"@!"	,".T."	 ,'SB1' ,'.T.'                  , 80, .T.   })
		aAdd( aPergs ,{1,"Semana         :" ,U_ORTP169A(),"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .T.   })
		aAdd( aPergs ,{2,"Tipo de Produto:" ,'ACABADO'   ,{'ACABADO','SEMI-ACABADO e MATERIA-PRIMA'}      , 80, .F.,.F.})
		aAdd( aPergs ,{2,"Calculo        :" ,"Simulacao" ,{"Simulacao","Geracao"}                        , 80, .F.,.F.})

		//aAdd( aPergs ,{1,"Dta limite Custo:" ,dCusto	 ,"@d"		 ,'',,'.T.',80,.T.})

		If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTR768d" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
			Return
		EndIf

		cProduto := MV_PAR01
		cSemana  := PadL( MV_PAR02, 3, "0" )
		cTipo    := MV_PAR03
		cCalculo   := MV_PAR04
		If cTipo == 'ACABADO'
			lComp:= .F.
		Else
			lComp:= .T.
		Endif

	Endif

	U_ORTP169C(cProduto, 'Z'+SUBSTR(cSemana,2,2),lComp,.t.,0, cCalculo)

Return

User Function ORTA768Y(cTab)

	ORTA768Z(cTab)

Return

Static Function Confia(cCod,cDesc)
	Local lRet := .F.

	cQueryA1 := "SELECT * FROM SIGA.CONFZZM WHERE trim(CONF_COD) = '"+alltrim(cCod)+"' AND Trim(SUBSTR(CONF_DESC,1,25)) = '"+Alltrim(substr(cDesc,1,25))+"' AND D_E_L_E_T_ = ' '"
	U_ORTQUERY(cQueryA1, "OR768CF")

	Do While !OR768CF->(EOF())
		lRet:= .T.
		OR768CF->(dbskip())
	EndDo

Return lRet

/*/{Protheus.doc} ORTA768C
description
@type function
@version  
@author luciana.rosa
@since 3/17/2022
@return variant, return_description
/*/
User Function ORTA768C(cCodTab)

	Local oDlg
	Local cTitulo  := "Confirmação das Descricoes Divergentes"
	Local lMark    := .F.
	Local oOk      := LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
	Local oNo      := LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
	Local oChk1
	Local oChk2
	Local cQuery:= " "

	Private lChk1 := .F.
	Private lChk2 := .F.
	Private oLbx
	Private aVetor := {}

	If cEmpAnt <>"51" .And. cEmpAnt <> "03"
		Alert("Rotina só deve ser executada na Empresa 51!")
		Return
	EndIf

	cQuery :=" SELECT DISTINCT ZZM_COD AS PRODUTO, B1_DESC AS DESC_LOCAL, ZZM_DESC AS DESC_MATRIZ "
	cQuery +=" FROM SIGA.ZZM030 ZZM "
	cQuery +=" JOIN SIGA.SB1030 B1L ON B1L.B1_FILIAL = '  ' "
	cQuery +=" AND B1L.D_E_L_E_T_ = ' ' "
	cQuery +=" AND B1L.B1_COD = ZZM_COD "
	cQuery +=" WHERE ZZM.ZZM_FILIAL = '  ' "
	cQuery +=" AND ZZM.D_E_L_E_T_ = ' ' "
	cQuery +=" AND ZZM_CODTAB = '" + cCodTab + "'
	cQuery +=" AND ZZM_ANOTAB = '" +ALLTRIM( STR(YEAR(DdATAbASE))) + "'
//cQuery +=" AND ZZM_DATA >= '20210101' " 
	cQuery +=" AND B1_DESC <> ZZM_DESC "
	cQuery +=" AND NOT EXISTS (SELECT 'X' FROM SIGA.CONFZZM WHERE TRIM(CONF_COD) = TRIM(ZZM_COD) "
    cQuery +=" AND TRIM(CONF_DESC) = TRIM(ZZM_DESC) ) " 
	cQuery +=" ORDER BY ZZM_COD, ZZM_DESC "

	memowrite("C:\ListBoxMar.sql",cQuery)

// Verificar se a tabela esta aberta

	If Select("TEMP") > 0
		DbSelectArea( "TEMP")
		DbCloseArea()
	Endif

	TCQuery cQuery New Alias "TEMP"

	DBSelectArea("TEMP")
	TEMP->(DbGoTop())

//+-------------------------------------+
//| Carrega o vetor conforme a condicao |
//+-------------------------------------+
	While !TEMP->(EOF())
		aAdd( aVetor, { 	lMark, ;
			TEMP->PRODUTO, ;
			TEMP->DESC_LOCAL, ;
			TEMP->DESC_MATRIZ;
			})
		dbSkip()
	End

//+-----------------------------------------------+
//| Monta a tela para usuario visualizar consulta |
//+-----------------------------------------------+
	If Len( aVetor ) == 0
//		Aviso( cTitulo, "Nao existem produtos com descricoes divergentes.", {"Ok"} )
		Return
	Endif

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 420,700 PIXEL

	@ 10,10 LISTBOX oLbx FIELDS HEADER ;
		" ", "PRODUTO", "DESCRICAO LOCAL", "DESCRICAO MATRIZ" ;
		SIZE 340,180 OF oDlg PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1])

	oLbx:SetArray( aVetor )
	oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),;
		aVetor[oLbx:nAt,2],;
		aVetor[oLbx:nAt,3],;
		aVetor[oLbx:nAt,4];
		}}

	@ 195,10 CHECKBOX oChk1 VAR lChk1 PROMPT "Marca/Desmarca Todos" SIZE 70,7 PIXEL OF oDlg ;
		ON CLICK( aEval( aVetor, {|x| x[1] := lChk1 } ),oLbx:Refresh() )

	@ 195,95 CHECKBOX oChk2 VAR lChk2 PROMPT "Iverter a seleção" SIZE 70,7 PIXEL OF oDlg ;
		ON CLICK( aEval( aVetor, {|x| x[1] := !x[1] } ), oLbx:Refresh() )

	DEFINE SBUTTON FROM 195,213 TYPE 1 ACTION (fGIsert(aVetor),oDlg:End())  ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER

Return

Static Function fGIsert(aInsert)
	Local i
	Local _cConf:= ""

	If MsgYesNo("Confirma que as descricoes selecionadas são equivalentes e os custos devem ser importados na sincronizacao com a matriz? ")
		For i:=1 to len(aInsert)
			If aInsert[i][1]
				_cConf := "INSERT INTO SIGA.CONFZZM (CONF_COD,CONF_DESC,CONF_DATA) VALUES ('"+aInsert[i][2]+"','"+aInsert[i][4]+"','"+dtos(ddatabase)+"')"
				if TcSqlExec(_cConf) <> 0
					alert("erro ao registrar confirmacao.")
				Endif
			EndIf
		Next i
	Endif

Return

Static Function fStatusZZM( cCodTab )

	Local cQuery := ""
	Local lRet   := .F.


	cQuery := " SELECT  ZM.* " 
	cQuery += " FROM SIGA.ZZM030 ZM " 
	cQuery += " WHERE ZM.d_e_l_e_t_ = ' ' " 
	cQuery += "     AND ZZM_FILIAL = '  ' "
	cQuery += "     AND ZZM_CODTAB = '" + cCodTab + "' " 
	cQuery +="      AND ZZM_ANOTAB = '" +ALLTRIM( STR(YEAR(DdATAbASE))) + "'
	cQuery += "     AND ZZM_DATA = (SELECT MAX(ZZM_DATA) "
	cQuery += "              FROM  SIGA.ZZM030 ZZX "
	cQuery += "              WHERE ZZX.ZZM_FILIAL = ' ' "
	cQuery += "              AND ZZX.D_E_L_E_T_ = ' ' "
	cQuery += "              AND ZZX.ZZM_CODTAB  = '" +cCodTab+"' "
	cQuery += "              AND ZZX.ZZM_ANOTAB  = ZM.ZZM_ANOTAB "
	cQuery += "              AND ZZX.ZZM_COD = ZM.ZZM_COD) "

	cQuery+=" ORDER BY ZZM_COD, ZZM_DATA"

	U_ORTQUERY(cQuery, "OT768F")

	If OT768F->(EOF())

		Aviso("ORTA768","A tabela da semana não foi criada pela matriz!",{"OK"})
		lRet := .f.

	Else
	
		cQuery := " SELECT  ZM.* " 
		cQuery += " FROM SIGA.ZZM030 ZM " 
		cQuery += " WHERE ZM.d_e_l_e_t_ = ' ' " 
		cQuery += "     AND ZZM_FILIAL = '  ' "
		cQuery += "     AND ZZM_STATUS not in ( 'F', 'I') "
		cQuery += "     AND ZZM_CODTAB = '" + cCodTab + "' "
		cQuery += "     AND ZZM_ANOTAB = '" +ALLTRIM( STR(YEAR(DdATAbASE))) + "' 
		cQuery += "     AND ZZM_DATA = (SELECT MAX(ZZM_DATA) "
		cQuery += "              FROM  SIGA.ZZM030 ZZX "
		cQuery += "              WHERE ZZX.ZZM_FILIAL = ' ' "
		cQuery += "              AND ZZX.D_E_L_E_T_ = ' ' "
		cQuery += "              AND ZZX.ZZM_CODTAB  = '" +cCodTab+"' "
		cQuery += "              AND ZZX.ZZM_ANOTAB  = ZM.ZZM_ANOTAB "
		cQuery += "              AND ZZX.ZZM_COD = ZM.ZZM_COD) "

		cQuery+=" ORDER BY ZZM_COD, ZZM_DATA"

		U_ORTQUERY(cQuery, "OT768AB")

		If !OT768AB->(eof() )
			
			Aviso("ORTA768","A tabela da matriz encontra-se aberta. Solicite o fechamento da mesma e tente novamente.",{"OK"})
			lRet := .f.
		Else
					
			Aviso("ORTA768","A tabela da Matriz será importada!",{"OK"})
			lRet := .T.

		EndIf

	EndIf'

Return lRet 

User Function ORTA768R() 

Local cProduto 	:= space(10)

Private aPergs 	:= {}
Private cTitulo := 'Recalculo'
Private aRet 	:= {}

/*/{Protheus.doc} nomeFunction
	(long_description)
	@type  Function
	@author user
	@since 14/06/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

	aAdd( aPergs ,{1,"Semana         :" ,U_ORTP169A(),"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .T.   })
	aAdd( aPergs ,{2,"Congela Precos :" ,"Nao"       ,{"Nao","Sim","Selecionados"}                   , 80, .F.,.F.})
	aAdd( aPergs ,{2,"Tipo de Produto:" ,'ACABADO'   ,{'ACABADO','SEMI-ACABADO e MATERIA-PRIMA'}      , 80, .F.,.F.})
	aAdd( aPergs ,{2,"Calculo        :" ,"Simulacao" ,{"Simulacao","Geracao"}                        , 80, .F.,.F.})
	aAdd( aPergs ,{2,"Permite redução?:" ,"Nao"       ,{"Nao","Sim"}                   , 80, .F.,.F.})
	aAdd( aPergs ,{1,"Produto        :" , cProduto	 ,"@!"	,".T."	 ,'SB1' ,'.T.'                  , 80, .T.   })
	
	//aAdd( aPergs ,{1,"Dta limite Custo:" ,dCusto	 ,"@d"		 ,'',,'.T.',80,.T.})

	If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTR762" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
		Return
	EndIf

	cSemana  := PadL( MV_PAR01, 3, "0" )
	cCongela := MV_PAR02
	cTipo    := MV_PAR03
	cCalculo := MV_PAR04
	cReducao := MV_PAR05
	cProduto := MV_PAR06

	cQuery := " SELECT NVL(PRODUTOS, 'N') PROD FROM ( "
	cQuery += " SELECT LISTAGG(G1_COD, ''',''') WITHIN GROUP( ORDER BY G1_COD) PRODUTOS "
	cQuery += " FROM (SELECT DISTINCT G1_COD FROM SIGA.SG1030 " 
	cQuery += " WHERE D_E_L_E_T_ = ' ' " 
	cQuery += " AND G1_FILIAL = '02' "
	cQuery += " AND G1_COMP = '"+ cProduto +"' ) " 
	cQuery += " ORDER BY 1 )"

	cAlias := U_ORTQUERY(cQuery, "OT768US")

	If !(cAlias)->(EOF()) .and. (cAlias)->PROD <> 'N'

		u_fMarfil((cAlias)->PRODUTOS, "S")

	EndIf

	
    cQuery := " SELECT DISTINCT G1_COD FROM SIGA.SG1030 " 
	cQuery += " WHERE D_E_L_E_T_ = ' ' " 
	cQuery += " AND G1_FILIAL = '02' "
	cQuery += " AND G1_COD = '"+ cProduto +"'  " 
	cQuery += " ORDER BY 1  "

	cAlias := U_ORTQUERY(cQuery, "OT768A")

	if !(cAlias)->(EOF()) 

		u_fMarfil((cAlias)->G1_COD, "A")

	endIf
	
Return 


User Function impZZm768(cCodTab)
	Local cQuery  		:= ""
	Local lDelete 		:= .F.
	Local lInc    		:= .T.
	
	Private aArea := GetArea()

	//BEGIN TRANSACTION
	cQuery:="SELECT COUNT(*) AS CONTAR FROM SIGA.ZZM030 WHERE ZZM_FILIAL = '  ' and d_e_l_e_t_ = ' ' " 
	cAlias := U_ORTQUERY(cQuery, "OT768C")

	ProcRegua((cAlias)->CONTAR)

	cQuery := " SELECT ZZM_FILIAL, "
	cQuery += " ZZM_COD, "
	cQuery += " ZZM_DESC, "
	cQuery += " ZZM_DATA, "
	cQuery += " ZZM_PTAX, "
	cQuery += " ZZM_UM, "
	cQuery += " ZZM_PICM, "
	cQuery += " ZZM_SICM, "
	cQuery += " ZZM_VLRANT, "
	cQuery += " ZZM_PORC, "
	cQuery += " ZZM_IPI, "
	cQuery += " ZZM_VLRNOV, "
	cQuery += " ZZM_VLRUSD, "
	cQuery += " ZZM_TOTAL, "
	cQuery += " ZZM_IMPORT, "
	cQuery += " ZZM_CODTAB, "
	cQuery += " ZZM_DTFECH, "
	cQuery += " ZZM_STATUS, "
	cQuery += " ZZM_ANOTAB, "
	
	cQuery += " ZZM_JUSTIF, "
	cQuery += " R_E_C_N_O_, 'S' ZZM_MATRIZ, "
	cQuery += " ZM.d_e_l_e_t_ AS DELETADO " 
	cQuery += " FROM SIGA.ZZM030 ZM 
	cQuery += " WHERE ZZM_FILIAL = '  ' and d_e_l_e_t_ = ' ' 
	


	U_ORTQUERY(cQuery, "OT768X")

	Do While  !OT768X->(EOF()) 

		IncProc()

		If OT768X->DELETADO == "*"
			lDelete := .T.
		else
			lDelete := .F.
		Endif

			If RecLock("ZZM",lInc)
				ZZM->ZZM_FILIAL := XFILIAL("ZZM")
				ZZM->ZZM_COD    := OT768X->ZZM_COD
				ZZM->ZZM_DESC	:= OT768X->ZZM_DESC
				ZZM->ZZM_DATA	:= STOD(OT768X->ZZM_DATA)
				ZZM->ZZM_UM	    := OT768X->ZZM_UM
				ZZM->ZZM_PICM   := OT768X->ZZM_PICM
				ZZM->ZZM_SICM   := OT768X->ZZM_SICM
				ZZM->ZZM_VLRANT := OT768X->ZZM_VLRANT
				ZZM->ZZM_PORC   := OT768X->ZZM_PORC
				ZZM->ZZM_VLRNOV := OT768X->ZZM_VLRNOV
				ZZM->ZZM_IPI    := OT768X->ZZM_IPI
				ZZM->ZZM_TOTAL  := OT768X->ZZM_TOTAL
				ZZM->ZZM_IMPORT := OT768X->ZZM_IMPORT
				ZZM->ZZM_MATRIZ := OT768X->ZZM_MATRIZ
				ZZM->ZZM_XRECOR := OT768X->R_E_C_N_O_
				ZZM->ZZM_CODTAB := OT768X->ZZM_CODTAB
				ZZM->ZZM_VLRUSD := OT768X->ZZM_VLRUSD
				ZZM->ZZM_PTAX   := OT768X->ZZM_PTAX
				//ZZM->ZZM_DTFECH := date()
				ZZM->ZZM_ANOTAB := ALLTRIM(STR(OT768X->ZZM_ANO))
				
				ZZM->(MsUnLock())
			Endif
		//Endif
		OT768X->(dbskip())
	EndDo
	//END TRANSACTION

	restarea(aArea)
Return()
