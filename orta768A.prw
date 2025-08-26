#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include "sigawin.ch"

#DEFINE ENTER CHR(13) + CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORTA776   ºAutor  ³ Marcela Coimbra    º Data ³ 28/03/2024  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Alteração de fora de linha                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//-=-=-=-=-=-=-=-=-=-=-=-=-
User Function ORTA768L()
						//:= 1
Local aButtons  				:={}
Local oSize						:= FwDefSize():New(.T., .T.)

Private oAgp      				:= Nil
Private cTitulo   				:= "Inclusão/Alteração de fora de linha."
Private nomeprog  				:= "ORTA768B"
Private Cabec1,Cabec2,Cabec3 	:= ""
Private oDlg      				:= Nil
Private oFont6    				:= NIL
Private aProd      				:= {{"","",""}}
Private cProd      				:= space(14) //space(06)
Private cCdProd                 := Space(06) 
Private oProd,oData      		:= Nil
Private nTxConv   				:= 0
Private aFilPro 				:= {}
Private oListProd    			:= Nil
Private lAgp        			:=.F.
Private dData 					:= stod("")

oFont6							:= TFont():New("Courier New",,14,,.T.)

Define Font oFontNeg Name "ARIAL" 	Size 0,-12 Bold

oSize:AddObject( "GCABECAC",  120, 250, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS",  120, 300, .T., .T. ) // Totalmente dimensionavel
oSize:lLateral 	:= .F. // Lateral
oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins:= {3,3,3,3}

oSize:Process() // Dispara os calculos 

DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], 640 TITLE cTitulo OF oDlg PIXEL
oDlg:bStart := {|| (ENCHOICEBAR(oDlg,{|| GrvCli(olistProd,lAgp)},{|| oDlg:End()},,aButtons))}                            

nLI := oSize:GetDimension("GCABECAC","LININI")
nCI := oSize:GetDimension("GCABECAC","COLINI")
nLE := oSize:GetDimension("GCABECAC","LINEND")
nCE := oSize:GetDimension("GCABECAC","COLEND")

@ nLI+013, nCI+005 TO 115,305 PIXEL
@ nLI+015, nCI+010 SAY "Esta rotina tem por objetivo incluir ou " 																					OF oDlg PIXEL 	Size 275,010 FONT oFont6 PIXEL//COLOR CLR_HBLUE
@ nLI+025, nCI+010 SAY "Alterar a data em que um produto fica fora de linha." 																	OF oDlg PIXEL 	Size 275,010 FONT oFont6 PIXEL
@ nLI+040, nCI+010 SAY "Data    :" 																													OF oDlg 		Size 150,010 FONT oFont6 PIXEL
@ nLI+065, nCI+010 SAY "Produto :" 																													OF oDlg 		Size 150,010 FONT oFont6 PIXEL

@ nLI+040, nCI+050 MsGet oData     		Var dData 		Size 60,010  F3  COLOR CLR_BLUE  Font oFontNeg Picture "@!"  PIXEL 	OF oDlg
@ nLI+065, nCI+050 MsGet oProd     		Var cProd 		Size 90,010 Valid(fValProd()) F3 "SB1" COLOR CLR_BLUE  Font oFontNeg Picture "@!"  PIXEL 	OF oDlg

@ nLI+090, nCI+005 ListBox olistProd Fields HEADER "Codigo","Nome","Fora de linha" FIELDSIZES 025,025,50,100 Size 300,150 pixel 						OF oDlg //175

oListProd:SetArray(aProd)
oListProd:nAt:=1
oListProd:bLine:={|| {aProd[oListProd:nAt, 1],aProd[oListProd:nAt, 2],stod(aProd[oListProd:nAt, 3])}}

ACTIVATE MSDIALOG oDlg CENTERED

if .t.

	fAlteraFL()

EndIf

Return

Return(.T.)


*******************************
Static Function fValProd() // incluido por claudio rocha ss1-127789
*******************************
Local lRet:=.t.
If !empty(cProd)
	if Empty(aProd[1,1])
		aProd:={}
	endif
	dbSelectArea("SB1")
		if ascan(aProd,{|x| x[1] == alltrim(cProd)})>0
			Alert("Produto ja informado")
			lRet:=.F.
		else
			dbSetOrder(1)
			if dbseek(xFilial("SB1")+Alltrim(cProd))

				aadd(aProd,{SB1->B1_COD,SB1->B1_DESC,SB1->B1_XFORLIN})
			endif
		endif	
	If lRet
		oListProd:SetArray(aProd)
		oListProd:bLine:={|| {aProd[oListProd:nAt, 1],aProd[oListProd:nAt, 2],aProd[oListProd:nAt, 3]}}
		oListProd:Refresh()
	Endif
	cProd:=space(14)
	lRet:=.F.
endif
Return(lRet)

*******************************
Static Function GrvCli(olistCli,lAgp) // incluido por claudio rocha ss1-127789
*******************************
Local x

	For x := 1 to len(oListCli:aarray)
		aadd(aFilPro,{oListCli:aarray[x][3]})
	Next x
	oDlg:End()

Return

Static Function fAlteraFL()

Local nCont := 0


If len(aFilPro) > 0

	For nCont := 1 to len(aFilPro)

		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek( xFilial("SB1") + aFilPro[nCont][1] )

			RecLock("SB1",.F.)

				//SB1->B1_XFORLIN := dData

			SB1->(MsUnLock())

		EndIf

	Next

EndIf

Return


