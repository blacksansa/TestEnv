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
User Function ORTA768G()
						//:= 1
Local aButtons  				:={}
Local oSize						:= FwDefSize():New(.T., .T.)

Private oAgp      				:= Nil
Private cTitulo   				:= "De X Para de insumos."
Private nomeprog  				:= "ORTA768G"
Private Cabec1,Cabec2,Cabec3 	:= ""
Private oDlg      				:= Nil
Private oFont6    				:= NIL
Private aProd      				:= {{"","","","",""}}
Private cProd      				:= space(14) //space(06)
Private cCdProd                 := Space(06) 
Private oProd      		:= Nil
Private nTxConv   				:= 0
Private aFilPro 				:= {}
Private oListProd    			:= Nil
Private lAgp        			:=.F.


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
@ nLI+050, nCI+010 SAY "Produto :" 																													OF oDlg 		Size 150,010 FONT oFont6 PIXEL

@ nLI+048, nCI+050 MsGet oProd     		Var cProd 		Size 90,010 Valid(fValProd()) F3 "SB1" COLOR CLR_BLUE  Font oFontNeg Picture "@!"  PIXEL 	OF oDlg

@ nLI+090, nCI+005 ListBox olistProd Fields HEADER "Produto","Nome","DT INI", "DT FIM" FIELDSIZES 025,025,50,100 Size 300,150 pixel 						OF oDlg //175

oListProd:SetArray(aProd)
//oListProd:nAt:=1
oListProd:bLine:={|| {aProd[oListProd:nAt, 1],aProd[oListProd:nAt, 2],aProd[oListProd:nAt, 3],aProd[oListProd:nAt, 4]}}

ACTIVATE MSDIALOG oDlg CENTERED

if .F.

	fAlteraFL()

EndIf

Return

Return(.T.)


*******************************
Static Function fValProd() // incluido por claudio rocha ss1-127789
*******************************
Local lRet:=.t.

aProd:={}

If !empty(cProd)

	cQry := " SELECT G1_COD, B1_DESC, G1_INI, G1_FIM, G1.R_E_C_N_O_ RECG1  "
	cQry += " FROM SIGA.SG1030 G1 INNER JOIN SIGA.SB1030 SB1 ON B1_FILIAL = '" + XFILIAL("SB1") + "' "
	cQry += "                             AND B1_COD = G1_COD "
	cQry += "                             AND SB1.D_E_L_E_T_ = ' ' "
	cQry += " WHERE G1_FILIAL = '01' "
	cQry += " AND G1_COMP = '" + cProd + "'
	cQry += " AND G1.D_E_L_E_T_ =  ' '
	
	cQry += " ORDER BY 2 "

	cAlias := U_ORTQUERY(cQry,"TMPG1",,.F.)

	nLin := 0
	While !TMPG1->( EOF() )
		aadd(aProd,{TMPG1->G1_COD,;
					TMPG1->B1_DESC,;
					TMPG1->G1_INI,;
					TMPG1->G1_FIM,;
					TMPG1->RECG1 })

		TMPG1->( dbSkip() )
nLin++

	EndDo

	oListProd:SetArray(aProd)
	oListProd:bLine := { || {aProd[oListProd:nAt,01],    aProd[oListProd:nAt,02],    aProd[oListProd:nAt,03]}}  
	oListProd:Refresh()
	

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

	For nCont := 1 to len(aProd)

		dbSelectArea("sg1")
		dbgoto(aProd[nCont][5])
		
		G1COD    := SG1->G1_COD
		G1COMP   := SG1->G1_COMP
		G1TRT    := SG1->G1_TRT
		G1FIXVAR := SG1->G1_FIXVAR
		G1QUANT  := SG1->G1_QUANT
		G1PERDA  := SG1->G1_PERDA
		G1INI    := SG1->G1_INI    
		G1FIM    := SG1->G1_FIM    
		G1OBSERV := SG1->G1_OBSERV 
		G1NIVINV := SG1->G1_NIVINV 
		G1GROPC  := SG1->G1_GROPC  
		G1OPC    := SG1->G1_OPC    
		G1REVINI := SG1->G1_REVINI 
		G1REVFIM := SG1->G1_REVFIM 
		G1NIV    := SG1->G1_NIV    
		G1TIPVEC := SG1->G1_TIPVEC 
		G1POTENCI:= SG1->G1_POTENCI
		G1OK     := SG1->G1_OK     
		G1VLCOMPE:= SG1->G1_VLCOMPE
		G1DTCRIA := SG1->G1_DTCRIA 
		G1VECTOR := SG1->G1_VECTOR 
		G1USAALT := SG1->G1_USAALT 
		G1LOCCONS:= SG1->G1_LOCCONS
		G1FANTASM:= SG1->G1_FANTASM
		G1LISTA  := SG1->G1_LISTA  

		
		RecLock("SG1",.F.)
			SG1->G1_OBSERV  := "DELECAO PROCESSO DE X PARA. PRODUTO NOVO: " + aProd[nCont][1]
		MsUnlock()

		RecLock("SG1",.F.)
			SG1->(dbDelete())
		MsUnlock()

		RecLock("SG1",.T.)
			
			SG1->G1_FILIAL 	:= XFILIAL("SG1")
			SG1->G1_COD 	:= G1COD
			SG1->G1_COMP 	:= G1COMP
			SG1->G1_DESC	:= G1DESC
			SG1->G1_TRT		:= G1TRT
			SG1->G1_FIXVAR	:= G1FIXVAR
			SG1->G1_QUANT	:= G1QUANT
			SG1->G1_PERDA	:= G1PERDA
			SG1->G1_INI    	:= G1INI    
			SG1->G1_FIM    	:= G1FIM    
			SG1->G1_OBSERV 	:= G1OBSERV 
			SG1->G1_NIVINV 	:= G1NIVINV 
			SG1->G1_GROPC  	:= G1GROPC  
			SG1->G1_OPC    	:= G1OPC    
			SG1->G1_REVINI 	:= G1REVINI 
			SG1->G1_REVFIM 	:= G1REVFIM 
			SG1->G1_NIV    	:= G1NIV    
			SG1->G1_TIPVEC 	:= G1TIPVEC 
			SG1->G1_POTENCI	:= G1POTENCI
			SG1->G1_OK     	:= G1OK     
			SG1->G1_VLCOMPE	:= G1VLCOMPE
			SG1->G1_DTCRIA 	:= date()
			SG1->G1_VECTOR 	:= G1VECTOR 
			SG1->G1_USAALT 	:= G1USAALT 
			SG1->G1_LOCCONS	:= G1LOCCONS
			SG1->G1_FANTASM	:= G1FANTASM
			
		MsUnlock()

	Next

EndIf

Return


