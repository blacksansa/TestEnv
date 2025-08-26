#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include "sigawin.ch"

#DEFINE ENTER CHR(13) + CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณORTA762   บAutor  ณ Fabio Costa        บ Data ณ 15/08/2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define Ordem e o Percentual dos tipos e linhas de produto  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//-=-=-=-=-=-=-=-=-=-=-=-=-
User Function ORTA762()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local nOpc      := GD_INSERT+GD_DELETE+GD_UPDATE
	Private aCoBrw1 := {}
	Private aHoBrw1 := {}
	Private noBrw1  := 0
	Private oDlg1, oGrp1,oSay1,oBtn1,oBtn2,oBtn3,oBrw1

	if cEmpAnt <> "03"
		MsgBox("O Acesso a esta rotina ้ exclusivo da unidade 03", "Unidade Invalida", "INFO")
		return
	endif

	oDlg1      := MSDialog():New( 088,232,500,845,"Linhas de Produtos",,,.F.,,,,,,.T.,,,.T. )
	oGrp1      := TGroup():New( 002,002,202,302,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1      := TSay():New( 010,006,{||"Nesta tela, voce pode cadastrar as Linhas de Produtos, e definir a ordem das mesmas na tabela de pre็os."},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,244,028)
	oBtn1      := TButton():New( 010,258,"Salvar"   ,oGrp1,{|| fSalvar()    },037,012,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton():New( 026,258,"Sair"     ,oGrp1,{|| oDlg1:end()  },037,012,,,,.T.,,"",,,,.F. )
	oBtn3      := TButton():New( 186,006,"Atualizar",oGrp1,{|| fRefresh()   },037,012,,,,.T.,,"",,,,.F. )

	MHoBrw1()
	MCoBrw1()

	//oBrw1      := MsNewGetDados():New(042,006,182,294    ,nOpc,'U_ORTA762LOK()','AllwaysTrue()','',{"X5_CHAVE","X5_DESCRI","BM_MARKUP","ACP_PERDES"},0,030,'AllwaysTrue()','','U_ORTA762DOK()',oGrp1,aHoBrw1,aCoBrw1 )
	oBrw1      := MsNewGetDados():New(042,006,182,294    ,nOpc,'U_ORTA762LOK()','AllwaysTrue()','',{"X5_CHAVE","X5_DESCRI","BM_MARKUP"},0,030,'AllwaysTrue()','','U_ORTA762DOK()',oGrp1,aHoBrw1,aCoBrw1 )

	oDlg1:Activate(,,,.T.)

Return

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function MHoBrw1()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local cTitu 	:= ""
	Local nX		:= 0
	//Local aCampos	:= {"X5_CHAVE","X5_DESCRI","BM_MARKUP","ACP_PERDES"}
	Local aCampos	:= {"X5_CHAVE","X5_DESCRI","BM_MARKUP"}

	DbSelectArea("SX3")
	DbSetOrder(2)
	For nX := 1 To Len(aCampos)
		If dbSeek(aCampos[nX])
			If aCampos[nX] == "X5_CHAVE"
				cTitu := "Linha"
			Endif
			If aCampos[nX] == "X5_DESCRI"
				cTitu := "Descri็ใo"
			Endif
			If aCampos[nX] == "BM_MARKUP"
				cTitu := "Ordem na tabela"
			Endif
			If aCampos[nX] == "ACP_PERDES"
				cTitu := "Marca็ใo"
			Endif

			noBrw1++

			Aadd(aHoBrw1,{ ;
				cTitu,;
				GetSx3Cache(aCampos[nX],'X3_CAMPO'),;
				IIF( aCampos[nX] == "ACP_PERDES", "@E 999.99", IIF( aCampos[nX] == "BM_MARKUP", "@E 99.99", GetSx3Cache(aCampos[nX],'X3_PICTURE'))),;
				IIF( aCampos[nX] == "BM_MARKUP" , 5, IIF( aCampos[nX] == "X5_DESCRI", 25, IIF( aCampos[nX] == "ACP_PERDES", 6, GetSx3Cache(aCampos[nX],'X3_TAMANHO')))),;
				IIF( aCampos[nX] == "ACP_PERDES", 2, IIF( aCampos[nX] == "BM_MARKUP", 2 , GetSx3Cache(aCampos[nX],'X3_DECIMAL'))),;
				IIF( aCampos[nX] == "X5_CHAVE"  , "U_ORTA762LOK(.T.)", ""),;
				"",;
				GetSx3Cache(aCampos[nX],'X3_TIPO'),;
				"",;
				"";
				})
		EndIf
	Next nX
Return

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function MCoBrw1()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local cQuery := ""
	Local cAlias := ""

	aCoBrw1:= {}

	cQuery := "SELECT CHAVE,      "
	cQuery += "       DESCRI,     "
	cQuery += "       ORDEM, 	  "
	cQuery += "       PERCENTUAL  "
	cQuery += "  FROM SIGA.REGRASMAR   "
	cQuery += " WHERE TABELA = 'ZA'    "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ORDEM ASC     "

	cAlias := U_ORTQUERY(cQuery, "A762")

	Do While  (cAlias)->(!EOF())
		//aAdd(aCoBrw1, { (cAlias)->CHAVE, (cAlias)->DESCRI, (cAlias)->ORDEM, (cAlias)->PERCENTUAL, .F. })
		aAdd(aCoBrw1, { (cAlias)->CHAVE, (cAlias)->DESCRI, (cAlias)->ORDEM, .F. })
		(cAlias)->(dbskip())
	EndDo

Return

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function fSalvar()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local i
	Local cQuery := ""
	Local aCols  := oBrw1:ACOLS

	For i:= 1 to Len(aCols)
		If !aCols[i][len(aCols[i])] // se ativo
			If Existe(aCols[i][1]) // se existe faz update

				//cQuery := "  UPDATE SIGA.REGRASMAR SET DESCRI = '"+aCols[i][2]+"', ORDEM = "+Alltrim(Str(aCols[i][3]))+", PERCENTUAL = "+Alltrim(Str(aCols[i][4]))+" WHERE TABELA = 'ZA' AND CHAVE = '"+aCols[i][1]+"' AND D_E_L_E_T_ = ' ' "
				cQuery := "  UPDATE SIGA.REGRASMAR SET DESCRI = '"+aCols[i][2]+"', ORDEM = "+Alltrim(Str(aCols[i][3]))+", PERCENTUAL = 0 WHERE TABELA = 'ZA' AND CHAVE = '"+aCols[i][1]+"' AND D_E_L_E_T_ = ' ' "
				nErro  := tcsqlexec(cQuery)

				If nErro <> 0
					MsgStop( "Ocorreu um erro, tente novamente.", "Erro[UP01]" )
					Return
				else
					FwPutSX5(/*cFlavour*/, "ZA", aCols[i][1], aCols[i][2], aCols[i][2], aCols[i][2], /*cTextoAlt*/)
				Endif
			else // se nao existe faz insert


				//cQuery := "  INSERT INTO SIGA.REGRASMAR (TABELA, CHAVE, DESCRI, ORDEM, PERCENTUAL) VALUES ('ZA', '"+aCols[i][1]+"', '"+aCols[i][2]+"', "+Alltrim(Str(aCols[i][3]))+" , "+Alltrim(Str(aCols[i][4]))+")  "
				cQuery := "  INSERT INTO SIGA.REGRASMAR (TABELA, CHAVE, DESCRI, ORDEM, PERCENTUAL) VALUES ('ZA', '"+aCols[i][1]+"', '"+aCols[i][2]+"', "+Alltrim(Str(aCols[i][3]))+" , 0)  "				
				nErro := tcsqlexec(cQuery)

				If nErro <> 0
					MsgStop( "Ocorreu um erro, tente novamente.", "Erro[IN01]" )
					Return
				else
					FwPutSX5(/*cFlavour*/, "ZA", aCols[i][1], aCols[i][2], aCols[i][2], aCols[i][2], /*cTextoAlt*/)
				Endif
			Endif
		else // se delete

			If !CanDel(aCols[i][1]) // Verifica se existe algum grupo de produtos atrelado a esta linha.

				MsgStop( "Nใo ้ possivel excluir o item: " +aCols[i][2]+" pois existem grupos atrelados a ele.", "Nใo Permitido" )
				Return

			else

				cQuery := "	UPDATE SIGA.REGRASMAR SET D_E_L_E_T_ = '*' WHERE TABELA = 'ZA' AND D_E_L_E_T_ = ' ' AND CHAVE = '"+aCols[i][1]+"' "
				nErro := tcsqlexec(cQuery)

				If nErro <> 0

					MsgStop( "Ocorreu um erro, tente novamente.", "Erro[EX01]" )
					Return

				else

					dbSelectArea("SX5")
					dbOrderNickName("PSX51")

					If dbSeek(xFilial("SX5")+"ZA"+aCols[i][1])

						SX5->(RecLock("SX5", .F.))
						SX5->(dbDelete())
						SX5->(MsUnlock())

					Endif

				Endif
			Endif


		EndIf
	Next i

	MsgInfo( "As informa็๕es foram salvas com sucesso. A tela serแ atualizada com o ordenamento atualizado.", "Sucesso" )
	MCoBrw1()
	oBrw1:aCols := aCoBrw1
	oBrw1:oBrowse:Refresh(.t.)
	oBrw1:GoTop()

Return

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function fRefresh()
//-=-=-=-=-=-=-=-=-=-=-=-=-

	If MsgYesNo("Deseja Continuar? Quaisquer altera็oes nใo salvas serใo perdidas.")
		aCoBrw1:= {}
		MCoBrw1()
		oBrw1:aCols := aCoBrw1
		oBrw1:oBrowse:Refresh(.t.)
	Endif

Return


//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function Existe(cItem)
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local lRet := .F.
	Local cQuery := ""

	cQuery := "SELECT COUNT(*) AS CONTAR FROM SIGA.REGRASMAR WHERE D_E_L_E_T_ = ' ' AND TABELA = 'ZA' AND CHAVE = '"+cItem+"'"
	cAlias := U_ORTQUERY(cQuery, "A762E")

	If (cAlias)->CONTAR > 0
		lRet := .T.
	Endif

Return lRet

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function CanDel(cItem)
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local lRet := .T.
	Local cQuery := ""

	cQuery := "SELECT COUNT(*) AS CONTAR FROM SIGA.SBM200 SBM WHERE BM_FILIAL = '" + XFILIAL("SBM")+"' AND SBM.D_E_L_E_T_ = ' ' AND BM_XSUBGRU = '"+cItem+"'"
	cAlias := U_ORTQUERY(cQuery, "A762D")

	If (cAlias)->CONTAR > 0
		lRet := .F.
	Endif

Return lRet

//-=-=-=-=-=-=-=-=-=-=-=-=-
User Function ORTA762DOK()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local aCols	  := oBrw1:aCols
	Local _nat    := oBrw1:nat
	Local lRet    := .T.

	If !CanDel(aCols[_nat][1])
		lRet	:= .F.
		MsgStop( "Nใo ้ possivel excluir o item: " +aCols[_nat][2]+" pois existem grupos atrelados a ele.", "Nใo Permitido" )
	Endif

Return lRet

//-=-=-=-=-=-=-=-=-=-=-=-=-
User Function ORTA762LOK(lCpo)
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local aCols  := oBrw1:aCols
	Local _nat   := oBrw1:nat
	Local lRet   := .T.
	Local ix     := 1
	Default lCpo := .F.

	If lCpo
		If M->X5_CHAVE <> aCols[_nat,1] .AND. !empty(aCols[_nat,1]) .AND. Existe(aCols[_nat,1])
			lRet	:= .F.
			MsgStop( "Nใo ้ possivel alterar o codigo de linha ja existente.", "Nใo Permitido" )
			Return lRet
		Endif
		If empty(M->X5_CHAVE) .AND. !empty(aCols[_nat,1])
			lRet	:= .F.
			MsgStop( "O Linha ้ de preenchimento obrigatorio.", "Nใo Permitido" )
			aCols[_nat,len(aCols[ix])] := .T.
			Return lRet
		Endif
	Endif

	for ix := 1 to len(aCols)
		if ix       <> _nat .and.  aCols[ix,len(aCols[ix])] == .F.  .and.  aCols[ix,1] == aCols[_nat,1]
			lRet	:= .F.
			MsgStop( "Esta linha jแ se encontra cadastrada: " +aCols[_nat][2]+" ", "Nใo Permitido" )
		endif
	next

Return lRet
