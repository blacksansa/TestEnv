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
ฑฑบPrograma  ณORTA776   บAutor  ณ Marcela Coimbra    บ Data ณ 15/08/2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define Ordem e os Grupamentos Adicionais de produtos       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//-=-=-=-=-=-=-=-=-=-=-=-=-
User Function ORTA768P()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local nOpc      := GD_INSERT+GD_DELETE+GD_UPDATE
	Private aCoBrw1 := {} 
	Private aHoBrw1 := {}
	Private noBrw1  := 0
	Private oDlg1, oGrp1,oSay1,oBtn1,oBtn2,oBtn3,oBrw1

	Private Inclui 


	if cEmpAnt <> "03"
		MsgBox("O Acesso a esta rotina ้ exclusivo da unidade 03", "Unidade Invalida", "INFO")
		return
	endif

	oDlg1      := MSDialog():New( 088,232,500,845,"Cadastro de custo de produtos de terceiros",,,.F.,,,,,,.T.,,,.T. )
	oGrp1      := TGroup():New( 002,002,202,302,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1      := TSay():New( 010,006,{||"Nesta tela, voce pode cadastrar produtos de terceiros "},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,244,028)
	oBtn1      := TButton():New( 010,258,"Salvar"   ,oGrp1,{|| fSalvar()    },037,012,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton():New( 026,258,"Sair"     ,oGrp1,{|| oDlg1:end()  },037,012,,,,.T.,,"",,,,.F. )
	oBtn3      := TButton():New( 186,006,"Atualizar",oGrp1,{|| fRefresh()   },037,012,,,,.T.,,"",,,,.F. )

	MHoBrw1() 
	MCoBrw1()

	oBrw1      := MsNewGetDados():New(042,006,182,294    ,nOpc,'U_O768TLOK()','AllwaysTrue()','',{"PA3_COD", "ZZM_VLRNOV", "ZZM_VLRUSD"},0,050,'AllwaysTrue()','','',oGrp1,aHoBrw1,aCoBrw1 )

	oDlg1:Activate(,,,.T.)

Return

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function MHoBrw1()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local cTitu 	:= ""
	Local nX		:= 0	
	Local aCampos	:= {"PA3_COD","ZZM_VLRNOV", "ZZM_VLRUSD"}	
	Local cF3       := ""

	For nX := 1 To Len(aCampos)
		If aCampos[nX] == "PA3_COD"
			cTitu := "Produto"
			cF3   := "SB1" 
		Endif
		If aCampos[nX] == "ZZM_VLRNOV"
			cTitu := "Pre็o de Venda"
			
		Endif
		If aCampos[nX] == "ZZM_VLRUSD"
			cTitu := "Custo"
		Endif			

		noBrw1++

		Aadd(aHoBrw1,{ ;
			cTitu,;
			GetSx3Cache(aCampos[nX],'X3_CAMPO'),;
			GetSx3Cache(aCampos[nX],'X3_PICTURE'),;
			GetSx3Cache(aCampos[nX],'X3_TAMANHO'),;
			GetSx3Cache(aCampos[nX],'X3_DECIMAL'),;
			IIF( aCampos[nX] == "PA3_COD"  , "U_O768TLOK(.T.)", ""),;
			GetSx3Cache(aCampos[nX],'X3_USADO'),;
			GetSx3Cache(aCampos[nX],'X3_TIPO'),;
			cF3,;
			"";
			})
	Next nX
Return

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function MCoBrw1()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local cQuery := ""
	Local cAlias := ""

	aCoBrw1:= {}

	cQuery := "SELECT PRODUTO ,      "
	cQuery += "       PRECO_VENDA ,     "
	cQuery += "       CUSTO  , "	  "
	cQuery += "       DATA_INC  , R_E_C_N_O_ RECMAR "
	cQuery += "  FROM SIGA.TERCEIROS_MARFIL   "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY 1, 2     "

	cAlias := U_ORTQUERY(cQuery, "A768")

	Do While  (cAlias)->(!EOF())		
		aAdd(aCoBrw1, {  (cAlias)->PRODUTO, (cAlias)->PRECO_VENDA, (cAlias)->CUSTO, (cAlias)->RECMAR, .F. })		
		(cAlias)->(dbskip())
	EndDo

Return

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function fSalvar()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local i
	Local cQuery := ""
	Local aCols  := oBrw1:ACOLS
	Local nRecno := 0

	For i:= 1 to Len(aCols)

        //aCols[i][1] := PADL(alltrim(aCols[i][1]), 6,'0')

		If !aCols[i][len(aCols[i])] // se ativo
            

			If Existe(aCols[i][1], @nRecno ) // se existe faz update
				

				cQuery := " UPDATE SIGA.TERCEIROS_MARFIL SET PRECO_VENDA = " + str(aCols[i][2]) + ", CUSTO = " + str(aCols[i][3]) + " WHERE  PRODUTO = '"+alltrim(aCols[i][1])+"'"
				nErro := tcsqlexec(cQuery)

				If nErro <> 0
					MsgStop( "Ocorreu um erro, tente novamente.", "Erro[IN01]" )
					Return
				EndIf

			Else
				// se nao existe faz insert
				
				cQuery := "  INSERT INTO SIGA.TERCEIROS_MARFIL ( PRODUTO, PRECO_VENDA , CUSTO , DATA_INC , D_E_L_E_T_, R_E_C_N_O_) "
				cQuery += "  VALUES ( '"+alltrim(aCols[i][1])+"', "+str(aCols[i][2])+", "+str(aCols[i][3])+", '"+dtos(date())+"', ' ', (SELECT NVL( MAX(R_E_C_N_O_), 1 ) FROM TERCEIROS_MARFIL ) )  "
				
				nErro  := tcsqlexec(cQuery)

				If nErro <> 0
					MsgStop( "Ocorreu um erro, tente novamente.", "Erro[IN02]" )
					Return
				else
					
				Endif
			
			Endif
		else // se delete

				cQuery := "	UPDATE SIGA.TERCEIROS_MARFIL SET D_E_L_E_T_ = '*' WHERE R_E_C_N_O_ = '"+aCols[i][5]+"' "
				nErro := tcsqlexec(cQuery)

				If nErro <> 0

					MsgStop( "Ocorreu um erro, tente novamente.", "Erro[EX01]" )
					Return

				else				

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
Static Function Existe( cProduto , nRec )
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local lRet := .F.
	Local cQuery := ""
	Local nRecno := 0

	cQuery := "SELECT r_e_c_n_o_ RECPROD  FROM SIGA.TERCEIROS_MARFIL WHERE D_E_L_E_T_ = ' ' AND  PRODUTO = '"+alltrim(cProduto)+"'"
	cAlias := U_ORTQUERY(cQuery, "A776E")

	If !A776E->( eof() )
		
		lRet := .T.
		nRecno := A776E->RECPROD

	Endif

Return lRet


//-=-=-=-=-=-=-=-=-=-=-=-=-
User Function O768TLOK(lCpo)
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local lRet   := .T.
	Default lCpo := .F.

	//aCols[_nat][3] := posicione( "SB1", 1, XFILIAL("SB1") + aCols[_nat][2], "B1_DESC")


Return lRet
