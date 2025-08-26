#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"
#INCLUDE "TBICONN.CH"



User Function ORTR813D()

Local cQry		:= ""
Local nTotal 	:= 0
Local nBl 		:= 0
Local nTotPeso 	:= 0
Local nTotCus 	:= 0
Local nF        := 0
		

Private aPergs    := {}
Private aRet	  := {}
Private cTitulo	  := "Blocos"
Private nomeprog  := "ORTR813D"
Private cGrupoDe  := space(4)
Private cGrupoAte := "ZZZZ"
Private cProdDe   := space(10)
Private cProdAte  := "ZZZZZZZZZZ"
Private aReport	  := {}
Private cTab      := "   "
Private cEmpresa  := "  "
Private aProdutos := {}
Private aComp     := {}
Private nCount    := 0
Private nPos      := 0
Private nContBl     := 0
Private aBlocos :={}
Private aItens := {}

	if cEmpAnt <> "03"
		Alert("O Acesso a esta rotina é exclusivo da unidade 03", "Unidade Invalida", "INFO")
		return
	endif
    
// PERGUNTAS
aAdd( aPergs ,{1,"Semanas"             , cTab      , ""    , ".T."	, , '.T.', 3,.T.})
aAdd( aPergs ,{1,"Empresa"            , cEmpresa	, ""	  , ".T." , 'SBM', '.T.', 50,.F.})
aAdd( aPergs ,{1,"Produto de"         , cProdDe	  , ""	  , ".T." , 'SB1', '.T.', 50,.F.})
aAdd( aPergs ,{1,"Produto Ate"        , cProdAte	, ""    , ".T."	, 'SB1', '.T.', 50,.T.})
aAdd( aPergs ,{2,"Visualizar     :" ,"Gerados",{"Simulacao","Gerados"}                        , 80, .F.,.F.})

If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, nomeprog + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
	Return
EndIf

cTab      := 'Z' + substr(MV_PAR01,2, 2)
cEmpresa  := MV_PAR02
cProdDe   := MV_PAR03
cProdAte  := MV_PAR04
cCalculo  := MV_PAR05


cQry := " SELECT PRODUTO, G1_COMP, B1A.B1_DESC DESCBL , B1B.B1_DESC DESCCOMP, G1_QUANT, DA1_XCUSTO, NVL(b5a.B5_XAGUA, 0) B5_XAGUA, "
cQry += " B1A.B1_XQTDEMB, B1A.B1_XALT, B5A.B5_DENSID, B1A.B1_XDENSEQ "
cQry += "  FROM SIGA.MAR_BLOCOS_POR_UN BL "
cQry += "  					INNER JOIN SIGA.SG1030 G1 ON G1_FILIAL = '02' "
cQry += "                           AND PRODUTO = TRIM(G1_COD) "
cQry += "                           AND G1.D_E_L_E_T_ = ' ' "
cQry += "  					INNER JOIN SIGA.SB1030 B1A ON B1A.B1_FILIAL = ' '
cQry += "                           AND B1A.B1_COD = G1_COD  "
cQry += "                           AND B1A.D_E_L_E_T_ = ' ' "
cQry += "  					LEFT JOIN SIGA.SB5030 B5A ON B5A.B5_FILIAL = '02'
cQry += "                           AND B1A.B1_COD = B5A.B5_COD  "
cQry += "                           AND B1A.D_E_L_E_T_ = ' ' "

cQry += "  					INNER JOIN SIGA.SB1030 B1B ON B1B.B1_FILIAL = ' '
cQry += "                           AND B1B.B1_COD = G1_COMP 
cQry += "                           AND B1B.D_E_L_E_T_ = ' ' "

cQry += "  					LEFT JOIN SIGA.SB5030 B5B ON B5B.B5_FILIAL = '02'
cQry += "                           AND B1B.B1_COD = B5B.B5_COD 
cQry += "                           AND B1B.D_E_L_E_T_ = ' ' "

If cCalculo == "Simulacao"

	cQry += "  					INNER JOIN SIGA.PREDA1030 DA1 ON  " 

Else

	cQry += "  					INNER JOIN SIGA.DA1030 DA1 ON DA1_FILIAL = ' ' AND " 
	cQry += "                           DA1.D_E_L_E_T_ = ' ' AND  "

Endif


cQry += "                            DA1_CODTAB = '" + cTab +"' "
cQry += "                           AND DA1_CODPRO = G1_COMP  "
cQry += " WHERE PRODUTO >= '"+cProdDe+"' "
cQry += "   AND PRODUTO <= '"+cProdAte+"' "
cQry += "   AND UN = '"+cEmpresa+"' " //and produto in(  '2010210331', '2010210337', '2010210163','2010210160', '2010112512') "
cQry += "   AND PLAN_BLOCOS = '1' "

cQry += " ORDER BY PRODUTO, G1_COMP  "

U_ORTQUERY(cQry, "OTR813D")
ProcRegua((cAlias)->registros)

While OTR813D->(!EOF())



	nPos := aScan(aComp,{|X|X[1]== OTR813D->G1_COMP	})

	If nPos == 0

		AaDd( aComp, {OTR813D->G1_COMP, OTR813D->DESCCOMP } )	

	EndIf
	
	nPos := aScan(aBlocos,{|X|X[1]== OTR813D->PRODUTO	})

	iF nPos == 0

		AaDd( aBlocos, {OTR813D->PRODUTO, OTR813D->DESCBL } )	

	EndIf

		AADD(	aItens,{ OTR813D->PRODUTO	,; //1
							OTR813D->G1_COMP    	,; //2							
							OTR813D->G1_QUANT					,	;//3
							OTR813D->DA1_XCUSTO					,   ;//4
							OTR813D->DA1_XCUSTO*OTR813D->G1_QUANT, ; //5
							0 ,;//6
							OTR813D->B5_XAGUA	,; //7
							0,;//peso total 8
							0,;// evap kg 9
							0,;//evap m3 10
							OTR813D->B1_XQTDEMB,; // peso medio 11
							OTR813D->B1_XALT    ,;// 12
							OTR813D->B5_DENSID,;//13
							0,;//14
							OTR813D->B1_XDENSEQ,;//15
							0,;//16
							0,;//17
							0;//18
							} )//5

	
	OTR813D->(dbSkip())

EndDo

IF Len(aBlocos) > 0

	IncProc()

		
	For nBl := 1 to Len(aBlocos)

		nTotal 		:= 0
		nTotPeso 	:= 0
		nTotCus 	:= 0
		

		for nF := 1 to Len(aItens)

			If aItens[nF][1] == aBlocos[nBl][1]

				nTotal += aItens[nF][5]

				nTotCus += aItens[nF][5]
				
				If substr(aItens[nF][2], 6,1) == '1'
					
					nTotPeso+= aItens[nF][3]
				
				EndIf
			
			EndIf			
		
		Next

		for nF := 1 to Len(aItens)
			
			If aItens[nF][1] == aBlocos[nBl][1]

				aItens[NF][6] := ROUND((100 / nTotal ) * ( aItens[nF][5] ) , 2	)
				aItens[NF][8] := nTotPeso + aItens[NF][7]
				aItens[NF][9] := aItens[NF][8] - aItens[NF][11]
				aItens[NF][10] := (aItens[NF][9] / aItens[NF][8] ) * 100
				aItens[NF][16] := nTotCus
				aItens[NF][17] := aItens[NF][16] / aItens[NF][11]
				aItens[NF][18] := aItens[NF][16] / aItens[NF][13]
				
			EndIf
		
		Next


	Next

Else

	Alert("Não foram encontrados registros com os dados informados.")	

Endif


fPrint(aBlocos, aComp, aItens)

Return


Static Function fPrint( aBlocos, aComp, aItens )

Private titulo   := "PLANILHA DE BLOCOS- SEMANA : " + cTab + " "
Private nomeprog := "ORTR813D"
Private _aHead	 := {}
Private _aItens	 := aProdutos
Private lRetrato := .f.  // indica se imprime no formato retrato ou nao
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
Private nHTam		:= 3100//2380 // limite horizontal da pagina no modo paisagem
Private nLimite 	:= 3300 // limite onde irá ocorrer a quebra de pagina no modo paisagem
Private aObjt		:= {}
Private nPdf	    := 0

Default aObj		:= {}
Default lPdf		:= .F.
Default cCaminho    := ""
Default lCSV		:= .F.

aObjt := aObj

nEsp 		:= 50
nPdf	    := 0

nLin       	:= 3500
nHTam		:= 3100//3384 // limite horizontal da pagina no modo paisagem
nLimite 	:= 2200 // limite onde irá ocorrer a quebra de pagina no modo paisagem		

If !File(cLogo)
	cLogo := "lgrl" + cFilAnt + ".bmp"
EndIf

if len(aItens) == 0 
	alert("Não a dados a serem impressos")
	return
endif



dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilAnt)
cNomFil  := SM0->M0_FILIAL

oFontM	:= TFont():New('Courier New',, 11,, .T.,,,,,.F.,.F.)

	oPrn := TReport():New(nomeprog,Titulo,,{|oPrn|GrR(oPrn, lPdf)  },Titulo)
	
		oPrn:SetLandscape()
		oPrn:SetEdit(.F.)         // Bloqueia personalizar
		oPrn:NoUserFilter()       // nao permite criar Filtro de usuario
		oPrn:DisableOrietation()  // não permite alterar a orientação da pagina
		oPrn:HideHeader()         // oculta o cabeçalho padrão
		oPrn:HideFooter()
		oPrn:PrintDialog()	
	
Return


Static Function GrR(oPrn,lpdf)

	oPrn:SetLandscape()

	//oPrn:oPage:nPaperSize == 9
	//oPrn:oReport:oPage:nPaperSize == 9

	if oPrn:nDevice == 6
		
		oFontM	:= TFont():New('Courier new',, 10,, .T.,,,,,.F.,.F.)
		oFontP	:= TFont():New('Courier new',, 09,, .T.,,,,,.F.,.F.)
		oPrn:Init()
		oPrn:oprint:nMargLeft   := 40
		oPrn:oPrint:lPDFasPNG 	:= .T.
		oPrn:oPrint:nPageWidth 	:= 2380
		oPrn:nPageWidth 		:= 2380
		oPrn:oPrint:lServer 	:= .T.
		nHTam		:= 3100//2380 // limite horizontal da pagina no modo paisagem
		if !lRetrato
			oPrn:oPrint:nPageWidth 	:= 3380
			oPrn:nPageWidth 		:= 3380
			nHTam		:= 3100//3384 // limite horizontal da pagina no modo paisagem
		endif
	Endif

//FscFillBox(_aHead,_aItens)

//RptStatus({|| GeraRel(oPrn) },Titulo)
Processa( {|| GeraRel(oPrn) }, "Aguarde...", "Gerando relatorio...",.F.)

Return


Static Function GeraRel(oPrn)

Local nCntProd	:= 0
Local h			:= 0
Local nComp 	:= 0
Local nBlocos 	:= 0
Local nCompl    := 0

local aBox1 := {700, 1300, 1900, 2500, 3100, 3700}
Local aCompl:= {"Agua", "Peso Total", "Evaporacao(KG)", "Evaporacao(%)", "Peso Medio" ,"Altura", "Volume", "Densidade Fabril", "Densidade Enquadramento", "Bloco", "KG", "M3"}


//aBlocos, aComp, aItens

//SetRegua(len())


nMax := len(aComp)
nBlocos := 0
For nBlocos:=1 to len(aBlocos) // Loop de colunas, blocos

	// quantidade de blocos por pg
	If nBlocos + 4 > len(aBlocos) 

		nMax := len(aBlocos)  - nBlocos

	Else

		nMax := 4

	EndIf
	
	// loop na composição dos 4 blocos da pagina
	For nComp:=1 to len(aComp) // Loop de colunas, blocos
		
		lComp := .F.
		nBlInt := nBlocos

		// imprime caceb
		If nComp == 1

			nLin := fImpCab("1", oPrn, aBlocos)
			lComp := .T.

			oPrn:Say ( nLin-10, 10, "DESCRICAO                " , oFontM)

			for nCntProd := 1 to nMax//Len(aBlocos)

				oPrn:Say ( nLin-10, aBox1[nCntProd]+40, aBlocos[nBlInt][1]  + " " + substr(aBlocos[nBlInt][2], 1, 15) , oFontM)
				nBlInt++

			Next

			oPrn:Line(nLin + nEsp , 00, nLin+ nEsp  , nHTam )
			

			nLin += nEsp
			nLinIni := nLin
			
			for nCntProd := 1 to nMax//Len(aBlocos)

				oPrn:Say ( nLin+10, aBox1[nCntProd]+60,  "QTDE"  , oFontM)
				oPrn:Say ( nLin+10, aBox1[nCntProd]+225, "VL.TOTAL" , oFontM)
				oPrn:Say ( nLin+10, aBox1[nCntProd]+435, "% PART" , oFontM)
				
			Next
		
			oPrn:Line(nLin + nEsp , 00, nLin + nEsp , nHTam )

			nLin += nEsp
			nLin += nEsp

		EndIf	// fim cabec
		
		//	IncRegua()

		nBlInt := nBlocos
		lImpComp := .f.

		// Verifica se a materia prima (g1_comp) vai ter valor em algum dos blocos da pg, não tendo não imprime
		for h:=1 to nMax//len(aBlocos)

			nPos := aScan(aItens,{|X|X[1]+X[2]== aBlocos[nBlInt][1]+aComp[nComp][1]	})

			iF nPos <> 0 .and. aItens[nPos][3] <> 0

				lImpComp := .t.
				exit

			EndIf

			nBlInt++

		Next

		If lImpComp
		
		nBlInt := nBlocos
			
			for h:=1 to nMax//len(aBlocos)

				If h == 1

					oPrn:Say ( nLin+10, 10, alltrim(aComp[nComp][1]) + " " + substr(aComp[nComp][2], 1, 25) , oFontM)
				
				EndIf

				nPos := aScan(aItens,{|X|X[1]+X[2]== aBlocos[nBlInt][1]+aComp[nComp][1]	})

				iF nPos <> 0

					oPrn:Say ( nLin+10, aBox1[h]+30,  Transform(aItens[nPos][3],"@E 999.9999")  , oFontM)
					oPrn:Say ( nLin+10, aBox1[h]+220, Transform(aItens[nPos][5],"@E 9999.9999") , oFontM)
					oPrn:Say ( nLin+10, aBox1[h]+470, Transform(aItens[nPos][6],"@E 99.99") , oFontM)
				
				EndIf
				
				nBlInt++

			next h

			nLin += nEsp

		EndIf	
		
	Next

	If nMax <> 0
		
		oPrn:Line(nLin  , 00, nLin , nHTam )
		nLin += nEsp
		For nCompl := 1 to Len(aCompl)

			//if nCompl == 1

				oPrn:Say ( nLin+10, 200,  aCompl[nCompl] , oFontM)

		//	EndIf
			nBlInt := nBlocos 

			for h:=1 to nMax//len(aBlocos)

				nPos := aScan(aItens,{|X|X[1]== aBlocos[nBlInt][1]	})

				iF nPos <> 0

					oPrn:Say ( nLin+10, aBox1[h]+50,  Transform(aItens[nPos][nCompl+6],"@E 9999.99")  , oFontM)
				
				EndIf

				nBlInt++
				oPrn:Line(155   ,  aBox1[h]+15 ,nLin + nEsp , aBox1[h] +15)
				oPrn:Line(nLinIni  ,  aBox1[h]+205,nLin + nEsp , aBox1[h] +205)
				oPrn:Line(nLinIni  ,  aBox1[h]+405,nLin + nEsp , aBox1[h] +405)
				
			next h

			oPrn:Line(155  ,  aBox1[h],nLin + nEsp , aBox1[h] )

			nLin += nEsp


			for h := 1 to nMax


				oPrn:Line(155   ,  aBox1[h]+15 ,nLin + nEsp , aBox1[h] +15)
				oPrn:Line(nLinIni  ,  aBox1[h]+205,nLin + nEsp , aBox1[h] +205)
				oPrn:Line(nLinIni  ,  aBox1[h]+405,nLin + nEsp , aBox1[h] +405)
					

			Next
		
		

		Next
	
	EndIf

	oPrn:Line(nLin + nEsp , 00, nLin + nEsp , nHTam )


If nBlocos == Len(aBlocos)

	nBlocos := nBlInt  

Else

	nBlocos := nBlInt-1  

EndIf
		

Next
	

MS_FLUSH()
Return


Static Function fImpCab(cTp, oPrn, aBloco)

nPag	+= 1

If nPag > 1
	oPrn:EndPage()
EndIf

oPrn:StartPage()


oPrn:SetLandscape()

nLin := 10

oPrn:Box( nLin, 01, nLin+nEsp*3, nHTam)


// Lado Esquerdo
oPrn:Say ( nLin, 10, "Hora: " + cHora + " - (" + nomeprog + ")"     , oFontM)
oPrn:Say ( nLin+nEsp*2, 10, "Empresa: " + cEmpresa  , oFontM)

// Centro
oPrn:Say ( nLin+nEsp , 10, PADC(AllTrim(Upper(titulo)), 119 ), oFontM)

// Lado Direito
nTam := IIf(lPdf,05,20)*( Len("Emissão:" + Dtos(Date())) )+IIf(lPdf,10,40)
oPrn:Say ( nLin, nHTam-nTam, "Folha: " + AllTrim(Str(nPag)), oFontM)
oPrn:Say ( nLin+nEsp*2, nHTam-nTam, "Emissão:" + DtoC(Date()), oFontM)

	nLin += nEsp*3
//nLin	:= 170        
    nEspC := 40    
	// mbc  oPrn:Box(nLin,01,nLin+nEsp*len(aBloco),nHTam)
		
/*For cb:=1 to len(aBloco)

	oPrn:Say(nLin,nCol,alltrim(aBloco[cb]),oFontM)
	nCol += nEspC 

next cb 
*/

nEspC := 40    
// mbc oPrn:Box(nLin,01,nLin+nEsp*len(aBloco),nHTam)
		

//FscPrintCab(aCab1,aBox1,lpdf)

// ------------------
nLin += nEsp

Return(nLin)




*---------------------------------------*
Static Function FscFillBox(aHead,aItens)
*---------------------------------------*
local cFinal := ""
local aColuna:= {}
local iy, ix

For ix:=1 to Len(aHead)
	aColuna := {}
	
	For iy:=1 to Len(aItens)
		if empty(aItens[iy]) .or. aItens[iy][ix] $ "AGRUPAMENTO:GRUPO:" 
			loop
		endif            
		aadd(aColuna, aItens[iy][ix+1])
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
