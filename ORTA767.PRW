#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include "sigawin.ch"

#DEFINE ENTER CHR(13) + CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณORTA767   บAutor  ณ Fabio Costa        บ Data ณ 29/09/2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Manutencao de grupos de produtos                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//-=-=-=-=-=-=-=-=-=-=-=-=-
User Function ORTA767()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local nOpc      := GD_INSERT+GD_DELETE+GD_UPDATE
	Private aCoBrw1 := {}
	Private aHoBrw1 := {}
	Private aAtu	:= {}
	Private noBrw1  := 0
	Private oDlg1, oGrp1,oSay1,oSay2,oBtn1,oBtn2,oBtn3,oBrw1,oGet1,oBtn4
	Private cPesquisa := space(06)

	if cEmpAnt <> "03"
		MsgBox("O Acesso a esta rotina ้ exclusivo da unidade 03", "Unidade Invalida", "INFO")
		return
	endif

	oDlg1      := MSDialog():New( 088,232,503,1160,"Grupos de Produtos",,,.F.,,,,,,.T.,,,.T. )
	oGrp1      := TGroup():New(002,002,202,460,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1      := TSay():New( 010,006,{||"Nesta tela, voce pode cadastrar os Grupos de Produtos, com seus respectivos percentuais."},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,244,028)

	oBtn1      := TButton():New( 010,415,"Salvar"   ,oGrp1,{|| Processa( {|| fSalvar() }, "Aguarde...", "Salvando dados",.F.)   },037,012,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton():New( 026,415,"Sair"     ,oGrp1,{|| oDlg1:end()  },037,012,,,,.T.,,"",,,,.F. )
	oBtn3      := TButton():New( 186,006,"Atualizar",oGrp1,{|| fRefresh()   },037,012,,,,.T.,,"",,,,.F. )

	oSay2      := TSay():New( 030,006,{||"Pesquisar:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
	oGet1      := TGet():New( 029,032,{|u| If(PCount()>0,cPesquisa:=u,cPesquisa)},oGrp1,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cPesquisa",,)
	oBtn4      := TButton():New( 029,082,"Ir",oGrp1,{|| Procurar()    },025,010,,,,.T.,,"",,,,.F. )

	MHoBrw1()
	MCoBrw1()

	oBrw1      := MsNewGetDados():New(042,006,182,454 ,nOpc,'U_ORTA767LOK()','AllwaysTrue()','',{"X5_CHAVE",'BM_DESC', 'BM_MARKUP', 'BM_XORDMIX', 'BM_XSEGM', 'BM_XALTBX', 'BM_XSUBGRU', 'BM_XCOMIND', 'BM_XCOMCOM', 'BM_XDENSCO', 'BM_XDENSFA', 'BM_XTLDE','BM_XGERMAR','BM_XGERSOB','BM_XPRDPAD','BM_XCONGP','BM_XAGRP'},0,99999,'U_ORTA767fOK()','','U_ORTA767DOK()',oGrp1,aHoBrw1,aCoBrw1 )

	oDlg1:Activate(,,,.T.)

Return

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function MHoBrw1()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local cTitu 	:= ""
	Local nX		:= 0
	Local aCampos	:= {"X5_CHAVE",'BM_DESC', 'BM_MARKUP', 'BM_XORDMIX', 'BM_XSEGM', 'BM_XALTBX', 'BM_XSUBGRU', 'BM_XCOMIND', 'BM_XCOMCOM', 'BM_XDENSCO', 'BM_XDENSFA', 'BM_XTLDE','BM_XGERMAR','BM_XGERSOB','BM_XPRDPAD','BM_XCONGP','BM_XAGRP'}

	//*DbSelectArea("SX3")
	//*DbSetOrder(2)
	For nX := 1 To Len(aCampos)
		If aCampos[nX] == "X5_CHAVE"
			cTitu := "Grupo"			
		ElseIf aCampos[nX] == "BM_XGERMAR"				
			cTitu := "Gera Marfil"			
		ElseIf aCampos[nX] == "BM_XGERSOB"				
			cTitu := "Gera Sob-Med"			
		ElseIf aCampos[nX] == "BM_XCONGP"				
			cTitu := "Congela Preco"
		ElseIf aCampos[nX] == "BM_XAGRP"				
			cTitu := "Agrupamento"								
		Else
			cTitu := GetSx3Cache(aCampos[nX],'X3_TITULO')
		Endif

		noBrw1++

		Aadd(aHoBrw1,{ ;
			cTitu,;
			GetSx3Cache(aCampos[nX],'X3_CAMPO'),;
			GetSx3Cache(aCampos[nX],'X3_PICTURE'),;
			IIF( aCampos[nX] == "BM_XORDMIX"  , 2, GetSx3Cache(aCampos[nX],'X3_TAMANHO')),;
			IIF( aCampos[nX] == "BM_XORDMIX"  , 0, GetSx3Cache(aCampos[nX],'X3_DECIMAL')),;
			IIF( aCampos[nX] == "X5_CHAVE"    , "U_ORTA767LOK(.T.)", ""),;
			"",;
			GetSx3Cache(aCampos[nX],'X3_TIPO'),;
			IIF( aCampos[nX] == "BM_XAGRP"  , "U_ORTA767X3()", ""),;
			"";
			})

			/*------------------------------------------*\
			| Estrutura do array com o cabe็alho da Grid |
			|--------------------------------------------|
			| aHeader[01] - X3_TITULO  | Tํtulo          |
			| aHeader[02] - X3_CAMPO   | Campo           |
			| aHeader[03] - X3_PICTURE | Picture         |
			| aHeader[04] - X3_TAMANHO | Tamanho         |
			| aHeader[05] - X3_DECIMAL | Decimal         |
			| aHeader[06] - X3_VALID   | Valida็ใo       |
			| aHeader[07] - X3_USADO   | Usado           |
			| aHeader[08] - X3_TIPO    | Tipo            |
			| aHeader[09] - X3_F3      | F3              |
			| aHeader[10] - X3_CONTEXT | Contexto (R,V)  |
			| aHeader[11] - X3_CBOX    | Combobox        |
			| aHeader[12] - X3_RELACAO | Inicial. Padrao |
			| aHeader[13] - X3_WHEN    | Habilita edicao |
			| aHeader[14] - X3_VISUAL  | Alteravel (A,V) |
			| aHeader[15] - X3_VLDUSER | Valid de User   |
			| aHeader[16] - X3_PICTVAR | Picture         |
			| aHeader[17] - X3_OBRIGAT | Obrigatorio     |
			\*------------------------------------------*/

	Next nX
Return

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function MCoBrw1()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local cQuery := ""
	Local cAlias := ""

	aCoBrw1:= {}

	cQuery := "SELECT BM_GRUPO CHAVE,       "
	cQuery += "       BM_DESC DESCRI,      "
	cQuery += "       BM_XORDMIX ORDEM, 	   "
	cQuery += "       BM_XGERMAR MARFIL, 	   "
	cQuery += "       BM_XGERSOB SOBMED, 	   "
	cQuery += "       BM_MARKUP PERCENTUAL,  "
	cQuery += "       BM_XCONGP CONGELA,  "
	cQuery += "       BM_MARKUP,   "
	cQuery += "       BM_XORDMIX,  "
	cQuery += "       BM_XSEGM,    "
	cQuery += "       BM_XALTBX,   "
	cQuery += "       BM_XSUBGRU,  "
	cQuery += "       BM_XCOMIND,  "
	cQuery += "       BM_XCOMCOM,  "
	cQuery += "       BM_XDENSCO,  "
	cQuery += "       BM_XDENSFA,  "
	cQuery += "       BM_XTLDE,	   "
	cQuery += "       BM_PICPAD,   "
	cQuery += "       BM_XFALINS,  "
	cQuery += "       BM_XPRDPAD,  "
	cQuery += "       BM_XNREPOR,  "
	cQuery += "       BM_XAGRP AGRUPAMENTO  "	
	cQuery += "  FROM  SIGA.SBM200 BM "
	cQuery += " WHERE BM.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY CHAVE, ORDEM ASC "

	cAlias := U_ORTQUERY(cQuery, "A767")

	Do While  (cAlias)->(!EOF())
		aAdd(aCoBrw1, { (cAlias)->CHAVE, ;
			(cAlias)->DESCRI,;
			IIf( (cAlias)->BM_MARKUP == 0  ,(cAlias)->PERCENTUAL, (cAlias)->BM_MARKUP),;
			Val((cAlias)->BM_XORDMIX),;
			(cAlias)->BM_XSEGM,;
			(cAlias)->BM_XALTBX,;
			(cAlias)->BM_XSUBGRU,;
			(cAlias)->BM_XCOMIND,;
			(cAlias)->BM_XCOMCOM,;
			(cAlias)->BM_XDENSCO,;
			(cAlias)->BM_XDENSFA,;
			(cAlias)->BM_XTLDE,;			
			(cAlias)->MARFIL,;			
			(cAlias)->SOBMED,;			
			(cAlias)->BM_XPRDPAD,;			
			(cAlias)->CONGELA,;			
			(cAlias)->AGRUPAMENTO,;			
			.F. })
		(cAlias)->(dbskip())
	EndDo

Return

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function fSalvar()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local i
	Local aCols  := oBrw1:ACOLS

	ProcRegua(len(aCols))

	For i:= 1 to Len(aCols) 
		IncProc()

		If aScan(aAtu, {|x| x == aCols[i][1] } ) > 0

			If !aCols[i][len(aCols[i])] .AND. !Empty(aCols[i][1]) // se ativo

				If Existe(aCols[i][1]) // se existe faz update

						dbSelectArea("SBM")
						dbSetOrder(1)

						If dbSeek(xFilial("SBM") + aCols[i][1])
							lInsert := .F.
						Else
							lInsert := .T.
						Endif
						
						reclock("SBM",lInsert)
						SBM->BM_FILIAL  := xFilial("SBM")
						SBM->BM_GRUPO   := aCols[i][01]
						SBM->BM_DESC    := aCols[i][02]
						SBM->BM_MARKUP  := aCols[i][03]
						SBM->BM_XORDMIX	:= IIf(aCols[i][04] == 99, '  ', Str(aCols[i][04]))
						SBM->BM_XSEGM   := aCols[i][05]
						SBM->BM_XALTBX  := aCols[i][06]
						SBM->BM_XSUBGRU := aCols[i][07]
						SBM->BM_XCOMIND := aCols[i][08]
						SBM->BM_XCOMCOM := aCols[i][09]
						SBM->BM_XDENSCO	:= aCols[i][10]
						SBM->BM_XDENSFA	:= aCols[i][11]
						SBM->BM_XTLDE   := aCols[i][12]						
						SBM->BM_XGERMAR	:= aCols[i][13]						
						SBM->BM_XGERSOB	:= aCols[i][14]
						SBM->BM_XPRDPAD	:= aCols[i][15]
						SBM->BM_XCONGP 	:= aCols[i][16]						
						SBM->BM_XAGRP   := aCols[i][17]						
					
						msunlock()			
						
					

				else // se nao existe faz insert


					
						dbSelectArea("SBM")
						dbSetOrder(1)

						If dbSeek(xFilial("SBM") + aCols[i][1])
							lInsert := .F.
						Else
							lInsert := .T.
						Endif
						//If lInsert
							reclock("SBM",lInsert)
							SBM->BM_FILIAL  := xFilial("SBM")
							SBM->BM_GRUPO   := aCols[i][01]
							SBM->BM_DESC    := aCols[i][02]
							SBM->BM_MARKUP  := aCols[i][03]
							SBM->BM_XORDMIX	:= IIf(aCols[i][04] == 99, '  ', Str(aCols[i][04]))
							SBM->BM_XSEGM   := aCols[i][05]
							SBM->BM_XALTBX  := aCols[i][06]
							SBM->BM_XSUBGRU := aCols[i][07]
							SBM->BM_XCOMIND := aCols[i][08]
							SBM->BM_XCOMCOM := aCols[i][09]
							SBM->BM_XDENSCO	:= aCols[i][10]
							SBM->BM_XDENSFA	:= aCols[i][11]
							SBM->BM_XTLDE   := aCols[i][12]
							SBM->BM_XGERMAR	:= aCols[i][13]						
							SBM->BM_XGERSOB	:= aCols[i][14]						
							SBM->BM_XPRDPAD	:= aCols[i][15]						
							SBM->BM_XCONGP 	:= aCols[i][16]						
							SBM->BM_XAGRP   := aCols[i][17]						
							msunlock()
							//Endif
				Endif
			else // se delete

				If !CanDel(aCols[i][1]) // Verifica se existe algum grupo de produtos atrelado a esta linha.

					MsgStop( "Nใo ้ possivel excluir o item: " +aCols[i][2]+" pois existem produtos atrelados a ele.", "Nใo Permitido" )
					Return

				else
						
						dbSelectArea("SBM")
						dbSetOrder(1)

						If dbSeek(xFilial("SBM") + aCols[i][1])
								
								SBM->(RecLock("SBM", .F.))
								SBM->(dbDelete())
								SBM->(MsUnlock())
								
						Endif
						
					
				Endif
			Endif
		Endif
	Next i

	MsgInfo( "As informa็๕es foram salvas com sucesso. A tela serแ atualizada.", "Sucesso" )
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

	cQuery := "SELECT COUNT(*) AS CONTAR FROM SIGA.SBM200 WHERE D_E_L_E_T_ = ' '  AND BM_GRUPO = '"+cItem+"'"
	cAlias := U_ORTQUERY(cQuery, "A767E")

	If (cAlias)->CONTAR > 0
		lRet := .T.
	Endif

Return lRet

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function CanDel(cItem)
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local lRet := .T.
	Local cQuery := ""

	cQuery := "SELECT COUNT(*) AS CONTAR FROM SIGA.SB1030 SB1 WHERE B1_FILIAL = '" + XFILIAL("SB1")+"' AND SB1.D_E_L_E_T_ = ' ' AND B1_GRUPO = '"+cItem+"'"
	cAlias := U_ORTQUERY(cQuery, "A767D")

	If (cAlias)->CONTAR > 0
		lRet := .F.
	Endif

Return lRet

//-=-=-=-=-=-=-=-=-=-=-=-=-
User Function ORTA767DOK()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local aCols	  := oBrw1:aCols
	Local _nat    := oBrw1:nat
	Local lRet    := .T.

	If !CanDel(aCols[_nat][1])
		lRet	:= .F.
		MsgStop( "Nใo ้ possivel excluir o item: " +aCols[_nat][2]+" pois existem produtos atrelados a ele.", "Nใo Permitido" )
	Else
		If aScan(aAtu, {|x| x == aCols[_nat][1] } ) == 0
			Aadd(aAtu, aCols[_nat][1])
		Endif
	Endif

Return lRet

//-=-=-=-=-=-=-=-=-=-=-=-=-
User Function ORTA767FOK()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local aCols	  := oBrw1:aCols
	Local _nat    := oBrw1:nat
	Local lRet    := .T.

	lRet := U_ORTA767LOK()

	If lRet
		If aScan(aAtu, {|x| x == aCols[_nat][1] } ) == 0
			Aadd(aAtu, aCols[_nat][1])
		Endif
	Endif

Return lRet
//-=-=-=-=-=-=-=-=-=-=-=-=-
User Function ORTA767LOK(lCpo)
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local aCols  := oBrw1:aCols
	Local _nat   := oBrw1:nat
	Local lRet   := .T.
	Local ix     := 1
	Default lCpo := .F.

	If lCpo
		If M->X5_CHAVE <> aCols[_nat,1] .AND. !empty(aCols[_nat,1]) .AND. Existe(aCols[_nat,1])
			lRet	:= .F.
			MsgStop( "Nใo ้ possivel alterar o codigo de Grupo ja existente.", "Nใo Permitido" )
			Return lRet
		Endif
		If empty(M->X5_CHAVE) .AND. !empty(aCols[_nat,1])
			lRet	:= .F.
			MsgStop( "O Grupo ้ de preenchimento obrigatorio.", "Nใo Permitido" )
			aCols[_nat,len(aCols[ix])] := .T.
			Return lRet
		Endif
	Endif

	If aScan(aCols, {|x| Alltrim(x[1]) == Alltrim(M->X5_CHAVE) }) > 0
		lRet	:= .F.
		MsgStop( "Este Grupo jแ se encontra cadastrado: " +aCols[_nat][2]+" ", "Nใo Permitido" )
	Else
		for ix := 1 to len(aCols)
			if ix       <> _nat .and.  aCols[ix,len(aCols[ix])] == .F.  .and. Alltrim(aCols[ix,1]) == Alltrim(aCols[_nat,1])
				lRet	:= .F.
				MsgStop( "Este Grupo jแ se encontra cadastrado: " +aCols[_nat][2]+" ", "Nใo Permitido" )
			endif
		next
	Endif
	If lRet
		Aadd(aAtu, aCols[_nat][1])
	Endif

Return lRet

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function Procurar()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local aCols  := oBrw1:aCols
	Local nPos1	 := aScan(aCols, { |x| Alltrim(x[1]) == Alltrim(cPesquisa) })
	Local nPos2	 := aScan(aCols, { |x| Alltrim(x[2]) == Alltrim(cPesquisa) })
	If nPos1 > 0
		oBrw1:GoTo(nPos1)
		oBrw1:Refresh()
	Else
		If nPos2 > 0
			oBrw1:GoTo(nPos2)
			oBrw1:Refresh()
		Else
			MsgStop( "Grupo: " + cPesquisa + " nใo encontrado.", "Nใo Encontrado" )
		Endif
	Endif

Return




// processa arquivo de texto com as marca็oes originais
User function ORTA767I()
	Local _cCSV	  := "C:\fabio\marcacoes.txt"
	Local _cLinha := ""
	Local _nLidas := 0
	Local _nProc  := 0
	Local _nErros := 0
	Local nHdl    := FT_FUSE(_cCSV)

	If !File(_cCSV)
		MsgBox("Arquivo " + _cCSV + " nao encontrado.  Verifique.","ATENวรO!","INFO")
		Return
	Endif

	If nHdl == -1
		MsgAlert("O arquivo de nome "+_cCSV+" nao pode ser aberto! Verifique.","Atencao!")
		Return
	Endif

	FT_FGOTOP()

	Do While !FT_FEOF()
		_cLinha := FT_FREADLN()
		_nLidas++

		If !Empty(_cLinha)

			_cCod := Substr(_cLinha,1,10)
			_cTipo:= Substr(_cLinha,11,1)
			_nMk1 := Val(Substr(_cLinha,12,5))/100
			_nMk2 := Val(Substr(_cLinha,17,5))/100

			dbSelectArea("SB1")
			dbOrderNickName("PSB11")

			// checa se existe
			If !dbSeek(xFilial("SB1") + _cCod)
				FT_FSKIP()
				LOOP
			Endif

			_cDesc:= POSICIONE("SBM", 1, xFilial("SBM")+SB1->B1_GRUPO, "BM_DESC")

			If Existe(SB1->B1_GRUPO) // se existe faz update

				cQuery := "  UPDATE SIGA.REGRASMAR SET PERCENTUAL = "+Alltrim(Str(_nMk1+_nMk2))+" WHERE TABELA = 'SBM' AND CHAVE = '"+SB1->B1_GRUPO+"' AND D_E_L_E_T_ = ' ' "
				nErro  := tcsqlexec(cQuery)

			Else
				cQuery := "  INSERT INTO SIGA.REGRASMAR (TABELA, CHAVE, DESCRI, PERCENTUAL) VALUES ('SBM', '"+SB1->B1_GRUPO+"', '"+_cDesc+"', "+Alltrim(Str(_nMk1+_nMk2))+" )  "
				nErro := tcsqlexec(cQuery)
			Endif

			if nErro == 0
				_nProc++
			Else
				_nErros++
				MemoWrite( "c:\fabio\Error_" + alltrim(Str(_nLidas)) + ".log", TCSQLError() )
			Endif

		Endif
		FT_FSKIP()
	EndDo

	alert("Processo finalizado. Lidos: " + Alltrim(Str(_nLidas-1)) + " / Ajustados: " + Alltrim(Str(_nProc)) + " / Erros: " + Alltrim(Str(_nErros)) + ".")
	FT_FUSE()
return

// importa registros da sbm que nao constem na tabela atual 
User Function ORTA767P()
	Local cQuery := ""
	Local nErro  := 0

	cQuery := "INSERT INTO siga.regrasmar
	cQuery += "  (TABELA, CHAVE, DESCRI, PERCENTUAL, ORDEM)
	cQuery += "  SELECT 'SBM' AS TABELA, BM_GRUPO, BM_DESC, BM.BM_MARKUP, TO_NUMBER(DECODE(BM.BM_XORDMIX, '  ', '99',BM.BM_XORDMIX ))
	cQuery += "    FROM SIGA.SBM200 BM
	cQuery += "   WHERE BM_FILIAL = '  '
	cQuery += "     AND D_E_L_E_T_ = ' '
	cQuery += "     AND BM_GRUPO <> '    '
	cQuery += "     AND BM_GRUPO <> '0000'
	cQuery += "     AND BM_GRUPO NOT LIKE 'C%'
	cQuery += "     AND NOT EXISTS (SELECT 'X'
	cQuery += "            FROM SIGA.REGRASMAR
	cQuery += "           WHERE TABELA = 'SBM'
	cQuery += "             AND CHAVE = BM_GRUPO)
	cQuery += "     AND EXISTS
	cQuery += "   (SELECT 'X'
	cQuery += "            FROM SIGA.SB1030
	cQuery += "           WHERE B1_GRUPO = BM_GRUPO
	cQuery += "             AND B1_MSBLQL <> '1'
	cQuery += "             AND B1_XCODBAS = ' '
	cQuery += "             AND (B1_XFORLIN = ' ' OR B1_XFORLIN >= '20191001'))
	cQuery += "ORDER BY 5

	nErro := tcsqlexec(cQuery)
/*
	IF SBM->BM_XSUBGRU $ ("10001L|10001C")
		SBM->BM_XORDMIX := '01'

	ELSEIF SBM->BM_XSUBGRU $ ("10002L|10003L")
		SBM->BM_XORDMIX := '02'

	ELSEIF SBM->BM_XSUBGRU $ ("10003C|10002C")
		SBM->BM_XORDMIX := '03'

	ELSEIF SBM->BM_XSUBGRU $ ("10004C|10004L")
		SBM->BM_XORDMIX := '04'

	ELSEIF SBM->BM_XSUBGRU $ ("10005L")
		SBM->BM_XORDMIX := '05'

	ELSEIF SBM->BM_XSUBGRU $ ("10006C")
		SBM->BM_XORDMIX := '06'

	ELSEIF SBM->BM_XSUBGRU $ ("10006G")
		SBM->BM_XORDMIX := '07'

	ELSEIF SBM->BM_XSUBGRU $ ("10007O|10008O")
		SBM->BM_XORDMIX := '08'

	ELSEIF SBM->BM_XSUBGRU $ ("20001I")
		SBM->BM_XORDMIX := '09'

	ELSEIF SBM->BM_XSUBGRU $ ("20002I")
		SBM->BM_XORDMIX := '10'

	ELSEIF SBM->BM_XSUBGRU $ ("20009I")
		SBM->BM_XORDMIX := '11'

	ELSEIF SBM->BM_XSUBGRU $ ("20003I")
		SBM->BM_XORDMIX := '12'

	ELSEIF SBM->BM_XSUBGRU $ ("20004I")
		SBM->BM_XORDMIX := '13'

	ELSEIF SBM->BM_XSUBGRU $ ("20005I")
		SBM->BM_XORDMIX := '14'

	ELSEIF SBM->BM_XSUBGRU $ ("20007I|20008I")
		SBM->BM_XORDMIX := '15'
	endif
*/

Return


// ------------------------------------------------------|
// F3 GENERICO
// REVISADO - FABIO COSTA 09/01/2019
// ------------------------------------------------------|
User Function ORTA767X3()
Local cQry        := ""
Private aDados    := {}
Private cTitulo   := "Agrupamentos Marfil"
Private cPreenche := ""
Default lSM0      := .F.

	cQry := "SELECT CHAVE,    "
	cQry += "       DESCRI,   "
	cQry += "       ORDEM 	  "
	cQry += "  FROM SIGA.REGRASMAR   "
	cQry += " WHERE TABELA = 'AG'    "
	cQry += "   AND D_E_L_E_T_ = ' ' "
	cQry += " ORDER BY ORDEM ASC, CHAVE     "

U_ORTQUERY(cQry, "OTA767X")

While !(OTA767X->(EOF()))
	AaDD(aDados,{AllTrim(OTA767X->CHAVE),AllTrim(OTA767X->DESCRI)})
	OTA767X->(dbSkip())
EndDo

OTA767X->(dbCloseArea())

U_FSCxF3(aDados, cTitulo, @cPreenche, .T.)

M->BM_XAGRP := cPreenche

Return .T.
