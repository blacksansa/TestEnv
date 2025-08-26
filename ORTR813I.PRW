#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"
#INCLUDE "TBICONN.CH"

 
User Function ORTR813I()
	Local aPergs      := {}
	Local aRet        := {}
	Private cTitulo   := "SUGESTA DE PRECO - INDUSTRIAL"
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
	pRIVATE cUn       := "02" 
	Default lSobMed   := .F.


	// Adicionar parametrizacao de grupo de/ate / produto de/ate

	aAdd( aPergs ,{1,"Semana         :" ,U_ORTP169A(),"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .T.   })
	aAdd( aPergs ,{1,"Grupo de"         , cGrupoDe	, ""	  , ".T." , 'SBM', '.T.', 50,.F.})
	aAdd( aPergs ,{1,"Grupo Ate"        , cGrupoAte	, ""    , ".T."	, 'SBM', '.T.', 50,.T.})
	aAdd( aPergs ,{1,"Produto de"       , cProdDe	  , ""	  , ".T." , 'SB1', '.T.', 50,.F.})
	aAdd( aPergs ,{1,"Produto Ate"      , cProdAte	, ""    , ".T."	, 'SB1', '.T.', 50,.T.})
	aAdd( aPergs ,{2,"Visualizar     :" ,"Gerados",{"Simulacao","Gerados"}                        , 80, .F.,.F.})
	aAdd( aPergs ,{1,"Unidade"      , cUn	, ""    , ".T."	, 'SB1', '.T.', 50,.T.})

	If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTR852" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
		Return
	EndIf 

	cSemana   := PadL( MV_PAR01, 3, "0" )
	cGrupoDe  := MV_PAR02
	cGrupoAte := MV_PAR03
	cProdDe   := MV_PAR04
	cProdAte  := MV_PAR05
	cUN    	  := MV_PAR07
	cCalculo  := MV_PAR06
	lForLin   := iif( MV_PAR10 == "Sim", .T., .F.)
	
	cTabAnt   := MV_PAR11

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
	
	Local cProduto 	:= ""
	Local cDesc	 	:= ""
	Local cAltura	:= 0
	Local cPeso	 	:= 0
	Local cPrcKVen 	:= 0
	Local cMarca   	:= 0
	Local cCusK    	:= 0
		
	Local cPrcM3V  	:= 0
	Local cCusM3   	:= 0
		
	Local cPrcM3VS  := 0
	Local cCusM3S   := 0
	
	Local cPrcLmVS  := 0
	Local cCusLmS   := 0
	Local cPrcLmVS1 := 0
	Local cCusLmS1  := 0
	Local cPeca 	:= 0
	Local cCusPec   := 0

	Local cPrcTorVS := 0
	Local cCusTorS  := 0
	Local cPrcTor3M := 0
	Local cCusTor3M := 0
		
	ProcRegua(0)

	If cCalculo == "Simulacao"
		cTitulo   := cTitulo + " Simulacao Semana :" + cTabGer
	Else
		cTitulo   := cTitulo + " Semana :" + cTabGer
	Endif

	cQry := " SELECT RMZA.CHAVE,
cQry += "    		       RMZA.DESCRI LINHA,
cQry += "    		       BM_GRUPO,
cQry += "    		       BM_DESC,
cQry += "    		       B1_COD,
cQry += "    		       B1_XALT,
cQry += "    		       B1_XQTDEMB,
cQry += "                  B1_DESC, 
cQry += "    		       DA1_PRCVEN VENDA_KG, 
cQry += "    		       B1_XMARKUP MARCACAO,
cQry += "    		       DA1_XCUSTO,
cQry += "    		       DA1_PRCVEN * B1_CONV VENDA_M3,
cQry += "    		       DA1_XCUSTO * B1_CONV CUSTO_M3,
cQry += "    		       (DA1_PRCVEN * B1_CONV) / 1.8855 VENDA_M3_S,
cQry += "    		       (DA1_XCUSTO * B1_CONV) / 0.8546 CUSTO_M3_S,
cQry += "    		       DA1_PRCVEN * B1_CONV * 1.08 LAMINADO_M3,
cQry += "    		       DA1_XCUSTO * B1_CONV * 1.08 LAMINADO_CM3,
cQry += "    		       (DA1_PRCVEN * B1_CONV * 1.08)/ 52.62 LAM_M3_1,
cQry += "    		       (DA1_XCUSTO * B1_CONV * 1.08)/ 52.62 LAM_M3C_1,

cQry += "    		       (DA1_PRCVEN * B1_CONV * 1.10) TOR_M3,
cQry += "    		       (DA1_XCUSTO * B1_CONV * 1.10) TOR_M3C,

cQry += "    		       (DA1_PRCVEN * B1_CONV * 1.10) * (B1_XALT * 0.003) TOR_3MM,
cQry += "    		       (DA1_XCUSTO * B1_CONV * 1.10) * (B1_XALT * 0.003) TOR_3MMC,

cQry += "    		       DA1_PRCVEN * B1_CONV,
cQry += "    		       (DA1_PRCVEN * B1_CONV )* 1.17 PECA_VENDA,
cQry += "    		       (DA1_XCUSTO * B1_CONV )* 1.17 PECA_CUSTO
cQry += "    		       
If cCalculo == "Simulacao"
		cQry += "   FROM SIGA.PREDA1030 DA1
	Else
		cQry += "   FROM SIGA.DA1030 DA1
	Endif

cQry += "    		 INNER JOIN SIGA.SB1030 SB1 ON B1_FILIAL = ' '
cQry += "    		                           AND B1_COD = DA1_CODPRO
cQry += "    		                           AND B1_XSEGMEN = '1' 
cQry += "    		                           AND SB1.D_E_L_E_T_ = ' '
cQry += "    		                           AND SB1.D_E_L_E_T_ = ' '
cQry += "    		 INNER JOIN SIGA.SBM200 SBM ON BM_FILIAL = ' '
cQry += "    		                           AND BM_GRUPO = B1_GRUPO
cQry += "    		                           AND SBM.D_E_L_E_T_ = ' '
cQry += "    		
cQry += "    		 INNER JOIN SIGA.REGRASMAR RMZA ON RMZA.TABELA = 'ZA'
cQry += "    		                               AND RMZA.CHAVE = BM_XSUBGRU
cQry += "    		

cQry += "    		 INNER JOIN SIGA.MAR_BLOCOS_POR_UN ON UN = '"+ cUn +"' 
cQry += "    		                               AND trim(PRODUTO) = trim(B1_COD) "
cQry += "    		                               AND TAB_PRECO = '1' "
cQry += "    		  LEFT JOIN SIGA.REGRASMAR AGRU ON AGRU.TABELA = 'AG'
cQry += "    		                               AND AGRU.CHAVE = BM_XAGRP
cQry += "    		                               AND AGRU.D_E_L_E_T_ = ' '

If cCalculo == "Simulacao"
cQry += "    	WHERE 
Else
		cQry += "    	WHERE DA1_FILIAL = ' ' AND
cQry += "    	   DA1.D_E_L_E_T_ = ' ' AND
Endif



cQry += "                    DA1_CODTAB = '"+cTabGer+"'
	
	
	cQry += "  AND B1_GRUPO >= '"+cGrupoDe+"'
	cQry += "  AND B1_GRUPO <= '"+cGrupoAte+"'
	cQry += "  AND B1_COD >= '"+cProdDe+"'
	cQry += "  AND B1_COD <= '"+cProdAte+"'
	cQry += "    	ORDER BY 2, 4

	U_ORTQUERY(cQry, "OTR814")

	cGrupo := ""
	cAgrupa:= ""
	cLinha := ""
	While OTR814->(!EOF())
		// TO-DO
		IncProc()

		cProduto := Padr(Alltrim(OTR814->B1_COD) ,10)
		cDesc	 := Padr(Alltrim(OTR814->B1_DESC) ,15) 
		cAltura	 := Transform(OTR814->B1_XALT,"@E 99.99")
		cPeso	 := Transform(OTR814->B1_XQTDEMB,"@E 999")
		cPrcKVen := Transform(OTR814->VENDA_KG,"@E 9999.99")
		cMarca   := Transform(OTR814->MARCACAO,"@E 9.9999")
		cCusK    := Transform(OTR814->DA1_XCUSTO,"@E 999.99")
		
		cPrcM3V  := Transform(OTR814->VENDA_M3,"@E 9999.99")
		cCusM3   := Transform(OTR814->CUSTO_M3,"@E 9999.99")
		
		cPrcM3VS  := Transform(OTR814->VENDA_M3_S,"@E 9999.99")
		cCusM3S   := Transform(OTR814->CUSTO_M3_S,"@E 9999.99")
		
		
		If OTR814->B1_XALT < 1.4 // laminado

			cPrcLmVS  := Padr(Transform(OTR814->LAMINADO_M3,"@E 9999.99"),10)
			cCusLmS   := Padr(Transform(OTR814->LAMINADO_CM3,"@E 9999.99"),10)
			cPrcLmVS1 := Padr(Transform(OTR814->LAM_M3_1,"@E 9999.99"),10)
			cCusLmS1  := Padr(Transform(OTR814->LAM_M3C_1,"@E 9999.99"),10)
			cPeca 	  := Padr(Transform(OTR814->PECA_VENDA,"@E 9999.99"),10)
			cCusPec   := Padr(Transform(OTR814->PECA_CUSTO,"@E 9999.99"),10)

			cPrcTorVS := ''
			cCusTorS  := ''
			cPrcTor3M := ''
			cCusTor3M := ''
		
		Else

			cPrcTorVS := Padr(Transform(OTR814->TOR_M3,"@E 9999.99"),10)
			cCusTorS  := Padr(Transform(OTR814->TOR_M3C,"@E 9999.99"),10)
			cPrcTor3M := Padr(Transform(OTR814->TOR_3MM,"@E 9999.99"),10)
			cCusTor3M  := Padr(Transform(OTR814->TOR_3MMC,"@E 9999.99"),10)

			cPrcLmVS  := ''
			cCusLmS   := ''
			cPrcLmVS1 := ''
			cCusLmS1  := ''
			cPeca 	  := ''
			cCusPec   := ''

		EndIf
		
		AADD(aReport,{ 	cProduto,;
						cDesc	 ,;
						cAltura	 ,;
						cPeso	 ,;
						cPrcKVen ,;
						cMarca   ,;
						cCusK    ,;					
						cPrcM3V  ,;
						cCusM3   ,;					
						cPrcM3VS ,;
						cCusM3S  ,;					
						cPrcLmVS ,; //12
						cCusLmS  ,;	//13				
						cPrcLmVS1 ,;
						cCusLmS1  ,;					
						cPrcTorVS ,;
						cCusTorS  ,;
						cPrcTor3M ,;
						cCusTor3M  ,;
						cPeca 	  ,;
						cCusPec   })


		OTR814->(dbSkip())
	EndDo

	aCabRel := {'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''}

	IF Len(aReport) > 0
		fImpMar("ORTR813I", cTitulo, aCabRel , aReport, .T., .F.)		
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

	cAlias := U_ORTQUERY("SELECT MAX(ZV_DTUMOV) as quando FROM SIGA.PRESZV WHERE ZV_TABELA = '"+cTab+"'","R814ZVD")
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
	If lCSV
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
			oPrn:oPrint:nPageWidth 	:= 3280
			oPrn:nPageWidth 		:= 3280
			nHTam		:= 3284 // limite horizontal da pagina no modo paisagem
		endif
	Endif
EndIF

///FscFillBox(_aHead,_aItens)

RptStatus({|| GeraRel(oPrn,lpdf) },Titulo)

Return

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function GeraRel(oPrn,lpdf)
Local i

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

	IncRegua(  )

	fImpBxL(_aItens[i])
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
oPrn:SetLandscape()

nLin := 10

oPrn:Box( nLin, 01, nLin+nEsp*3+nPdf, nHTam)


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

FscPrintCab()

// ------------------

Return(nLin)

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-|
// Função criada para retornar o posicionamento do box |
// de acordo com o tamanho da string enviada           |
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-|
Static Function FscRetTam(nLen, lDesconta)

Local nTam	  := 0
Local nMedida := 16 // para fontes 09

if oPrn:nDevice == 6
	nMedida := 15 // para fontes 09
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
Static Function FscPrintCab()
*------------------------------------*

oPrn:Line(nLin  , 00, nLin  , nHTam )
	oPrn:Line(nLin+2, 00, nLin+2, nHTam )
	oPrn:Line(nLin+4, 00, nLin+4, nHTam )

oPrn:Box( nLin, 0, nLin+65, nHTam )

nCol := 1800
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 10, 700," B L O C O ", oFontM)

nCol := 1835
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 10, nCol + 30,"LAMINADO", oFontM)

nCol := 2400
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 10, nCol + 55,"TORNEADO", oFontM)

nCol := 3000
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 10 , nCol + 20,"PECA", oFontM)

nLin += nEsp + 10
oPrn:Line(nLin, 0, nLin, nHTam ) //

// cabec 2
oPrn:Say ( nLin + 30, 030,"CODIGO", oFontM)

nCol := 230
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 30, nCol + 20,"DESCRICAO", oFontM)

nCol := 550
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 30, nCol + 15,"ALTURA", oFontM)

nCol := 685
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 30 , nCol + 20,"PESO", oFontM)



nCol := 810
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 10 , nCol + 200,"KG", oFontM)

oPrn:Line(nLin + nEsp, nCol, nLin + nEsp , nHTam ) //

nCol := 1245
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 10 , nCol + 120,"M3", oFontM)

nCol := 1540
oPrn:Line(nLin, nCol, nLin+65, nCol ) // mbc
oPrn:Say ( nLin + 10 , nCol + 30,"M3 S/ REV", oFontM)

nCol := 1835
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 10 , nCol + 110,"M3", oFontM)

nCol := 2100
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 10 , nCol + 30,"1 CM (0,019m3)", oFontM)

nCol := 2400
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 10 , nCol + 30,"M3", oFontM)

nCol := 2700
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 10 , nCol + 30,"3 MM", oFontM)

nCol := 3000
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 10 , nCol + 30,"M3", oFontM)


nLin += nEsp + 10

//////////////////////////////////////////////////// cabec 3

nCol := 230
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

nCol := 550
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

nCol := 685
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

nCol := 810
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 15,"VENDA", oFontM)


nCol := 955
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 10,"MARC.", oFontM)

nCol := 1075
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 10,"CUSTO", oFontM)

////// M3

nCol := 1245
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 5,"VENDA", oFontM)


nCol := 1390
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 10,"CUSTO", oFontM)

// m3 srev
nCol := 1540
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 30,"CUSTO", oFontM)


// m3 laminado
nCol := 1835
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 20,"VENDA", oFontM)


nCol := 1955
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 25,"CUSTO", oFontM)


// LAM 1 CM
nCol := 2100
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 30,"VENDA", oFontM)

nCol := 2250
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 30,"CUSTO", oFontM)

// TORNEADO M3
nCol := 2400
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 30,"VENDA", oFontM)

nCol := 2550
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 30,"CUSTO", oFontM)

// TORNEADO 3MM
nCol := 2700
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 30,"VENDA", oFontM)

nCol := 2850
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 30,"CUSTO", oFontM)

// PECA
nCol := 3000
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 30,"VENDA", oFontM)

nCol := 3150
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 20 , nCol + 30,"CUSTO", oFontM)

nLin += nEsp + 10

///////////////////////////////////////// cabec 5

nCol := 230
oPrn:Line(nLin, nCol, nLin+60, nCol ) //

nCol := 550
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

nCol := 685
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

nCol := 810
oPrn:Line(nLin, nCol, nLin+65, nCol ) //


nCol := 955
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

nCol := 1075
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

////// M3

nCol := 1245
oPrn:Line(nLin, nCol, nLin+65, nCol ) //


nCol := 1390
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

// m3 srev
nCol := 1540
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 10 , nCol + 10,"COLCHAO", oFontM)

nCol := 1690
oPrn:Line(nLin, nCol, nLin+65, nCol ) //
oPrn:Say ( nLin + 10 , nCol + 05,"ALMOFADA", oFontM)


// m3 laminado
nCol := 1835
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

nCol := 1955
oPrn:Line(nLin, nCol, nLin+65, nCol ) //


// LAM 1 CM
nCol := 2100
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

nCol := 2250
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

// TORNEADO M3
nCol := 2400
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

nCol := 2550
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

// TORNEADO 3MM
nCol := 2700
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

nCol := 2850
oPrn:Line(nLin, nCol, nLin+65, nCol ) //


// PECA
nCol := 3000
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

nCol := 3150
oPrn:Line(nLin, nCol, nLin+65, nCol ) //

nLin += nEsp 
oPrn:Line(nLin , 0, nLin, nHTam ) //


//MBC
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


Static Function fImpBxL(aVetImp)
Local nCol
// Calcula a posição vertical do centro da linha
Local nLinhaCen := nLin + (nEsp / 2) - (oFontM:nHeight / 2)

// CODIGO
nCol := 10
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[1], oFontM)

// DESCRICAO
nCol := 230
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[2], oFontM)

// ALTURA
nCol := 550
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[3], oFontM)

// PESO
nCol := 685
oPrn:Line(nLin, nCol, nLin+50, nCol ) 
oPrn:Say ( nLinhaCen  , nCol + 15,aVetImp[4], oFontM)

// VENDA KG
nCol := 810
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[5], oFontM)

// MARCACAO
nCol := 955
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[6], oFontM)

// CUSTO KG
nCol := 1075
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 08,aVetImp[7], oFontM)

// VENDA M3
nCol := 1245
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen, nCol + 10,aVetImp[8], oFontM)

// CUSTO M3
nCol := 1390
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[9], oFontM)

// M3 SEM REVISAO
nCol := 1540
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[10], oFontM)

// M3 CUSTO SEM REVISAO
nCol := 1690
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[11], oFontM)

// LAMINADO M3
nCol := 1835
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 02,aVetImp[12], oFontM)

// LAMINADO CUSTO
nCol := 1955
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[13], oFontM)

// LAMINADO 1 CM VENDA
nCol := 2100
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[14], oFontM)

// LAMINADO 1 CM CUSTO
nCol := 2250
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[15], oFontM)

// TORNEADO M3 VENDA
nCol := 2400
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[16], oFontM)

// TORNEADO M3 CUSTO
nCol := 2550
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[17], oFontM)

// TORNEADO 3MM VENDA
nCol := 2700
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[18], oFontM)

// TORNEADO 3MM CUSTO
nCol := 2850
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[19], oFontM)

// PECA VENDA
nCol := 3000
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen  , nCol + 10,aVetImp[20], oFontM)

// PECA CUSTO
nCol := 3150
oPrn:Line(nLin, nCol, nLin+50, nCol ) //
oPrn:Say ( nLinhaCen , nCol + 10,aVetImp[21], oFontM)

oPrn:Line(nLin, nHTam, nLin + nEsp, nHTam)

oPrn:Line(nLin+nEsp   , 00, nLin+nEsp   , nHTam )

Return
