#Include "Protheus.Ch"
#Include "TopConn.Ch"
#Include "RwMake.Ch"
#Include "SigaWin.Ch"
#include "colors.ch"
#include "font.ch"
#INCLUDE "JPEG.CH"
#INCLUDE "TBICONN.CH"
#include 'vkey.ch'
#include "ap5mail.ch"
#INCLUDE "EICCONST.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORTP115   º Autor ³ Márcio Sobreira    º Data ³  19/12/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravação do Custo dos Produtos 							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Estoque										              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

************************************************************************************************************
User Function ORTP115(cCodTab)
	************************************************************************************************************
	Local aPergs     	:= {}
	Local aRet       	:= {}
	
	Private cCadastro := "Custo dos Produtos"
	Private aRotina   := { 	{"Pesquisar"		 ,"AxPesqui"		,0,1} ,;
							{"Visualizar"		 ,"U_ORTP115T(2)"	,0,2} ,;
							{"Incluir"   		 ,"U_ORTP115C(3)"	,0,3} ,;
							{"Copia.Tabela.Ant." ,"U_ORTP115C(5)"	,0,3} ,;
							{"Ajustar/Atualizar" ,"U_ORTP115T(4)"	,0,4} ,;
							{"Exporta CSV."		 ,"U_ORTP115E()" 	,0,3} ,;
							{"Importar em Lote"	 ,"U_uImpZZMM() " 	,0,3} ,;
							{"Atualiza.Tx.Dolar" ,"U_ORTP115X()" 	,0,4} ,;
							{"Fechar tabela"     ,"U_ORTP115F()" 	,0,4} ,;
							{"Excluir"			 ,"AxDeleta"     	,0,5} }

	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private cTabela  := '000'	
	Private cAnotab		:= ALLTRIM(STR(YEAR(DDATABASE)))
	Private cRotina  := "ORTP115"
	Private cUnidade := cEmpAnt

	Default cCodTab	 := '000'

	Public cXXTaxa := 0

	If !(cEmpAnt $ "51") .And. !(cEmpAnt $ "03")
		Alert("Favor utilizar esta rotina na unidade 51 (TCP/ORTOBOM)")
		Return
	Endif

	If cCodTab == '000'
		aAdd( aPergs ,{1,"Tabela         :" ,cCodTab,"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .T.   })
		aAdd( aPergs ,{1,"Ao Tabela      :" ,cAnotab,"@!"	,".T."	 ,'' ,'.T.'                     , 80, .T.   })

		If !Parambox( aPergs, cCadastro, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTA768" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
			Return
		EndIf

		cCodTab  := PadL( MV_PAR01, 3, "0" )
		cAnotab  := MV_PAR02
	Endif

	cCodTab := PadL( cCodTab, 3, "0" )
	cTabela := cCodTab
	cXXTaxa := fBuscaTx(cTabela)

	If upper(alltrim(GetEnvServer())) == "ORTOBOM"
		U_ORTP115D(cCodTab)
	Endif
	/*
	dbselectarea("DA0")
	dbOrderNickName("PDA01")	
	If dbseek( xFilial("DA0") + cTabela)
		If ddatabase >= DA0->DA0_DATDE
			alert("Atenção, Esta tabela já está em vigencia. Recomenda-se não realizar alteraçoes de custo.")
		Endif
	Endif
    */                                                                                                               
	//cFilter := "ZZM_CODTAB = '"+cCodTab+"' AND ZZM_ANOTAB = '" + ALLTRIM(STR(YEAR(DDATABASE))) + "' "
	cFilter := "ZZM_CODTAB = '"+cCodTab+"' AND ZZM_ANOTAB = '" + cAnotab + "' "

	dbSelectArea("ZZM")
	dbSetOrder(1)

	mBrowse( 6,1,22,75,"ZZM",,,,,, ,,,,,,,,cFilter)

Return

	************************************************************************************************************
User Function ORTP115C(_nOpt)
	************************************************************************************************************
	// Copia
	If _nOpt == 5
		Processa( {|| cCopia() }, "Aguarde...", "Copiando Dados...",.F.)
	Else
		AxInclui('ZZM',ZZM->(RecNo()),_nOpt,,,,"U_fVlDCust()")
	Endif

Return

Static Function cCopia()
	Local aPergs     := {}
	Local aRet       := {}
	Local cQryC		 := ""
	Private cCadastro:= "Custo dos Produtos"
	Private cTabAnt  := '000'
	Private cTabNov  := '000'

	aAdd( aPergs ,{1,"Tabela Anterior:" ,cTabAnt,"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .T.   })
	aAdd( aPergs ,{1,"Tabela Atual   :" ,cTabNov,"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .T.   })

	If !Parambox( aPergs, cCadastro, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTA768" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
		Return
	EndIf

	cTabAnt  := PadL( MV_PAR01, 3, "0" )
	cTabNov  := PadL( MV_PAR02, 3, "0" )

	If (cTabNov == cTabAnt .OR. cTabAnt > cTabNov) .and. cAnotab >= ALLTRIM(STR(Year(dDataBase)))
		Alert("A tabela atual deve ser superior a tabela anterior.")
	Else
		If MsgYesNo("Confirma a copia dos custos da tabela: "+ cTabAnt +" para a tabela: " + cTabNov )

			//If !fExist(cTabAnt)
			//	Alert("Tabela Anterior nao encontrada.Não será realizada a copia.")
			//Endif

			If fExist(cTabNov)
				Alert("Ja existem custos registrados na tabela informada.Não será realizada a copia.")
			Else
				cQryC := "SELECT ZZM_COD,   "
				cQryC += "       ZZM_DESC,  "
				cQryC += "       ZZM_DATA,  "
				cQryC += "       ZZM_PTAX,  "
				cQryC += "       ZZM_UM,    "
				cQryC += "       ZZM_PICM,  "
				cQryC += "       ZZM_SICM,  "
				cQryC += "       ZZM_VLRANT,"
				cQryC += "       ZZM_PORC,  "
				cQryC += "       ZZM_VLRNOV,"
				cQryC += "       ZZM_IPI,   "
				cQryC += "       ZZM_TOTAL, "
				cQryC += "       ZZM_IMPORT,"
				cQryC += "       ZZM_VLRUSD,"
				cQryC += "       ZZM_ANOTAB, ZZM_JUSTIF, ZZM_MATRIZ    "
				cQryC += "  FROM SIGA." + RetSqlName("ZZM") + " ZZM "
				cQryC += " WHERE D_E_L_E_T_ = ' '
				cQryC += "   AND ZZM_FILIAL = '"+XFILIAL("ZZM")+"'
				cQryC += "   AND ZZM_CODTAB = '"+cTabAnt+"'
				//cQryC += "   AND ZZM_ANOTAB = '" + alltrim(str(Year(dDataBase))) + "' "
				cQryC += "   AND ZZM_ANOTAB = '" + cAnotab + "' "
				cQryC += "   AND ZZM_DATA = (SELECT MAX(ZZM_DATA) "
				cQryC += "              FROM  " + RetSqlName("ZZM") + " ZZX "
				cQryC += "              WHERE ZZX.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
				cQryC += "              AND ZZX.D_E_L_E_T_ = ' ' "
				cQryC += "              AND ZZX.ZZM_CODTAB  = '" +cTabAnt+"' "
				cQryC += "              AND ZZX.ZZM_COD = ZZM.ZZM_COD) "
				cQryC += "  AND ZZM_PICM = (SELECT MAX(ZZM_PICM) "
				cQryC += "              FROM  " + RetSqlName("ZZM") + " ZZX "
				cQryC += "              WHERE ZZX.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
				cQryC += "              AND ZZX.D_E_L_E_T_ = ' ' "
				cQryC += "              AND ZZX.ZZM_DATA = ZZM.ZZM_DATA "
				cQryC += "              AND ZZX.ZZM_CODTAB  = '" +cTabAnt+"' "
				cQryC += "              AND ZZX.ZZM_COD = ZZM.ZZM_COD) "
				cQryC += " ORDER BY ZZM_COD, ZZM_DATA DESC

				U_ORTQUERY(cQryC,"P115INS")

				While !P115INS->( Eof() )
					If RecLock("ZZM",.T.)
						ZZM->ZZM_FILIAL := XFILIAL("ZZM")
						ZZM->ZZM_COD    := P115INS->ZZM_COD
						ZZM->ZZM_DESC	:= P115INS->ZZM_DESC
						ZZM->ZZM_DATA	:= stod(P115INS->ZZM_DATA)
						ZZM->ZZM_PTAX	:= P115INS->ZZM_PTAX
						ZZM->ZZM_UM	    := P115INS->ZZM_UM
						ZZM->ZZM_PICM   := P115INS->ZZM_PICM
						ZZM->ZZM_SICM   := P115INS->ZZM_SICM
						ZZM->ZZM_VLRANT := P115INS->ZZM_VLRANT
						ZZM->ZZM_PORC   := P115INS->ZZM_PORC
						ZZM->ZZM_VLRNOV := P115INS->ZZM_VLRNOV
						ZZM->ZZM_IPI    := P115INS->ZZM_IPI
						ZZM->ZZM_TOTAL  := P115INS->ZZM_TOTAL
						//ZZM->ZZM_IMPORT := P115INS->ZZM_IMPORT
						ZZM->ZZM_VLRUSD := P115INS->ZZM_VLRUSD
						ZZM->ZZM_ANOTAB := ALLTRIM(STR(Year(dDataBase)))
						ZZM->ZZM_JUSTIF  := P115INS->ZZM_JUSTIF
						ZZM->ZZM_CODTAB := cTabNov
						ZZM->ZZM_MATRIZ := P115INS->ZZM_MATRIZ
						ZZM->(MsUnLock())
					Endif

					P115INS->(DbSkip())
				End
				MsgAlert("Cópia Realizada","Cópia")
			Endif
		Endif
	Endif

	u_ORTP115( cTabNov )
	CloseBrowse()
Return

	************************************************************************************************************
User Function fVlDCust
	************************************************************************************************************
	Local lRet := .T.

	cQry := " SELECT COUNT(*) AS TOTAL "
	cQry += " 	FROM "+RetSqlName("ZZM")
	cQry += " 	WHERE ZZM_FILIAL  = '" +xFilial("ZZM")+"' "
	cQry += " 	 AND  ZZM_COD     = '" +M->ZZM_COD    +"' "
	cQry += " 	 AND  ZZM_PICM    = '" +Alltrim(Str(M->ZZM_PICM))   +"' "
	cQry += " 	 AND  D_E_L_E_T_  = ' '"
	cQryC += "   AND  ZZM_MATRIZ  = 'S' "
	cQry += " 	 AND  ZZM_CODTAB  = '" +cTabela+"' "
	//cQry += " 	 AND  ZZM_ANOTAB  = '" + ALLTRIM(STR(YEAR(DDATABASE))) + "' "
	cQry += " 	 AND  ZZM_ANOTAB  = '" + cAnotab + "' "

	memowrit('C:\QUERYS\SOBREIRA\fVlDCust.sql',cQry)

	If Select("TDUPL") > 0
		("TDUPL")->( DbCloseArea() )
	EndIf

	TCQUERY cQry NEW ALIAS "TDUPL"

	IF TDUPL->TOTAL > 0
		lRet := .F.
		MsgAlert("Este produto já foi digitado com esta Alíquota de ICMS.Para alteracao, utilize a opcao de ajuste.","Registro Duplicado - Inclusão")
	EndIF

	TDUPL->(DBCLOSEAREA())

	If Empty(M->ZZM_CODTAB)
		lRet := .F.
		MsgAlert("O Codigo da Tabela da Semana é de preenchimento obrigatório.","Semana Invalida - Inclusão")
	Endif


Return lRet

	************************************************************************************************************
User Function ORTP115T(_nOpt)
	************************************************************************************************************
	Local cGDTudoOk
	Local nX
	Private _oPTAX , _nPTAX 	:= 0
	Private _oData , _dData 	:= DTOC(dDataBase)
	Private _oCodI , _cCodI 	:= SPACE(15)
	Private _oDescI , _cDescI 	:= SPACE(30)
	Private aGetAuxG    := {}
	Private aCpoGDG     := {} //{"PB1_CODPRO","Z6_PRCDIG"}     //aGetAux1
	Private aAlterG    	:= {}
	Private aVetorG	    := {}
	Private lTOK		:= .F.
	Private oDlgGr, oGetDGr
	Private _aDadosCus  := {}
	Private _aDadosTot  := {}
	Private aHeader     := {}
	Private aCols       := {}
	Private _lReset     := .T.
	Private _oTabela

	aGetAuxG    := {"D1_ITEM   ","ZZM_COD   ","ZZM_DESC  ","ZZM_DATA  ","ZZM_UM    ","ZZM_PICM  ","ZZM_SICM  ","ZZM_VLRANT","ZZM_PORC  ","ZZM_VLRNOV", "ZZM_VLRUSD" ,"ZZM_PTAX" , "ZZM_IPI   ","ZZM_TOTAL ","ZZM_JUSTIF"}
	aCpoGDG     := aGetAuxG //{"PB1_CODPRO","Z6_PRCDIG"}     //aGetAux1
	aAlterG    	:= {"ZZM_VLRNOV","ZZM_VLRUSD","ZZM_PICM  ","ZZM_SICM  ", "ZZM_IPI   ", "ZZM_JUSTIF", "ZZM_DESC"}


	DbSelectArea("SM2")
	dbOrderNickName("PSM21")
	DbSeek(DTOS(ddatabase-1))

	//_nPTAX := SM2->M2_MOEDA5 + (SM2->M2_MOEDA5 * 0.03)
	_nPTAX := 4.15

	If _nOpt == 2
		INCLUI := .F.
		ALTERA := .F.
	ElseIf _nOpt == 4
		INCLUI := .F.
		ALTERA := .T.

		If fBuscaST( cTabela ) == "F"

			If MsgYesNo("A tabela " + cTabela + " encontra-se fechada para manutenção. Deseja reabri-la? ")

				ProcSZMfEC("A")

			EndIf

		EndIf

	endif

	// Busca os produtos
	_aDadosCus := fBuscPrd(_nOpt)

	aHeader	:= {}
	aCols   := 	_aDadosCus

	For nX := 1 to Len(aCpoGDG)
		Aadd(aHeader,{ IIF(AllTrim(aCpoGDG[nX])$"D1_ITEM","Linha",AllTrim(X3Titulo())),;
			GetSx3Cache(aCpoGDG[nX],'X3_CAMPO')	  ,;
			GetSx3Cache(aCpoGDG[nX],'X3_PICTURE') ,;
			GetSx3Cache(aCpoGDG[nX],'X3_TAMANHO') ,;
			GetSx3Cache(aCpoGDG[nX],'X3_DECIMAL') ,;
			IIF(!AllTrim(aCpoGDG[nX])$"ZZM_VLRNOV/ZZM_VLRUSD/ZZM_JUSTIF/ZZM_TOTAL/ZZM_IPI/ZZM_SICM/ZZM_DESC",GetSx3Cache(aCpoGDG[nX],'X3_VALID'),"U_FORTP115()") ,;
			GetSx3Cache(aCpoGDG[nX],'X3_USADO')	  ,;
			GetSx3Cache(aCpoGDG[nX],'X3_TIPO')	  ,;
			GetSx3Cache(aCpoGDG[nX],'X3_F3')      ,;
			GetSx3Cache(aCpoGDG[nX],'X3_CONTEXT') ,;
			GetSx3Cache(aCpoGDG[nX],'X3_CBOX')	  ,;
			GetSx3Cache(aCpoGDG[nX],'X3_RELACAO')})
	Next nX

	if _nOpt == 2
		cMsg:= "Consulta Custo dos Produtos: "
	elseif _nOpt == 4
		cMsg:= "Ajuste Custo dos Produtos: "

	endif

	Define Font oFont14Grd Name "Arial" Size 0,-18 Bold
	Define Font oFontGrd   Name "Arial" Size 0,-12 Bold

	DEFINE MSDIALOG oDlgGr TITLE "Custo dos Produtos" FROM 000, 000  TO 495, 960 COLORS 0, 16777215 PIXEL

	@ 010,10 Say cMsg  Size 300,010 COLOR CLR_BLUE Font oFont14Grd PIXEL OF oDlgGr
	//@ 050,10 Say cProj Size 300,010 COLOR CLR_BLUE Font oFont14Grd PIXEL OF oDlgGr

	//@ 025,215 Say "Custo dos Produtos" Size 300,010 COLOR CLR_BLUE Font oFont14Grd PIXEL OF oDlgGr

	//@ 032, 010 SAY "Dólar PTAX + 3%" SIZE 050, 008 OF oDlgGr COLORS 0, 16777215 PIXEL
	//@ 032, 060 MSGET _oPTAX VAR _nPTAX SIZE 030, 008 WHEN .F. OF oDlgGr PICTURE "@E 999.9999" COLORS 0, 16777215 PIXEL
	@ 042, 010 SAY "Data Atu.:" SIZE 040, 011 OF oDlgGr COLORS 0, 16777215 PIXEL
	@ 042, 060 MSGET _oData VAR _dData SIZE 040, 008 WHEN .F. OF oDlgGr PICTURE "@!" COLORS 0, 16777215 PIXEL

	@ 057, 010 SAY "Tabela:" SIZE 040, 011 OF oDlgGr COLORS 0, 16777215 PIXEL
	@ 057, 060 MSGET _oTabela VAR cTabela SIZE 040, 008 WHEN .F. OF oDlgGr PICTURE "@!" COLORS 0, 16777215 PIXEL


/*
@ 230, 011 SAY "Período (Últimos 6 meses):" SIZE 090, 007 OF oDlgGr COLORS 0, 16777215 PIXEL
@ 230, 080 MSGET oDt1 VAR dDt1 WHEN .F. SIZE 040, 010 OF oDlgGr COLORS 0, 16777215 PIXEL
@ 230, 133 SAY "Ate" SIZE 010, 010 OF oDlgGr COLORS 0, 16777215 PIXEL
@ 230, 150 MSGET oDt2 VAR dDt2 WHEN .F. SIZE 040, 010 OF oDlgGr COLORS 0, 16777215 PIXEL
*/

//@ 100, 100 SAY Produtos PROMPT "Dados dos Produtos" Font oFnt1 SIZE 100, 011 OF oDlgGr COLORS CLR_BLUE PIXEL
//@ 100, 100 SAY Produtos PROMPT "Dados dos Produtos" Font oFnt1 SIZE 100, 011 OF oDlgGr COLORS CLR_BLUE PIXEL

	oGetDGr := MSGetDados():New(080,008,225,474,IIF(_nOpt <> 2,3,_nOpt),"U_OR115LOK","U_OR115TOK",,.F.,aAlterG,,,999999)

//@ 010, 095  TO  096, 088  OF oDlgGr COLOR 255,255,255  PIXEL
	@ 010, 180  TO  070, 181   OF oDlgGr COLOR 255,255,255  PIXEL
	@ 070, 008  TO  071, 510   OF oDlgGr COLOR 255,255,255  PIXEL

	cGDTudoOk	:= oGetDGr:cTudoOk

	@ 230,032 Say 'Cod.:' SIZE 040,12 OF oDlgGr COLORS 0, 16777215 PIXEL
	@ 230,052 MSGET _oCodI VAR _cCodI SIZE 050, 008 F3 "SB1" OF oDlgGr COLORS 0, 16777215 PIXEL
	@ 230,130 Say 'Desc.:' SIZE 040,12 OF oDlgGr COLORS 0, 16777215 PIXEL
	@ 230,155 MSGET _oDescI VAR _cDescI SIZE 100, 008 OF oDlgGr COLORS 0, 16777215 PIXEL
	@ 230,270 BUTTON oBtn PROMPT "Pesquisar" SIZE 040,11 PIXEL ACTION (PesqCod())
	//@ 230,320 BUTTON oBtn PROMPT "Resetar" SIZE 040,11 PIXEL ACTION (RestCod())

	@ 230, 400 BmpButton Type 01 Action(IF(&cGDTudoOk.(oGetDGr:oBrowse,),(ltOK := .T.,Close(oDlgGr)),.F.))
	@ 230, 440 BmpButton Type 02 Action(Close(oDlgGr))

	ACTIVATE MSDIALOG oDlgGr CENTERED

	If ltOK
		MsAguarde({|lFim| fProcDados(@lFim, _nOpt)},"Processamento","Aguarde a finalização do processamento...")
	Endif

Return

Static Function fProcDados(lFim, _nOpt)

// Grava aCols atual na Variavel de ARRAY para o Grupo
	Local _nPosIcm := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_PICM"   } )
	Local _nPosNov := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_VLRNOV" } )
//	Local _nPosImp := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_IMPORT" } )
	Local _nPosCod := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_COD"    } )
	Local _nPosDat := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_DATA"   } )

	Local _nPosDes := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_DESC"   } )
	Local _nPosUm  := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_UM"     } )
	Local _nPosSIc := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_SICM"   } )
	Local _nPosVan := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_VLRANT" } )
	//Local _nPosPor := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_PORC"   } )
	Local _nPosTot := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_TOTAL"  } )
	Local _nPosUsd := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_VLRUSD" } )
	Local _nPosIpi := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_IPI" } )
	Local _nPosTax := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_PTAX" } )
	Local _nPosJus := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_JUSTIF" } )

	Local _Nx	   := 1
	Local aCols    := _aDadosCus

	For _Nx := 1 to Len (aCols)
		If !aCols[_Nx,Len(aHeader)+1] .and. !Empty(aCols[_Nx,_nPosCod])
			_lInc   := .T.
			_lMudou := .F.
			DbSelectArea("ZZM")
			DbSetOrder(1)
			// Localiza registro atual e verifica mudança na Data já existente
			DbGoTop()

			If DbSeek(XFILIAL("ZZM")+aCols[_Nx,_nPosCod]+DTOS(aCols[_Nx,_nPosDat]))
				While !ZZM->(EOF()) .AND. ZZM->ZZM_COD == aCols[_Nx,_nPosCod] .and. ZZM->ZZM_DATA == aCols[_Nx,_nPosDat]
				//If 	ZZM->ZZM_CODTAB == cTabela  .AND. ZZM->ZZM_ANOTAB = ALLTRIM(STR(YEAR(DDATABASE)))  .and.  ;
				If 	ZZM->ZZM_CODTAB == cTabela  .AND. ZZM->ZZM_ANOTAB = cAnotab .and.  ;
							( ( ZZM->ZZM_VLRNOV <> aCols[_Nx,_nPosNov] ) .or. ;
							round( ZZM->ZZM_PICM, 2) <> round( aCols[_Nx,_nPosIcm], 2) .or. ;
							alltrim(ZZM->ZZM_JUSTIF )<> alltrim(aCols[_Nx,_nPosJus] ) .or. ;
							ALLTRIM(ZZM->ZZM_DESC) <> ALLTRIM(aCols[_Nx,_nPosDes]).or. ;
							round( ZZM->ZZM_IPI, 2)  <> round( aCols[_Nx,_nPosIpi], 2) .or. ;
							round( ZZM->ZZM_SICM, 4) <> round( aCols[_Nx,_nPosSIc], 4) )

				         /*
						 		                                                            alert(ZZM->ZZM_COD)
						If ZZM->ZZM_VLRNOV <> aCols[_Nx,_nPosNov] 
						                                           alert("ZZM->ZZM_VLRNOV <> aCols[_Nx,_nPosNov]" )
						                                           alert(ZZM->ZZM_VLRNOV  )
						                                           alert(aCols[_Nx,_nPosNov] )
						EndIf
						If ZZM->ZZM_PICM <> aCols[_Nx,_nPosIcm] 
						                                           alert("ZZM->ZZM_PICM <> aCols[_Nx,_nPosIcm] " )
						                                           alert(ZZM->ZZM_PICM  )
						                                           alert(aCols[_Nx,_nPosIcm] )


						EndIf
						If alltrim(ZZM->ZZM_JUSTIF )<> alltrim(aCols[_Nx,_nPosJus] ) 
						                                           alert("alltrim(ZZM->ZZM_JUSTIF )<> alltrim(aCols[_Nx,_nPosJus] ) " )
						                                           alert( ZZM->ZZM_JUSTIF )  
						                                           alert( aCols[_Nx,_nPosJus] )  

						EndIf
						
						If ZZM->ZZM_IPI <> aCols[_Nx,_nPosIpi] 
						                                           alert("ZZM->ZZM_IPI <> aCols[_Nx,_nPosIpi]" )
						                                           alert(ZZM->ZZM_IPI  )                      
						                                           alert(aCols[_Nx,_nPosIpi] )

						EndIf
						
						
						If ZZM->ZZM_SICM <> aCols[_Nx,_nPosSIc] 
						                                           alert("ZZM->ZZM_SICM <> aCols[_Nx,_nPosSIc]" )
						                                           alert(round(ZZM->ZZM_SICM, 4)  )
						                                           alert(round(aCols[_Nx,_nPosSIc] ,4))

						EndIf
						
						                               return
						*/
						_lMudou := .T.

						If aCols[_Nx,_nPosDat] == dDataBase
							_lInc := .F.
							exit
						EndIf

					Endif
					ZZM->(DbSkip())
				End
			Endif
            /*
			// Verifica se Registro já existe na Data de Hoje
			DbGoTop()
			If DbSeek(XFILIAL("ZZM")+aCols[_Nx,_nPosCod]+DTOS(dDataBase))
				While !ZZM->(EOF()) .and. ZZM->ZZM_COD == aCols[_Nx,_nPosCod] .and. ZZM->ZZM_DATA == aCols[_Nx,_nPosDat]
					If ZZM->ZZM_CODTAB  == cTabela  .and. ZZM->ZZM_PICM == aCols[_Nx,_nPosIcm] .and. ZZM->ZZM_VLRNOV == aCols[_Nx,_nPosNov] .and.  alltrim(ZZM->ZZM_JUSTIF ) == alltrim(aCols[_Nx,_nPosJus] )
				   		_lInc := .F.
					  	Exit
					Endif
					ZZM->(DbSkip())
				End
			Endif
			*/                       
			If _lMudou
				If RecLock("ZZM",_lInc)
					ZZM->ZZM_FILIAL := XFILIAL("ZZM")
					ZZM->ZZM_COD    := aCols[_Nx,_nPosCod]
					ZZM->ZZM_DESC	:= aCols[_Nx,_nPosDes]
					ZZM->ZZM_DATA	:= CTOD(_dData)
					ZZM->ZZM_UM	    := aCols[_Nx,_nPosUm]
					ZZM->ZZM_PICM   := aCols[_Nx,_nPosIcm]
					ZZM->ZZM_SICM   := aCols[_Nx,_nPosSIc]
					ZZM->ZZM_VLRANT := aCols[_Nx,_nPosVan]
					ZZM->ZZM_PORC   := aCols[_Nx,9]
					ZZM->ZZM_VLRNOV := aCols[_Nx,_nPosNov]
					ZZM->ZZM_IPI    := aCols[_Nx,_nPosIpi]
					ZZM->ZZM_TOTAL  := aCols[_Nx,_nPosTot]
//					ZZM->ZZM_IMPORT := aCols[_Nx,_nPosImp]
					ZZM->ZZM_VLRUSD := aCols[_Nx,_nPosUsd]
					ZZM->ZZM_PTAX   := aCols[_Nx,_nPosTax]
					ZZM->ZZM_JUSTIF := aCols[_Nx,_nPosJus]
					ZZM->ZZM_ANOTAB := ALLTRIM(STR(Year(dDataBase)))
					ZZM->ZZM_MATRIZ := IIF(cUserName == 'rg.kmineiro' , "N", 'S')
					ZZM->ZZM_STATUS := IIF(cUserName == 'rg.kmineiro' , "I", '')
					ZZM->ZZM_CODTAB := cTabela
					ZZM->(MsUnLock())

				Endif

			Endif

		Endif
	Next
// Retorna dados do aCols anterior
//aHeader	:= aHeaderBkp
//aCols	:= aColsBkp
//n		:= nPosBkp

Return

	********************************************************************************************************************
User Function OR115LOK
	********************************************************************************************************************
	Local _nPosprc := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_VLRNOV" } )
	Local _nPosAnt := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_VLRANT" } )
	//Local _nPosJus := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_JUSTIF" } )
	Local _lRet    := .T.

	If aCols[n,_nPosPrc] <= 0 .and. !aCols[n,Len(aHeader)+1] .and. aCols[n,_nPosAnt] <> 0
		Aviso( "Atenção", "Custo Novo não pode ser zero na linha ["+Alltrim(Str(n))+"]!", { "Ok" } )
		_lRet    := .F.
	Endif

Return(_lRet)

	********************************************************************************************************************
User Function OR115TOK
	********************************************************************************************************************
	Local _nPosprc := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_VLRNOV" } )
	Local _nPosAnt := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_VLRANT" } )
	Local _nPosJus := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_JUSTIF" } )
	Local _nPosCod := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_COD" } )

	Local _lRet    := .T.
	Local _Nx

	For _Nx := 1 to Len (aCols)
		If !aCols[_Nx,Len(aHeader)+1]
			If aCols[_Nx,_nPosPrc] <= 0 .and. aCols[_Nx,_nPosAnt] <> 0
				Aviso( "Atenção", "Custo Novo não pode ser zero na linha ["+Alltrim(Str(_Nx))+"]!", { "Ok" } )
				_lRet    := .F.
				Exit
			Endif
		Endif
	Next

	If !(cUserName == 'rg.kmineiro')

		For _Nx := 1 to Len (aCols)
			If !aCols[_Nx,Len(aHeader)+1]
				If aCols[_Nx,_nPosPrc] > aCols[_Nx,_nPosAnt] .and. Empty(aCols[_Nx,_nPosJus] )
					Aviso( "Atenção", "O valor novo do produto " + aCols[_Nx,_nPosCod] + " é maior que o valor anterior, favor preencha a justificativa!", { "Ok" } )
					_lRet    := .F.
					Exit
				Endif
			Endif
		Next

	EndIf

Return(_lRet)

	********************************************************************************************************************
Static Function fBuscPrd(_nOpt)
	********************************************************************************************************************
	Local cQuery := ""
	Local _aRet  := {}

/*
cQuery := " SELECT SB1.B1_COD,  "
cQuery += "        SB1.B1_DESC, "
cQuery += "        SB1.B1_UM,   "
cQuery += "        MAX(SB1.B1_PICM) B1_PICM, "
cQuery += "        SB1.B1_XCUSMED, "
cQuery += "        SB1.B1_IPI, "

cQuery += "        (SELECT MAX(ZZM_DATA) ZZM_DATA "
cQuery += "                FROM " + RetSqlName("ZZM") + " ZZM "
cQuery += "                WHERE ZZM.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
cQuery += "                AND ZZM.D_E_L_E_T_ = ' ' "
cQuery += "                AND ROWNUM = 1 "
cQuery += "                AND ZZM.ZZM_COD = SB1.B1_COD) ZZM_DATA, "

cQuery += "        (SELECT ZZM_VLRNOV "
cQuery += "                FROM " + RetSqlName("ZZM") + " ZZM "
cQuery += "                WHERE ZZM.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
cQuery += "                AND ZZM.D_E_L_E_T_ = ' ' "
cQuery += "                AND ZZM.ZZM_COD = SB1.B1_COD "
cQuery += "                AND ROWNUM = 1 "
cQuery += "                AND ZZM.ZZM_DATA = (SELECT MAX(ZZM_DATA) ZZM_DATA "
cQuery += "                                    FROM " + RetSqlName("ZZM") + " ZZM "
cQuery += "                                    WHERE ZZM.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
cQuery += "                                    AND ZZM.D_E_L_E_T_ = ' ' "
cQuery += "                                    AND ZZM.ZZM_COD = SB1.B1_COD)) ZZM_VLRNOV, "

cQuery += "        (SELECT ZZM_IMPORT "
cQuery += "                FROM " + RetSqlName("ZZM") + " ZZM "
cQuery += "                WHERE ZZM.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
cQuery += "                AND ZZM.D_E_L_E_T_ = ' ' "
cQuery += "                AND ZZM.ZZM_COD = SB1.B1_COD "
cQuery += "                AND ROWNUM = 1 "
cQuery += "                AND ZZM.ZZM_DATA = (SELECT MAX(ZZM_DATA) ZZM_DATA "
cQuery += "                                    FROM " + RetSqlName("ZZM") + " ZZM "
cQuery += "                                    WHERE ZZM.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
cQuery += "                                    AND ZZM.D_E_L_E_T_ = ' ' "
cQuery += "                                    AND ZZM.ZZM_COD = SB1.B1_COD)) ZZM_IMPORT "

cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' "
cQuery += " AND SB1.B1_FILIAL = '"+XFILIAL("SB1")+"' "
cQuery += " AND SB1.B1_PICM <> 0 "
//cQuery += " AND SB1.B1_TIPO = 'MP' "
cQuery += " GROUP BY SB1.B1_COD, SB1.B1_DESC, SB1.B1_UM, SB1.B1_PICM, SB1.B1_XCUSMED, SB1.B1_IPI "
cQuery += " ORDER BY SB1.B1_COD "
*/

	cQuery := " SELECT ZZM_COD,  "
	cQuery += "        ZZM_DESC, "
	cQuery += "        ZZM_DATA, "
	cQuery += "        ZZM_PTAX, "
	cQuery += "        ZZM_UM, "
	cQuery += "        ZZM_PICM, "
	cQuery += "        ZZM_SICM, "
	cQuery += "        ZZM_VLRANT, "
	cQuery += "        ZZM_PORC, "
	cQuery += "        ZZM_VLRNOV, "
	cQuery += "        ZZM_IPI, "
	cQuery += "        ZZM_TOTAL, "
	cQuery += "        ZZM_IMPORT, "
	cQuery += "        ZZM_VLRUSD, "
	cQuery += "        ZZM_JUSTIF "
	cQuery += " FROM " + RetSqlName("ZZM") + " ZZM "
	cQuery += " WHERE ZZM.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
	cQuery += " AND ZZM.D_E_L_E_T_ = ' ' "
	cQuery += " AND ZZM_CODTAB  = '" +cTabela+"' "

	If cUserName == 'rg.kmineiro'

		cQuery += " AND ZZM_MATRIZ  <> 'S' "

	Else

		cQuery += " AND ZZM_MATRIZ  = 'S' "

	EndIf
	cQuery += " AND  ZZM_ANOTAB = '" + cAnotab + "' "
	cQuery += " AND ZZM_DATA = (SELECT MAX(ZZM_DATA) "
	cQuery += "              FROM  " + RetSqlName("ZZM") + " ZZX "
	cQuery += "              WHERE ZZX.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
	cQuery += "              AND ZZX.D_E_L_E_T_ = ' ' "
	cQuery += "              AND ZZX.ZZM_CODTAB  = '" +cTabela+"' "
	cQuery += "              AND ZZX.ZZM_COD = ZZM.ZZM_COD) "
	cQuery += " AND ZZM_PICM = (SELECT MAX(ZZM_PICM) "
	cQuery += "              FROM  " + RetSqlName("ZZM") + " ZZX "
	cQuery += "              WHERE ZZX.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
	cQuery += "              AND ZZX.D_E_L_E_T_ = ' ' "
	cQuery += "              AND ZZX.ZZM_DATA = ZZM.ZZM_DATA "
	cQuery += "              AND ZZX.ZZM_CODTAB  = '" +cTabela+"' "
	cQuery += "              AND ZZX.ZZM_COD = ZZM.ZZM_COD) "
	cQuery += " GROUP BY ZZM_COD, "
	cQuery += "        ZZM_DESC, "
	cQuery += "        ZZM_DATA, "
	cQuery += "        ZZM_PTAX, "
	cQuery += "        ZZM_UM, "
	cQuery += "        ZZM_PICM, "
	cQuery += "        ZZM_SICM, "
	cQuery += "        ZZM_VLRANT, "
	cQuery += "        ZZM_PORC, "
	cQuery += "        ZZM_VLRNOV, "
	cQuery += "        ZZM_IPI, "
	cQuery += "        ZZM_TOTAL, "
	cQuery += "        ZZM_IMPORT, "
	cQuery += "        ZZM_VLRUSD, ZZM_JUSTIF "
	cQuery += "        ORDER BY ZZM_COD "

	U_ORTQUERY(cQuery,"TMP","ORTP115.sql")

	_nCont := 0
	While !TMP->( Eof() )

		_nCont++
		//_lImp    := IIF(TMP->ZZM_IMPORT == "S",.T.,.F.)
		_nVlrNov := TMP->ZZM_VLRNOV
		_nSICM   := _nVlrNov - ((_nVlrNov  * TMP->ZZM_PICM) / 100)
		_nVlrIPi := (_nVlrNov * TMP->ZZM_IPI) / 100
		_nTotal  := _nVlrNov + _nVlrIpi

		AADD(_aRet,{STRZERO(_nCont,4), ;
			TMP->ZZM_COD, ;
			TMP->ZZM_DESC, ;
			STOD(TMP->ZZM_DATA), ;
			TMP->ZZM_UM, ;
			TMP->ZZM_PICM, ;
			TMP->ZZM_SICM   , ;
			_nVlrNov, ;
			0, ;
			_nVlrNov, ;
			TMP->ZZM_VLRUSD,;
			TMP->ZZM_PTAX, ;
			TMP->ZZM_IPI, ;
			TMP->ZZM_TOTAL,;//_nTotal,;
			TMP->ZZM_JUSTIF,;
			.F.})

		TMP->(DbSkip())
	End

Return(_aRet)


	********************************************************************************************************************
User Function FORTP115
	********************************************************************************************************************
	Local _nPosIcm  := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_PICM" } )
	Local _nPosSicm := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_SICM" } )
	Local _nPosAnt  := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_VLRANT" } )
	Local _nPosPorc := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_PORC" } )
	Local _nPosIpi  := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_IPI" } )
	Local _nPosTot  := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_TOTAL" } )
	Local _nPosItm  := aScan( aHeader, { |x| AllTrim ( x[2] ) == "D1_ITEM" } )
	Local _nPosUsd  := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_VLRUSD" } )
	Local _Ny
	Local _nPosNov  := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_VLRNOV" } )
//	Local _nPosImp  := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_IMPORT" } )   
	Local _nPosTx   := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_PTAX" } )
	Local _nPosJus  := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_JUSTIF" } )
	Local _nPosDes  := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_DESC" } )

	//dolar
	If "ZZM_VLRUSD" $ AllTrim(ReadVar())
		If M->ZZM_VLRUSD <> 0

			_nVlrNov := round(M->ZZM_VLRUSD * aCols[n,_nPosTx], 4)
			aCols[n,_nPosNov] := _nVlrNov
			aCols[n,_nPosSicm]  := _nVlrNov - ((_nVlrNov  * aCols[n,_nPosIcm]) / 100)
			_nVlrIPi := (_nVlrNov * aCols[n,_nPosIpi]) / 100
			aCols[n,_nPosPorc]  := (100 - ((_nVlrNov / aCols[n,_nPosAnt]) * 100)) * -1
			aCols[n,_nPosTot]   := _nVlrNov + _nVlrIpi

		EndIf
	Endif

	If "ZZM_VLRNOV" $ AllTrim(ReadVar())
		//		aCols[n,_nPosUsd] := 0
		_nVlrNov := M->ZZM_VLRNOV
		aCols[n,_nPosSicm]  := _nVlrNov - ((_nVlrNov  * aCols[n,_nPosIcm]) / 100)
		_nVlrIPi := (_nVlrNov * aCols[n,_nPosIpi]) / 100
		aCols[n,_nPosPorc]  := (100 - ((_nVlrNov / aCols[n,_nPosAnt]) * 100)) * -1
		aCols[n,_nPosTot]   := _nVlrNov + _nVlrIpi
	Endif

	_nPos := aScan(_aDadosCus, { |x| AllTrim ( x[1] ) == aCols[n,_nPosItm] } )
	For _Ny := 1 to Len(aheader)+1
		If "ZZM_VLRNOV" $ AllTrim(ReadVar()) .and. _Ny == _nPosNov
			_aDadosCus[_nPos,_Ny] := M->ZZM_VLRNOV
			_aDadosCus[_nPos,_Ny] := ((M->ZZM_VLRNOV * _aDadosCus[_nPos,_nPosIpi]) / 100 ) + M->ZZM_VLRNOV
			//ElseIf "ZZM_IMPORT" $ AllTrim(ReadVar()) .and. _Ny == _nPosImp
			//	_aDadosCus[_nPos,_Ny] := M->ZZM_IMPORT
		ElseIf "ZZM_VLRUSD" $ AllTrim(ReadVar()) .and. _Ny == _nPosUsd
			_aDadosCus[_nPos,_Ny] := M->ZZM_VLRUSD
		ElseIf "ZZM_JUSTIF" $ AllTrim(ReadVar()) .and. _Ny == _nPosJus
			_aDadosCus[_nPos,_Ny] := M->ZZM_JUSTIF
		ElseIf "ZZM_DESC" $ AllTrim(ReadVar()) .and. _Ny == _nPosDes
			_aDadosCus[_nPos,_Ny] := M->ZZM_DESC

		ElseIf "ZZM_IPI" $ AllTrim(ReadVar()) .and. _Ny == _nPosIpi
			_aDadosCus[_nPos,_Ny] := M->ZZM_IPI
			aCols[n,_nPosPorc]  := (100 - ((ZZM->ZZM_VLRNOV / aCols[n,_nPosAnt]) * 100)) * -1
			aCols[n,_nPosTot]   := ZZM->ZZM_VLRNOV + M->ZZM_IPI
		ElseIf "ZZM_SICM" $ AllTrim(ReadVar()) .and. _Ny == _nPosSicm
			_aDadosCus[_nPos,_Ny] := M->ZZM_SICM
		ElseIf "ZZM_PICM" $ AllTrim(ReadVar()) .and. _Ny == _nPosIcm
			_aDadosCus[_nPos,_Ny] := M->ZZM_PICM
		ElseIf "ZZM_TOTAL" $ AllTrim(ReadVar()) .and. _Ny == _nPosTot
			_aDadosCus[_nPos,_Ny] := M->ZZM_TOTAL
		Else
			_aDadosCus[_nPos,_Ny] := aCols[n,_Ny]
		Endif
	Next

	oGetDGr:Refresh()
	oDlgGr:Refresh()

Return(.T.)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function PesqCod()
	Local _nPosCod := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_COD" } )
	Local _nPosDes := aScan( aHeader, { |x| AllTrim ( x[2] ) == "ZZM_DESC" } )
	Local _Nx, _Ny

	If !Empty(_cCodI) .or. !Empty(_cDescI)
		If !Empty(_cCodI)
			_aDadTemp := {}
			For _Nx := 1 to len(_aDadosCus)
				If Alltrim(_cCodI) $ _aDadosCus[_Nx,_nPosCod]
					AADD(_aDadTemp,ARRAY(Len(aHeader)+1))
					For _Ny := 1 to Len(aheader)+1
						_aDadTemp[Len(_aDadTemp),_Ny] := _aDadosCus[_Nx,_Ny]

					Next
				Endif
			Next
		Endif
		If Empty(_cCodI) .and. !Empty(_cDescI)
			_aDadTemp := {}
			For _Nx := 1 to len(_aDadosCus)
				If UPPER(Alltrim(_cDescI)) $ UPPER(_aDadosCus[_Nx,_nPosDes])
					AADD(_aDadTemp,ARRAY(Len(aHeader)+1))
					For _Ny := 1 to Len(aheader)+1
						_aDadTemp[Len(_aDadTemp),_Ny] := _aDadosCus[_Nx,_Ny]
					Next
				Endif
			Next
		Endif
	Endif

	_lReset     := .F.
	aCols := _aDadTemp
	oGetDGr:Refresh()
	oDlgGr:Refresh()

Return

/*
Static Function RestCod()
	aCols := _aDadosCus
	oGetDGr:Refresh()
	oDlgGr:Refresh()
	_lReset     := .T.
Return
*/
	*'Importação .CSV ------------------------------------------------------------------------------------------------'*
	********************************************************************************************************************
User Function ORTP115I
	********************************************************************************************************************
	Private oLeTxt
	Private cArqTxt  := ""
	Private _aDadosx := {}
	Private aRet	 := {}

	dbSelectArea("SD3")
	dbSetOrder(1)

	@ 200,1 TO 380,380 DIALOG oLeTxt TITLE OemToAnsi("Leitura de Arquivo Texto")
	@ 02,07 TO 090,190

	@ 10,018 Say " Este programa ira ler o conteudo de um arquivo texto, conforme"
	@ 18,018 Say " Layout definido e carregar novo Custo.                        "

	@ 70,090 BMPBUTTON TYPE 04 ACTION SelArq()
	@ 70,128 BMPBUTTON TYPE 01 ACTION OkLeTxt()
	@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)

	Activate Dialog oLeTxt Centered

	Alert("Processo Encerrado!")

Return

	********************************************************************************************************************
Static Function SelArq()
	********************************************************************************************************************
	Local aRet	   := {}

//	cArqTxt := cGetFile("Pasta de Arqs de Importação |SigCRP*.TXT.","Selecione o Arquivo",,"SERVIDOR\Importa_Arq\")

	If ParamBox( {	{ 6,"Arquivo Origem",SPACE(10),,,"", 80 ,.T.,"Arquivo .csv *.csv |*.csv"} },"Arquivo",@aRet)
		cArqTxt    := aRet[1]
	Else
		Return()
	EndIf

	If AllTrim(cArqTxt) == ""
		Alert("Não foi selecionado nenhum arquivo.")
		Return()
	EndIf

Return

	********************************************************************************************************************
Static Function OkLeTxt
	********************************************************************************************************************
	Private cEOL    := "CHR(13)+CHR(10)"
	Private aItem   := {}

	MsgAlert("Rotina descontinuada")
Return

	If Empty(cArqTxt)
		MsgAlert("Nenhum arquivo selecionado")
		Return
	Endif

	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	If !File(cArqTXT)
		MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser aberto! Verifique os parametros.","Atencao!")
		Return
	Endif

	RunCont()

Return

	********************************************************************************************************************
Static Function RunCont
	********************************************************************************************************************
	PRIVATE lMSHelpAuto := .f. // para nao mostrar os erro na tela
	PRIVATE lMSErroAuto := .f. // inicializa como falso, se voltar verdadeiro e' que deu erro
	PRIVATE _aParcelas := {"1","2","3","4","5","6","7","8","9","A","B","C"}

	_xFilAnt := cFilAnt

// Processa a Inclusão de Fornecedores
	Processa({|| ORTP115P() },"Processando...")

	fImpCust(_aDadosx)

	Close(oLeTxt)

	cFilAnt := _xFilAnt

Return
/*
********************************************************************************************************************
Static Function fDescr(_cDescricao)
********************************************************************************************************************
Local _cRet  := ""
Local _nI
Local _cChar := "0123456789"
	For _nI := 1 To Len(_cDescricao)
		If Substr(_cDescricao,_nI,1) $ _cChar
		_cRet += Substr(_cDescricao,_nI,1)
		Endif
	Next
Return(_cRet)
*/
	********************************************************************************************************************
Static Function ORTP115P()
	********************************************************************************************************************
	Local _Nx
// cria arquivo temporario
	_aStruTRA := {{"TEXTO","C",500,0}}
	_cArqB    := FWTemporaryTable():New( "TRA", _aStruTRA )
	If Select("TRA") > 0
		TRA->(DbCloseArea())
	Endif
	dbSelectArea("TRA")
	dbGoTop()

// Fornecedor
	If !File(cArqTXT)
		MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser aberto! Verifique os parametros.","Atencao!")
		Return
	Endif

	APPEND FROM &cArqTXT SDF
	ProcRegua(TRA->(RecCount()))
	TRA->(DbGoTop())

	WHILE !TRA->(EOF())

		cBuffer  := Alltrim(TRA->TEXTO)
		_cTexto := ""
		_aDados := {}

		// incremente regua
		IncProc("Registros com valores...")

		// Processa os Dados em Array
		For _Nx := 1 to len(cBuffer)
			If SUBSTR(cBuffer,_Nx,1) == ";"
				AADD(_aDados,_cTexto)
				_cTexto := ""
				Loop
			Endif

			_cTexto += SUBSTR(cBuffer,_Nx,1)

		Next
		AADD(_aDados,_cTexto)

		c_campo1 := Alltrim(_aDados[1])	 // Cod

		If !Empty(c_campo1) .and. LEFT(c_campo1,1) == "0"
			c_campo2 := LEFT(Alltrim(_aDados[2]),30)	 // Descrição
			c_campo3 := CTOD(Alltrim(_aDados[3]))	 // Data Atu.
			c_campo4 := Alltrim(_aDados[4])	 // UM
			c_campo5 := Val(Alltrim(_aDados[5]))	 // Aliquota ICMS
			c_campo6t:= strtran(Alltrim(_aDados[6]),".","")
			c_campo6 := Val(strtran(Alltrim(c_campo6t),",","."))	 // Sem ICMS
			c_campo7t:= strtran(Alltrim(_aDados[7]),".","")
			c_campo7 := Val(strtran(Alltrim(c_campo7t),",","."))	 // Valor Antigo
			c_campo9t:= strtran(Alltrim(_aDados[9]),".","")
			c_campo9 := Val(strtran(Alltrim(c_campo9t),",","."))	 // Valor Novo
			c_campo8 := (100 - ((c_campo9 / c_campo7) * 100)) * -1 //Alltrim(_aDados[8])	 // Porcentagem
			c_campo10:= Val(Alltrim(_aDados[10])) // IPI
			c_campo11t:= strtran(Alltrim(_aDados[11]),".","")
			c_campo11:= Val(strtran(Alltrim(c_campo11t),",","."))    // Total

			AADD(_aDadosx,{c_campo1,c_campo2,c_campo3,c_campo4,c_campo5,c_campo6,c_campo7,c_campo8,c_campo9,c_campo10,c_campo11})
		Endif

		TRA->(DbSkip())
	End

	TRA->(DbCloseArea())

Return

	********************************************************************************************************************
Static Function fImpCust(_aDadosx)
	********************************************************************************************************************
	Local _Nx
	For _Nx := 1 to Len(_aDadosx)

		DbSelectArea("ZZM")
		DbSetOrder(1)
		DbGoTop()
		If !DbSeek(XFILIAL("ZZM")+_aDadosx[_Nx,1]+DTOS(_aDadosx[_Nx,3]))
			_lInc := .T.
		Endif

		If RecLock("ZZM",_lInc)
			ZZM->ZZM_FILIAL := XFILIAL("ZZM")
			ZZM->ZZM_COD    := _aDadosx[_Nx,1]
			ZZM->ZZM_DESC	:= _aDadosx[_Nx,2]
			ZZM->ZZM_DATA	:= _aDadosx[_Nx,3]
			ZZM->ZZM_UM	    := _aDadosx[_Nx,4]
			ZZM->ZZM_PICM   := _aDadosx[_Nx,5]
			ZZM->ZZM_SICM   := _aDadosx[_Nx,6]
			ZZM->ZZM_VLRANT := _aDadosx[_Nx,7]
			ZZM->ZZM_PORC   := _aDadosx[_Nx,8]
			ZZM->ZZM_VLRNOV := _aDadosx[_Nx,9]
			ZZM->ZZM_IPI    := _aDadosx[_Nx,10]
			ZZM->ZZM_TOTAL  := _aDadosx[_Nx,11]
			ZZM->ZZM_JUSTIF := _aDadosx[_Nx,12]
			ZZM->ZZM_IMPORT := "S"
			ZZM->ZZM_MATRIZ := "S"

			ZZM->(MsUnLock())
		Endif

	Next

Return
	*'Importação .CSV ------------------------------------------------------------------------------------------------'*


/*/{Protheus.doc} ORTP115D
description
@type function
@version  
@author luciana.rosa
@since 3/17/2022
@return variant, return_description
/*/
User Function ORTP115D(cCodTab)

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

	If cEmpAnt <>"03"
		Alert("Rotina só deve ser executada na Empresa 03!")
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
	cQuery +=" AND ZZM_ANOTAB = '" + cAnotab + "' "
	cQuery +=" AND B1_DESC <> ZZM_DESC "
	cQuery +=" AND NOT EXISTS (SELECT 'X' FROM SIGA.CONFZZM WHERE TRIM(CONF_COD) = TRIM(ZZM_COD) "
	cQuery += " AND ZZM_DATA = (SELECT MAX(ZZM_DATA) "
	cQuery += "              FROM  " + RetSqlName("ZZM") + " ZZX "
	cQuery += "              WHERE ZZX.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
	cQuery += "              AND ZZX.D_E_L_E_T_ = ' ' "
	cQuery += "              AND ZZX.ZZM_CODTAB  = '" +cTabela+"' "
	cQuery += "              AND ZZX.ZZM_COD = ZZM.ZZM_COD) "

	cQuery +=" AND TRIM(CONF_DESC) = TRIM(ZZM_DESC) ) "
	cQuery +=" ORDER BY ZZM_COD, ZZM_DESC "

	//memowrite("C:\Analistas\marcela.coimbra\ListBoxMar.sql",cQuery)

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
		Return
	Endif

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 420,700 PIXEL

	@ 10,10 LISTBOX oLbx FIELDS HEADER ;
		" ", "PRODUTO", "DESCR.REGIONAL", "DESCRICAO MATRIZ" ;
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

User Function ORTP115E()
	Local aPergs     := {}
	Local aRet       := {}
	Local dData		 := stod(" ")
	Private cCadastro := "Exporta Custos"
	Private cTabOld  := '000'

	aAdd( aPergs, {2, "Opcão", "1", {"1=Geral", "2=Somente Inclusão", "3=Somente Alteraçao"}, 100, "", .F.})
	aAdd( aPergs ,{1, "Tabela Atual   :" ,cTabela,"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .T.   })
	aAdd( aPergs ,{1, "Tabela Anterior:" ,cTabOld,"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .T.   })
	aAdd( aPergs ,{1, "Data Alteração:"  ,dData  ,"@D"	,".T."	 , ,'.T.'                  , 8, .F.   })
	aAdd( aPergs, {2, "Somente Regional?", "3", {"1=Sim", "2=Não", "3=Totos"}, 100, "", .F.})

	If !Parambox( aPergs, cCadastro, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTA768" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
		Return
	EndIf
	cOpc    := MV_PAR01
	cTabela := PadL( MV_PAR02, 3, "0" )
	cTabOld := PadL( MV_PAR03, 3, "0" )
	dData   := MV_PAR04
	cOpReg  := MV_PAR05

	Processa({|| ORTP115E(cOpc,cTabela,cTabOld, dData, cOpReg) },'Consolidando dados...')
Return

Static Function ORTP115E(cOpc,cTabela,cTabOld, dData, cOpReg)
	Local aRelatorio := {}
	Local cQryC		 := ""

	cQryC := "SELECT ZZM_COD,
	cQryC += "       ZZM_DESC,
	cQryC += "       ZZM_DATA,
	cQryC += "       ZZM_PTAX,
	cQryC += "       ZZM_UM,
	cQryC += "       ZZM_PICM,
	cQryC += "       ZZM_SICM,
	cQryC += "       ZZM_VLRANT,
	cQryC += "       ROUND(ZZM_VLRANT + (ZZM_VLRANT * (ZZM_IPI) / 100),2) AS ANTIGO_CIMPOSTO,
	cQryC += "       ZZM_PORC,
	cQryC += "       ZZM_VLRNOV,
	cQryC += "       ZZM_IPI,
	cQryC += "       ZZM_TOTAL,
	cQryC += "       ZZM_IMPORT,
	cQryC += "       ZZM_CODTAB,
	cQryC += "       ZZM_MATRIZ
	cQryC += "  FROM SIGA." + RetSqlName("ZZM") + " ZZM "
	cQryC += " WHERE D_E_L_E_T_ = ' '
	cQryC += "   AND ZZM_FILIAL = '"+XFILIAL("ZZM")+"'
	cQryC += "   AND ZZM_CODTAB = '"+cTabela+"'
	cQryC += "   AND ZZM_ANOTAB = '" + cAnotab + "' "
	cQryC += "   AND ZZM_DATA = (SELECT MAX(ZZM_DATA) "
	cQryC += "              FROM  " + RetSqlName("ZZM") + " ZZX "
	cQryC += "              WHERE ZZX.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
	cQryC += "              AND ZZX.D_E_L_E_T_ = ' ' "
	cQryC += "              AND ZZX.ZZM_CODTAB  = '" +cTabela+"' "
	cQryC += "              AND ZZX.ZZM_ANOTAB = '" + cAnotab + "' "
	cQryC += "              AND ZZX.ZZM_COD = ZZM.ZZM_COD) "
	cQryC += "  AND ZZM_PICM = (SELECT MAX(ZZM_PICM) "
	cQryC += "              FROM  " + RetSqlName("ZZM") + " ZZX "
	cQryC += "              WHERE ZZX.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
	cQryC += "              AND ZZX.D_E_L_E_T_ = ' ' "
	cQryC += "              AND ZZX.ZZM_DATA = ZZM.ZZM_DATA "
	cQryC += "              AND ZZX.ZZM_CODTAB  = '" +cTabela+"' "
	cQryC += "              AND ZZX.ZZM_ANOTAB = '" + cAnotab + "' "
	cQryC += "              AND ZZX.ZZM_COD = ZZM.ZZM_COD) "
	If cOpc == "2" // Somente Inclusao
		cQryC += "  AND NOT EXISTS ( SELECT 'X' FROM SIGA." + RetSqlName("ZZM") + " ZZMA "
		cQryC += " WHERE ZZMA.D_E_L_E_T_ = ' '
		cQryC += "   AND ZZMA.ZZM_FILIAL = '"+XFILIAL("ZZM")+"'
		cQryC += "   AND ZZMA.ZZM_CODTAB = '"+cTabOld+"'
		cQryC += "   AND ZZMA.ZZM_COD = ZZM.ZZM_COD   "
		cQryC += "   AND ZZMA.ZZM_ANOTAB = '" + cAnotab + "' "
		cQryC += "   AND ZZMA.ZZM_PICM= ZZM.ZZM_PICM )  "
	Endif
	If cOpc == "3" // Somente Alteracão
		cQryC += "  AND EXISTS ( SELECT 'X' FROM SIGA." + RetSqlName("ZZM") + " ZZMA "
		cQryC += " WHERE ZZMA.D_E_L_E_T_ = ' '
		cQryC += "   AND ZZMA.ZZM_FILIAL = '"+XFILIAL("ZZM")+"'
		cQryC += "   AND ZZMA.ZZM_CODTAB = '"+cTabOld+"'
		cQryC += "   AND ZZMA.ZZM_ANOTAB = '" + cAnotab + "' "
		cQryC += "   AND ZZMA.ZZM_COD  = ZZM.ZZM_COD
		cQryC += "   AND ZZMA.ZZM_PICM = ZZM.ZZM_PICM
		cQryC += "   AND ZZMA.ZZM_TOTAL <> ZZM.ZZM_TOTAL
		cQryC += "   AND ZZMA.ZZM_DATA = ( SELECT max(ZZM_DATA) FROM SIGA." + RetSqlName("ZZM") + "  ZZMX WHERE ZZMX.D_E_L_E_T_ = ' '  "
		cQryC += "                         AND ZZMX.ZZM_CODTAB = '"+cTabOld+"' "
		cQryC += "                         AND ZZMX.ZZM_ANOTAB = '" + cAnotab + "' "
		cQryC += "                         AND ZZMX.ZZM_COD    = ZZMA.ZZM_COD  "
		cQryC += "                         AND ZZMX.ZZM_PICM   = ZZMA.ZZM_PICM  "
		cQryC += "                         AND ZZMX.ZZM_COD = ZZMA.ZZM_COD ) ) "
	Endif
	If !Empty(dData)

		cQryC += " AND ZZM.ZZM_DATA = '" + dtos( dData ) + "' "

	EndIf

	If cOpReg == '1'

		cQryC += " AND ZZM.ZZM_MATRIZ = 'N' "
	ElseIf cOpReg == '2'

		cQryC += " AND ZZM.ZZM_MATRIZ = 'S' "

	EndIf

	cQryC += " ORDER BY ZZM_PORC, ZZM_COD, ZZM_DATA DESC

	U_ORTQUERY(cQryC,"P115INS")

	While !P115INS->( Eof() )

		aadd(aRelatorio, {P115INS->ZZM_COD, ;
			TRIM(P115INS->ZZM_DESC),;
			dtoc(stod(P115INS->ZZM_DATA)),;
			Transform( P115INS->ZZM_PICM  		 , "@E 9999.99"),;
			Transform( P115INS->ANTIGO_CIMPOSTO  , "@E 999,999,999.999"),;
			Transform( P115INS->ZZM_TOTAL  		 , "@E 999,999,999.999"),;
			Transform( P115INS->ZZM_PORC  		 , "@E 9999.99"),;
			P115INS->ZZM_CODTAB,;
			IIF(P115INS->ZZM_MATRIZ=='S', 'SIM', 'NAO')})

		P115INS->(DbSkip())
	End

	If len(aRelatorio) > 0 //.and. U_ORTCHKPLAN(cRotina,cUnidade) //Desativado em 02/07/2025 para teste
		Processa({||GeraCSV({"PRODUTO", "DESCRICAO", "DATA", "ICM", "VLR.ANTIG.COM.IMPOSTO", "VLR.NOVO.COM.IMPOSTO","VARIACAO.%", "SEMANA", "MATRIZ"}, aRelatorio)},'Gerando arquivo CSV...')
	Else
		Alert("Sem registros para exportar.")
	Endif

Return
//==============================================
// GERA EXCEL/CSV
//==============================================
Static Function GeraCSV(aHead,aDados)
	Local cPath		:= "C:\CUSTOS_MARFIL\"
	Local cNomeCSV	:= "planilha_"+dtos(ddatabase)+StrTran( Time(), ":", "" )+".csv"
	Local cArquivo	:= cPath + cNomeCSV
	Local cLinha	:= ""
	Local i,z

	FwMakeDir( cPath, .T. )

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
			cLinha += Alltrim(cValToChar(aDados[i][z]))+";"
		Next z

		cLinha += CRLF
		FWrite( cArqRef, cLinha )
		cLinha := ""
	Next i

	FClose( cArqRef )

	Aviso( "Atenção", "Será aberto o arquivo abaixo." + CRLF + cArquivo, { "Ok" } )
	ShellExecute("open", cNomeCSV, "", cPath, 1)

Return

Static Function fExist(cTabNov)
	Local lRet   := .F.
	Local cQuery := ""

	cQuery:="SELECT COUNT(*) AS CONTAR FROM SIGA." + RetSqlName("ZZM") + " "
	cQuery+= " WHERE D_E_L_E_T_ = ' '
	cQuery += "   AND ZZM_FILIAL = '"+XFILIAL("ZZM")+"'
	cQuery += "   AND ZZM_CODTAB = '"+cTabNov+"'
	cQuery += "   AND ZZM_ANOTAB = '"+ALLTRIM(STR(YEAR(DDATABASE)))+"' "
	//cQuery += "   AND ZZM_ANOTAB = '"+cAnotab+"' "
	cAlias := U_ORTQUERY(cQuery, "OT115C")

	If (cAlias)->CONTAR > 0
		lRet := .T.
	Endif

Return lRet



User Function ORTP115X()

	Local aPergs     := {}
	Local aRet       := {}
//Local cQryC		 := ""
	Private cCadastro:= "Custo dos Produtos - Taxa Dolar"
	Private dTxDol   := 0

	aAdd( aPergs ,{1,"Taxa do Dolar   :" ,dTxDol, "@E 99.99"	,".T."	 , ,'.T.'                  , 80, .T.   })

	If !Parambox( aPergs, cCadastro, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTA768" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
		Return
	EndIf


	MsAguarde( { || ProcSZM(MV_PAR01) }  , "Atualizando taxas, aguarde..."  , "Aguarde, atualizando..."  )


Return

Static Function ProcSZM(MV_PAR01)


	dTxDol  :=  MV_PAR01

	If dTxDol <= 0

		MsgAlert("Taxa inválida","A taxa informada é inválida")

	ElseIf fBuscaST(cTabela) == 'F'

		MsgAlert("Tabela fechada","A tabela informada encontra-se fechada, portando não pode sofrer alteração da taxa do dolar.")


	ElseIf MsgYesNo("Confirma a ateração da taxa do dolar para tabela " + cTabela )

		cQryC := "SELECT ZZM_COD,
		cQryC += "       ZZM_DESC,
		cQryC += "       ZZM_DATA,
		cQryC += "       ZZM_PTAX,
		cQryC += "       ZZM_UM,
		cQryC += "       ZZM_PICM,
		cQryC += "       ZZM_SICM,
		cQryC += "       ZZM_VLRANT,
		cQryC += "       ZZM_PORC,
		cQryC += "       ZZM_VLRNOV,
		cQryC += "       ZZM_IPI,
		cQryC += "       ZZM_TOTAL,
		cQryC += "       ZZM_IMPORT,
		cQryC += "       ZZM.R_E_C_N_O_ RECZZM
		cQryC += "  FROM SIGA." + RetSqlName("ZZM") + " ZZM "
		cQryC += " WHERE D_E_L_E_T_ = ' '
		cQryC += "   AND ZZM_FILIAL = '"+XFILIAL("ZZM")+"'
		cQryC += "   AND ZZM_CODTAB = '"+cTabela+"'
		//cQryC += "   AND ZZM_ANOTAB = '" + ALLTRIM(STR(YEAR(DDATABASE))) + "' "
		cQryC += "   AND ZZM_ANOTAB = '" + cAnotab + "' "
		cQryC += "   AND ZZM_DATA = (SELECT MAX(ZZM_DATA) "
		cQryC += "              FROM  " + RetSqlName("ZZM") + " ZZX "
		cQryC += "              WHERE ZZX.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
		cQryC += "              AND ZZX.D_E_L_E_T_ = ' ' "
		cQryC += "              AND ZZX.ZZM_CODTAB  = '" +cTabela+"' "
		cQryC += "              AND ZZX.ZZM_COD = ZZM.ZZM_COD) "
		cQryC += "  AND ZZM_PICM = (SELECT MAX(ZZM_PICM) "
		cQryC += "              FROM  " + RetSqlName("ZZM") + " ZZX "
		cQryC += "              WHERE ZZX.ZZM_FILIAL = '"+XFILIAL("ZZM")+"' "
		cQryC += "              AND ZZX.D_E_L_E_T_ = ' ' "
		cQryC += "              AND ZZX.ZZM_DATA = ZZM.ZZM_DATA "
		cQryC += "              AND ZZX.ZZM_CODTAB  = '" +cTabela+"' "
		cQryC += "              AND ZZX.ZZM_COD = ZZM.ZZM_COD) "
		cQryC += " ORDER BY ZZM_COD, ZZM_DATA DESC

		U_ORTQUERY(cQryC,"P115INS")

		n := 0

		While !P115INS->( Eof() )
			n++

			dbSelectArea("ZZM")
			dbGoTo(P115INS->RECZZM)
			If RecLock("ZZM",.F.)

				ZZM->ZZM_PTAX	:= dTxDol


				If ZZM->ZZM_VLRUSD <> 0

					_nVlrNov := round( ZZM->ZZM_VLRUSD * dTxDol, 4 )
					_nVlrIPi := (_nVlrNov * ZZM->ZZM_IPI) / 100

					ZZM->ZZM_VLRANT := ZZM->ZZM_VLRNOV
					ZZM->ZZM_VLRNOV := _nVlrNov
					//ZZM->ZZM_SICM 	:= round( _nVlrNov - ((_nVlrNov  * ZZM->ZZM_PICM) / 100) , 4 )
					ZZM->ZZM_PORC   := (100 - ((_nVlrNov / ZZM->ZZM_VLRANT) * 100)) * -1
					ZZM->ZZM_TOTAL  := _nVlrNov + _nVlrIpi
					//ZZM->ZZM_VLRUSD :=
					ZZM->ZZM_DATA	:= Date()
				EndIf


				ZZM->(MsUnLock())
			Endif

			P115INS->(DbSkip())

		EndDo

		If n > 0

			MsgAlert("Taxa do dólar atualizada","Atualizado!")

		EndIf

		If fEnvMail(cTabela, dTxDol, "T")
//		MsgAlert("Email enviado","Email enviado!?")
		EndIf

	Endif


Return


Static Function fEnvMail(cTabela, nTaxa, cStatus)

	local cAccount := "sistema@ortobom.com.br"
	local cPssWrd  := "sis7823@w"
	local cMailTo  := "estatistica@ortobom.com.br;sandro.fontana@ortobom.com.br;rafael.melo@ortobom.com.br;leticia.sarambeli@ortobom.com.br"
	local nErro    := 0

	Local cSub := iif(cStatus == "T", "[sigo] - CADASTRO DE TAXA DE DOLAR",  "[sigo] - TABELA " + cTabela + " DE CUSTOS " + iif(cStatus == "A", "REABERTA", "FECHADA" )+ " PELA MATRIZ"  )

	If "TST" $ GetEnvServer() //Testa se é ambiente teste

		cMailTo := "rafael.nicolay@ortobom.com.br"
		
	EndIf
//---------------------------------------------------------
// Notificação de Alteração da Diferença de Aluguel
//---------------------------------------------------------------------------

	cBodyFab := '<html>'
	cBodyFab += 	'<head>'
	cBodyFab += 		'<META http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">'
	cBodyFab += 		'<style type="text/css">'
	cBodyFab += 			'#Cab{font-family:Verdana;}'
	cBodyFab += 		'</style>'
	cBodyFab += 	'</head>'

	If cStatus == 'T'

		cBodyFab += 		'<title>ALTERAÇÃO DA TAXA DO DOLAR NO CUSTO DOS PRODUTOS</title><br/><br/>'

		cBodyFab += 	'<body>'
		cBodyFab += 		'<h4 >ALTERAÇÃO DA TAXA DO DOLAR NO CUSTO DOS PRODUTOS</h4><br/>'
		cBodyFab += 	'</body>'
		cBodyFab += 	'<body>'
		cBodyFab += 		'<h5 >Prezados, </h5>'
		cBodyFab += 		'<h5 >A taxa do dolar foi alterada na tabela ' + cTabela +  ' para ' + Transform( nTaxa, "@R 99.99" ) + ' pelo usuário ' + cUserName + ' </h5>'

		cBodyFab += 	'<hr><br>'
		cBodyFab += 		'<h7 id="Cab">Enviado por: TI ORTOBOM</h7><br/><br/>'
		cBodyFab += 		'<h8 id="Cab">Mensagem automática e não é necessário respondê-la.</h8>'
		cBodyFab += 	'</body>'
		cBodyFab += '</html>'

	Else


		cBodyFab += 		'<title>TABELA DE CUSTOS ' + iif(cStatus == "A", "REABERTA", "FECHADA" ) + ' PELA MATRIZ</title><br/><br/>'

		cBodyFab += 	'<body>'
		cBodyFab += 		'<h4 >TABELA DE CUSTOS ' + iif(cStatus == "A", "REABERTA", "FECHADA" ) + ' PELA MATRIZ</h4><br/>'
		cBodyFab += 	'</body>'
		cBodyFab += 	'<body>'
		cBodyFab += 		'<h5 >Prezados, </h5>'
		cBodyFab += 		'<h5 >A tabela ' + cTabela +  ' foi ' + iif(cStatus == "A", 'reaberta pelo usuário ' + cUserName +  ' e encontra-se em manutenção pela matriz ', 'fechada  pelo usuário ' + cUserName +  ' e encontra-se disponível para uso.' ) + ' </h5>'

		cBodyFab += 	'<hr><br>'
		cBodyFab += 		'<h7 id="Cab">Enviado por: TI ORTOBOM</h7><br/><br/>'
		cBodyFab += 		'<h8 id="Cab">Mensagem automática e não é necessário respondê-la.</h8>'
		cBodyFab += 	'</body>'
		cBodyFab += '</html>'


	EndIf
//---------------------------------------------------------
// Estrutura de Envio
//---------------------------------------------------------------------------
	oServer  := TMailManager():New()
	nErro    := oServer:init( "", "10.0.100.102", cAccount, cPssWrd, 0)

	oServer:smtpConnect()

	nErro    := oServer:smtpAuth( cAccount, cPssWrd )

	oMessage := tMailMessage():new()
	oMessage:clear()
	oMessage:cFrom		:= cAccount
	oMessage:cTo		:= cMailTo
	oMessage:cSubject   := cSub
	oMessage:cBody		:= cBodyFab

	nErro := oMessage:send(oServer)

Return nErro==0

User Function ORTP115F()


	Private cCadastro:= "Custo dos Produtos - Fechar tabela"
	Private dTxDol   := 0

	If !MsgYesNo("Confirma que deseja fechar a tabela: "+ cTabela +" ? " )

		Return

	EndIf

	MsAguarde( { || ProcSZMfEC( "F" ) }  , "Fechando a tabela " + cTabela + ", aguarde..."  , "Aguarde, atualizando..."  )


Return

Static Function ProcSZMfEC(cAbreFec)


	cQryC := "SELECT ZZM_COD,
	cQryC += "       ZZM_DESC,
	cQryC += "       ZZM_DATA,
	cQryC += "       ZZM_PTAX,
	cQryC += "       ZZM_UM,
	cQryC += "       ZZM_PICM,
	cQryC += "       ZZM_SICM,
	cQryC += "       ZZM_VLRANT,
	cQryC += "       ZZM_PORC,
	cQryC += "       ZZM_VLRNOV,
	cQryC += "       ZZM_IPI,
	cQryC += "       ZZM_TOTAL,
	cQryC += "       ZZM_IMPORT,
	cQryC += "       ZZM.R_E_C_N_O_ RECZZM
	cQryC += "  FROM SIGA." + RetSqlName("ZZM") + " ZZM "
	cQryC += " WHERE D_E_L_E_T_ = ' '
	cQryC += "   AND ZZM_FILIAL = '"+XFILIAL("ZZM")+"'
	cQryC += "   AND ZZM_CODTAB = '"+cTabela+"'
	//cQryC += "   AND ZZM_ANOTAB = '" + ALLTRIM(STR(YEAR(DDATABASE))) + "' "
	cQryC += "   AND ZZM_ANOTAB = '" + cAnotab + "' "
	cQryC += " ORDER BY ZZM_COD, ZZM_DATA DESC

	U_ORTQUERY(cQryC,"P115INS")

	n := 0

	While !P115INS->( Eof() )
		n++

		dbSelectArea("ZZM")
		dbGoTo(P115INS->RECZZM)
		If RecLock("ZZM",.F.)

			If empty( ZZM_DTFECH )

				ZZM->ZZM_DTFECH := Date()

			EndIf

			ZZM->ZZM_STATUS := cAbreFec

			ZZM->(MsUnLock())

		Endif

		P115INS->(DbSkip())

	EndDo

	If n > 0

		MsgAlert("Tabela " +  cTabela + iif(cAbreFec == 'A', ' reaberta!', ' fechada!') )

	EndIf

	If fEnvMail(cTabela, , cAbreFec)
		MsgAlert("Email enviado","Email enviado!?")
	EndIf

Return

Static Function fBuscaTx( cTabela )

	cQry := " SELECT DISTINCT ZZM_PTAX   "
	cQry += " 	FROM "+RetSqlName("ZZM")
	cQry += " 	WHERE ZZM_FILIAL  = '" +xFilial("ZZM")+"' "
	cQry += " 	 AND  D_E_L_E_T_  = ' '"
	cQry += " 	 AND  ZZM_PTAX    <>0  "
	cQry += " 	 AND  ZZM_CODTAB  = '" +cTabela+"' "
	cQry += "    AND ZZM_ANOTAB = '" +cAnotab +"' "// ALLTRIM(STR(YEAR(DDATABASE))) + "' "

	memowrit('C:\QUERYS\SOBREIRA\fVlDCust2.sql',cQry)

	If Select("TDUPL") > 0
		("TDUPL")->( DbCloseArea() )
	EndIf

	TCQUERY cQry NEW ALIAS "TDUPL"

	IF !TDUPL->(  eof() )

		cXXTaxa := TDUPL->ZZM_PTAX

	EndIF

	TDUPL->(DBCLOSEAREA())

Return cXXTaxa



Static Function fBuscaST( cTabela )

	Local cStatus := "A"

	cQry := " SELECT DISTINCT ZZM_STATUS   "
	cQry += " 	FROM "+RetSqlName("ZZM")
	cQry += " 	WHERE ZZM_FILIAL  = '" +xFilial("ZZM")+"' "
	cQry += " 	 AND  D_E_L_E_T_  = ' '"
	cQry += " 	 AND  ZZM_STATUS    <> ' '  "
	cQry += " 	 AND  ZZM_CODTAB  = '" +cTabela+"' "
	//cQry += "    AND  ZZM_ANOTAB = '" + ALLTRIM(STR(YEAR(DDATABASE))) + "' "
	cQry += "    AND  ZZM_ANOTAB = '" + cAnotab + "' "

	memowrit('C:\QUERYS\SOBREIRA\fVlDCust2.sql',cQry)

	If Select("TMPSTS") > 0
		("TMPSTS")->( DbCloseArea() )
	EndIf

	TCQUERY cQry NEW ALIAS "TMPSTS"

	IF !TMPSTS->(  eof() )

		cStatus := TMPSTS->ZZM_STATUS

	EndIF

	TMPSTS->(DBCLOSEAREA())

Return cStatus
