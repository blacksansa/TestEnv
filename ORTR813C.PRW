#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"
#INCLUDE "TBICONN.CH"

 
User Function ORTR813C()

	Local aPergs      := {}
	Local aRet        := {}
	Private cTitulo   := "SUGESTA DE PRECO - COMERCIAL | "
	Private cSemana   := ""
	Private cAgru     := ""
	Private cCongela  := ""
	Private cCalculo  := ""
	Private cGrupoDe  := space(4)
	Private cGrupoAte := "ZZZZ"
	Private cProdDe   := space(15)
	Private cProdAte  := "ZZZZZZZZZZZZZZZ"
	Private cVaria    := ""
	Private lVaria    := .F.
	Private cTabAnt	  := ""
	Private lForLin   := .F.
	Default lSobMed   := .F.


	// Adicionar parametrizacao de grupo de/ate / produto de/ate

	aAdd( aPergs ,{1,"Semana         :" ,U_ORTP169A(),"@!"	,".T."	 ,'DA0' ,'.T.'                  , 80, .T.   })
	aAdd( aPergs ,{1,"Grupo de"         , cGrupoDe	, ""	  , ".T." , 'SBM', '.T.', 50,.F.})
	aAdd( aPergs ,{1,"Grupo Ate"        , cGrupoAte	, ""    , ".T."	, 'SBM', '.T.', 50,.T.})
	aAdd( aPergs ,{1,"Produto de"       , cProdDe	  , ""	  , ".T." , 'SB1', '.T.', 50,.F.})
	aAdd( aPergs ,{1,"Produto Ate"      , cProdAte	, ""    , ".T."	, 'SB1', '.T.', 50,.T.})
	aAdd( aPergs ,{2,"Visualizar     :" ,"Gerados",{"Gerados", "Simulacao"}                        , 80, .F.,.F.})
	aAdd( aPergs ,{2,"Visualizar     :" ,"Relatorio Completo",{"Relatorio Completo", "Comercial","Dirigida 05", "Dirigida 06", "Dirigida 11", "Vendas Web", "Hotelaria","Casas Bahia"}                        , 80, .F.,.F.})
	
	If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTR852" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
		Return
	EndIf 

	cSemana   := PadL( MV_PAR01, 3, "0" )
	cGrupoDe  := MV_PAR02
	cGrupoAte := MV_PAR03
	cProdDe   := MV_PAR04
	cProdAte  := MV_PAR05
	cCalculo  := MV_PAR06
	cAgru     := MV_PAR07

	cAgrupamento(cAgru)
	Processa( {|| Relatorio(cSemana) }, "Aguarde...", "Gerando relatorio...",.F.)

Return

static function cAgrupamento(Agrupamento)
	DO CASE
		CASE Agrupamento == "Relatorio Completo"
		cTitulo += Agrupamento

		CASE Agrupamento == "Comercial"
		cAgru := "000300"
		cTitulo += Agrupamento 

		CASE Agrupamento == "Dirigida 5"
		cAgru := "000005"
		cTitulo += Agrupamento 

		CASE Agrupamento == "Dirigida 6"
		cAgru := "000006"
		cTitulo += Agrupamento 
		
		CASE Agrupamento == "Dirigida 11"
		cAgru := "000011"
		cTitulo += Agrupamento 

		CASE Agrupamento == "Dirigida 26"
		cAgru := "000026"
		cTitulo += Agrupamento 

		CASE Agrupamento == "Vendas Web"
		cAgru := "000121"
		cTitulo += Agrupamento 


		CASE Agrupamento == "Casas Bahia"
		cAgru := "000121"
		cTitulo += Agrupamento 

		CASE Agrupamento == "Hotelaria"
		cAgru := "000108"
		cTitulo += Agrupamento 

	END CASE
	
return
Static Function Relatorio(cSemana)
	Local cQry    := ""
	Local cTabGer := cSemana
	Local aReport := {}
	
	ProcRegua(0)

	cAlias := U_ORTQUERY("SELECT MAX(DA1_DTUMOV) as quando FROM SIGA.PREDA1030 WHERE DA1_CODTAB = '"+cTabGer+"'")
	_cLastData := (cAlias)->quando
	(cAlias)->(DBCLOSEAREA())

	
	If cCalculo == "Simulacao"
		cTitulo   := cTitulo + " - Simulacao Semana: " + cTabGer + " "  
	Else
		cTitulo   := cTitulo + " - Semana : " + cTabGer + " "
	Endif
	
	cQry := " SELECT 	RMZA.CHAVE,"
    cQry += "    		RMZA.DESCRI AGRU_DESC,"
    cQry += "    		RMZA.ORDEM,"
    cQry += "    		BM_GRUPO,"
	cQry += "    		BM_DESC GRUPO,"
	cQry += "    		B1_COD,"
	cQry += "    		B1_XCOMP,"
	cQry += "    		B1_XLARG,"
	cQry += "    		B1_XALT,"
	cQry += "    		DA1_PRCVEN * 0.90 A_VISTA,"
	cQry += "    		DA1_PRCVEN * 0.92 A30_DD, "
	cQry += "    		DA1_PRCVEN * 0.96 A60_DD, "
	cQry += "    		DA1_PRCVEN A90_DD , "
	cQry += "    		B1_XESPACO

	If cCalculo == "Simulacao"

		cQry += "   FROM SIGA.PREDA1030 DA1

	Else

		cQry += "   FROM SIGA.DA1030 DA1

	Endif

	cQry += "    		INNER JOIN SIGA.SB1030 SB1 ON B1_FILIAL = ' '
    cQry += "    		   AND B1_COD = DA1_CODPRO
    cQry += "    		   AND B1_XSEGMEN = '2' 
    cQry += "    		   AND SB1.D_E_L_E_T_ = ' '
    cQry += "    		   AND SB1.D_E_L_E_T_ = ' '
 	cQry += "    		INNER JOIN SIGA.SBM200 SBM ON BM_FILIAL = ' '
    cQry += "    		                       AND BM_GRUPO = B1_GRUPO
    cQry += "    		                       AND SBM.D_E_L_E_T_ = ' '

    cQry += "    		                       INNER JOIN SIGA.REGRASMAR RMZA ON RMZA.TABELA = 'ZA'
    cQry += "    		                                                  AND RMZA.CHAVE = BM_XSUBGRU

    cQry += "    		                       LEFT JOIN SIGA.REGRASMAR AGRU ON AGRU.TABELA = 'AG'
    cQry += "    		                       AND AGRU.CHAVE = BM_XAGRP
    cQry += "    		                       AND AGRU.D_E_L_E_T_ = ' '

   If cCalculo == "Simulacao"
cQry += "    	WHERE 
Else
		cQry += "    	WHERE DA1_FILIAL = ' ' AND
		cQry += "    	    DA1.D_E_L_E_T_ = ' ' AND
Endif

    cQry += "    	 DA1_CODTAB = '"+cTabGer+"' "
    cQry += "    	   AND SUBSTR(B1_COD, 1, 1) <> '2'
      
    
    
	
	If cCalculo == "Simulacao"
		cQry += "                   and DA1_DTUMOV = '"+_cLastData+"'
	Else
		cQry += "                   and DA1.d_e_l_e_t_ = ' '	
	Endif

	cQry += "  AND B1_GRUPO >= '"+cGrupoDe+"'
	cQry += "  AND B1_GRUPO <= '"+cGrupoAte+"'
	cQry += "  AND B1_COD >= '"+cProdDe+"'
	cQry += "  AND B1_COD <= '"+cProdAte+"'
	cQry += "  AND B1_XFORLIN = ' '
	cQry += "  AND B1_XCODBAS = ' '

	if(cAgru <> "Relatorio Completo")
		cQry += "  AND BM_XAGRP = '"+cAgru+"'"
	endif

	cQry += "  AND RMZA.DESCRI != 'TERCEIROS'
	cQry += "    	ORDER BY RMZA.ORDEM, BM_DESC"
	U_ORTQUERY(cQry, "OTR814")

	cGrupo := ""
	cDGrupo := ""
	cAgrupa:= ""
	cLinha := ""

	While OTR814->(!EOF())

		// TO-DO
		IncProc()

		If Padr(OTR814->AGRU_DESC,20) <> cAgrupa
			
			AADD(aReport,{  "AGRUPAMENTO:",;
				Alltrim(OTR814->AGRU_DESC),;
				'',;
				'',;
				'',;
				'',;
				'',;
				''})
		Endif		

		If Padr(OTR814->GRUPO,30) <> cDGrupo

			//aSobMed := getSZV(cTabGer,cGrupo, IIF(cCalculo == "Simulacao",.T.,.F.))

			AADD(aReport,{  "GRUPO:" ,;
				Alltrim(OTR814->GRUPO),;
				'',;
				'',;
				'',;
				'',;
				'',;
				''})
		Endif
		
		cLinha	 := Padr(OTR814->BM_GRUPO,20)
		cGrupo 	 := Padr(OTR814->GRUPO,35)
		cDGrupo	 := Alltrim(OTR814->GRUPO)
		cAgrupa  := Padr(OTR814->AGRU_DESC,20)
		cProduto := Padr(Alltrim(OTR814->B1_COD) ,10)
		cMedida	 := Padr(Alltrim(STR(OTR814->B1_XLARG)) + "X" + Alltrim(Str(OTR814->B1_XCOMP)) + "/" + Alltrim(Str(OTR814->B1_XALT)),15)
		cAVista  := Padr(Transform(OTR814->A_VISTA,"@E 99999.99"),08)
		c30  	 := Padr(Transform(OTR814->A30_DD,"@E 99999.99"),08)
		c60  	 := Padr(Transform(OTR814->A60_DD,"@E 99999.99"),08)
		c90  	 := Padr(Transform(OTR814->A90_DD,"@E 99999.99"),08)
		cEsp  	 := Padr(Transform(OTR814->B1_XESPACO,"@E 99999.99"),08)
		
		
			// ate 165 chars
			AADD(aReport,{  cLinha		,;
							cGrupo		,;
							cProduto	,;
							cMedida		,;
							cAVista		,;
							c30			,;
							c60			,;
							c90			,;
							cEsp		})
			
		
		OTR814->(dbSkip())
	EndDo

	aCabRel := {"CODIGO", "MEDIDA", "A VISTA", "30 DD","60 DD","90 DD", "ESP"}

	IF Len(aReport) > 0
		fImpMar("ORTR813C", cTitulo, aCabRel , aReport, .T., .T.)		
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

	cAlias := U_ORTQUERY("SELECT MAX(ZV_DTUMOV) as quando FROM SIGA.PRESZV030 WHERE ZV_TABELA = '"+cTab+"'","R814ZVD")
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
Private oPrn,oFontM,oFontP, oFontA, oFontG
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

oFontM	:= TFont():New('Courier New',, 11,, .T.,,,,,.F.,.F.)
oFontG	:= TFont():New('Courier New',, 11,, .T.,,,,,.T.,.F.)

oFontA  := TFont():New('Courier New',, 13,, .T.,,,,,.F.,.F.)	
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
			oPrn:oPrint:nPageWidth 	:= 3380
			oPrn:nPageWidth 		:= 3380
			nHTam		:= 3384 // limite horizontal da pagina no modo paisagem
		endif
	Endif
EndIF

FscFillBox(_aHead,_aItens)

RptStatus({|| GeraRel(oPrn,lpdf) },Titulo)

Return

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Static Function GeraRel(oPrn,lpdf)

Local h
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

	If  alltrim(_aItens[i][1])  == 'AGRUPAMENTO:'   

		FscPrintBox({2117},nEsp+ 10)
		oPrn:Say ( nLin+IIf(lPdf,07,10), 1000, _aItens[i][2] , oFontA)
		nLin += nEsp+10
		Loop

	ElseIf alltrim(_aItens[i][1])  == 'GRUPO:'          
	    
		FscPrintBox({2117},nEsp)
		oPrn:Say ( nLin+IIf(lPdf,07,10), 10, _aItens[i][2] , oFontM)
		nLin += nEsp
		Loop

	EndIf	

		If lImpBox
			//FscPrintBox(aBox1,50)
			FscPrintBox(aBox1,nEsp)
		endif	

		for h:=3 to len(_aItens[i])
			if h == 3
				oPrn:Say ( nLin+IIf(lPdf,07,10), 10, _aItens[i][3] , oFontM)
			else
				oPrn:Say ( nLin+IIf(lPdf,07,10), aBox1[h-3]+IIf(lPdf,05,10), _aItens[i][h] , oFontM)
			endif
		next h

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
if !lRetrato
	oPrn:SetLandscape()
endif
If lpdf
	nLin := 30
	oPrn:SetPaperSize(9)
Else
	nLin := 10
EndIF


//oPrn:Box ( [ nRow], [ nCol], [ nBottom], [ nRight] )
/*oPrn:Box( 10, 01, 155, nHTam )
oPrn:Box( 09, 00, 154, nHTam )*/

oPrn:Box( nLin, 01, nLin+nEsp*3+nPdf, nHTam)
//oPrn:Box( nLin-1, 00, nLin+nEsp*3-1, nHTam )

If lPdf
	nLin += nEsp
EndIF

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

FscPrintCab(aCab1,aBox1,lpdf)

// ------------------
nLin += nEsp

Return(nLin)

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-|
// Função criada para retornar o posicionamento do box |
// de acordo com o tamanho da string enviada           |
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-|
Static Function FscRetTam(nLen, lDesconta)

Local nTam	  := 0
Local nMedida := 20 // para fontes 09

if oPrn:nDevice == 6
	nMedida := 19 // para fontes 09
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
Static Function FscPrintCab(aCab,aBox,lpdf)
*------------------------------------*
local ii

oPrn:Line(nLin  , 00, nLin  , nHTam )
If !lpdf
	oPrn:Line(nLin+2, 00, nLin+2, nHTam )
	oPrn:Line(nLin+4, 00, nLin+4, nHTam )
EndIF

oPrn:Box( nLin, 0, nLin+65, aBox[len (aBox)] )

For ii := 1 to len (aBox)
	oPrn:Line(nLin, aBox[ii], nLin+65, aBox[ii] ) //
Next ii

nLin += 15

For ii := 1 to len (aCab)
	If ii == 1
		oPrn:Say ( nLin , 040,aCab[1], oFontM)
	Else
		oPrn:Say ( nLin , aBox[ii-1]+IIf(lPdf,05,10),aCab[ii], oFontM)
	EndIf
Next ii

nLin += nEsp

oPrn:Line(nLin  , 00, nLin  , nHTam )
If !lpdf
	oPrn:Line(nLin+2, 00, nLin+2, nHTam )
	oPrn:Line(nLin+4, 00, nLin+4, nHTam )
EndIF

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
