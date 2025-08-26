#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include "sigawin.ch"

#DEFINE ENTER CHR(13) + CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณORTA776   บAutor  ณ Marcela Coimbra    บ Data ณ 28/03/2024  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de blocos por unidade                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

//-=-=-=-=-=-=-=-=-=-=-=-=-
User Function ORTA768B()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local nOpc      := GD_INSERT+GD_DELETE+GD_UPDATE
	Private aCoBrw1 := {} 
	Private aHoBrw1 := {}
	Private noBrw1  := 0
	Private oDlg1, oGrp1,oSay1,oBtn1,oBtn2,oBtn3,oBrw1

	Private Inclui 


	if cEmpAnt <> "03"
		MsgBox("O Acesso a esta rotina ้ exclusivo da unidade 51", "Unidade Invalida", "INFO")
		return
	endif

	oDlg1      := MSDialog():New( 088,232,500,845,"Cadastro de blocos por unidade",,,.F.,,,,,,.T.,,,.T. )
	oGrp1      := TGroup():New( 002,002,202,302,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1      := TSay():New( 010,006,{||"Nesta tela, voce pode definir os blocos que serใo exibidos no relat๓rio "},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,244,028)
	oBtn1      := TButton():New( 010,258,"Salvar"   ,oGrp1,{|| fSalvar()    },037,012,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton():New( 026,258,"Sair"     ,oGrp1,{|| oDlg1:end()  },037,012,,,,.T.,,"",,,,.F. )
	oBtn3      := TButton():New( 186,006,"Atualizar",oGrp1,{|| fRefresh()   },037,012,,,,.T.,,"",,,,.F. )

	MHoBrw1() 
	MCoBrw1()

	oBrw1      := MsNewGetDados():New(042,006,182,294    ,nOpc,'U_O768BLOK()','AllwaysTrue()','' ,{"UNIDADE","PRODUTO", "INDUSTRIAL", "BLOCOS"},0,9999,'AllwaysTrue()','','',oGrp1,aHoBrw1,aCoBrw1 )
	
	oDlg1:Activate(,,,.T.)

Return

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function MHoBrw1()
//-=-=-=-=-=-=-=-=-=-=-=-=-

	Aadd(aHoBrw1,{ "UN","UNIDADE","@!",2,0,"","","C",""/*cF3*/,""})
	Aadd(aHoBrw1,{ "COD","PRODUTO","@!",10,0,"","","C","SB1",""})
	Aadd(aHoBrw1,{ "DESC","DESC","@!",30,0,"","","C","",""})
	Aadd(aHoBrw1,{ "BLOCOS","BLOCOS","@!"        ,1,0,"","","C","","2" , "1=Sim;2=Nao"})
	Aadd(aHoBrw1,{ "INCUSTRIAL","INDUSTRIAL","@!",1,0,"","","C","","2", "1=Sim;2=Nao" })

Return

//-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function MCoBrw1()
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local cQuery := ""
	Local cAlias := ""

	aCoBrw1:= {}

	cQuery := "SELECT UN,      "
	cQuery += "       PRODUTO,     "
	cQuery += "       DESCPROD , "	  "
	cQuery += "       DT_CADASTRO , R_E_C_N_O_ RECMAR, TAB_PRECO, PLAN_BLOCOS "
	cQuery += "  FROM SIGA.MAR_BLOCOS_POR_UN   "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY 1, 2     "

	cAlias := U_ORTQUERY(cQuery, "A768")

	Do While  (cAlias)->(!EOF())		
		aAdd(aCoBrw1, { (cAlias)->UN, ;
						(cAlias)->PRODUTO, ;
						(cAlias)->DESCPROD, ;
						(cAlias)->PLAN_BLOCOS, ;
						(cAlias)->TAB_PRECO, ;
						(cAlias)->DT_CADASTRO,;
						 (cAlias)->RECMAR, ;
						 .F. })		
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

        //aCols[i][1] := PADL(alltrim(aCols[i][1]), 6,'0')

		If !Empty(aCols[i][2])

			If !aCols[i][len(aCols[i])]  // se ativo
				


				If !Existe(aCols[i][1], aCols[i][2] ) // se existe faz update
					
					// se nao existe faz insert
					
					cQuery := "  INSERT INTO SIGA.MAR_BLOCOS_POR_UN (UN, PRODUTO, DESCPROD, DT_CADASTRO,D_E_L_E_T_, PLAN_BLOCOS, TAB_PRECO, R_E_C_N_O_)"
					cQuery += "  VALUES ( '"+alltrim(aCols[i][1])+"', '"+alltrim(aCols[i][2])+"', '"+Alltrim(aCols[i][3])+"', '"+dtos(date())+"', ' ','"+aCols[i][4]+"','"+aCols[i][5]+"',  (SELECT NVL( MAX(R_E_C_N_O_), 0 )+1 FROM MAR_BLOCOS_POR_UN ) )  "

					nErro := tcsqlexec(cQuery)

					If nErro <> 0
						
						MsgStop( "Ocorreu um erro, tente novamente. Produto: " + alltrim(aCols[i][2]) , "Erro[IN01]" )
						
					Endif
				Else

					cQuery := "	UPDATE SIGA.MAR_BLOCOS_POR_UN SET PLAN_BLOCOS = '"+alltrim(aCols[i][4])+"', TAB_PRECO = '"+alltrim(aCols[i][5])+"' WHERE PRODUTO = '"+alltrim(aCols[i][2])+"' AND UN = '" + alltrim(aCols[i][1]) + "' "
					nErro := tcsqlexec(cQuery)

					If nErro <> 0

						MsgStop( "Ocorreu um erro, tente novamente.Produto: " + alltrim(aCols[i][2]), "Erro[EX02]" )
						
					Endif

				Endif

			else // se delete

					cQuery := "	UPDATE SIGA.MAR_BLOCOS_POR_UN SET D_E_L_E_T_ = '*' WHERE R_E_C_N_O_ = "+str(aCols[i][7])+" "
					nErro := tcsqlexec(cQuery)

					If nErro <> 0

						MsgStop( "Ocorreu um erro, tente novamente.", "Erro[EX01]" )
						Return

					else				

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
Static Function Existe( cUn, cProduto )
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local lRet := .F.
	Local cQuery := ""

	cQuery := "SELECT COUNT(*) AS CONTAR FROM SIGA.MAR_BLOCOS_POR_UN WHERE D_E_L_E_T_ = ' ' AND UN = '" + cUn + "' AND PRODUTO = '"+alltrim(cProduto)+"'"
	cAlias := U_ORTQUERY(cQuery, "A776E")

	If A776E->CONTAR > 0
		lRet := .T.
	Endif

Return lRet


//-=-=-=-=-=-=-=-=-=-=-=-=-
User Function O768BLOK(lCpo)
//-=-=-=-=-=-=-=-=-=-=-=-=-
	Local aCols  := oBrw1:aCols
	Local _nat   := oBrw1:nat
	Local lRet   := .T.

	Default lCpo := .F.

	aCols[_nat][3] := posicione( "SB1", 1, XFILIAL("SB1") + aCols[_nat][2], "B1_DESC")


Return lRet
