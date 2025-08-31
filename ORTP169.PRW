#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"
#INCLUDE "TBICONN.CH"

User Function ORTP169(lSobMed)
    Local aPergs     := {}
    Local aRet       := {}
    Private cTitulo  := "Geracao Marfil"
    Private cSemana  := ""
    Private cCongela := ""
    Private cTipo    := ""
    Private cCalculo := ""
    Private a_Comps  := {}
    Default lSobMed  := .F.

    If cEmpAnt <> "03"
        MsgBox("O Acesso a esta rotina é exclusivo da unidade 03", "Unidade Invalida", "INFO")
        Return
    Endif

    aAdd( aPergs ,{1,"Semana         :" ,U_ORTP169A(),"@!"    ,".T."   ,'DA0' ,'.T.'                  , 80, .T.   })
    aAdd( aPergs ,{2,"Congela Precos :" ,"Nao"       ,{"Nao","Sim","Selecionados"}                   , 80, .F.,.F.})
    aAdd( aPergs ,{2,"Tipo de Produto:" ,'ACABADO'   ,{'ACABADO','SEMI-ACABADO e MATERIA-PRIMA'}      , 80, .F.,.F.})
    aAdd( aPergs ,{2,"Calculo        :" ,"Simulacao" ,{"Simulacao","Geracao"}                        , 80, .F.,.F.})
    aAdd( aPergs ,{2,"Permite reduo?:" ,"Nao"       ,{"Nao","Sim"}                   , 80, .F.,.F.})

    If !Parambox( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTR762" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
        Return
    EndIf

    cSemana  := PadL( MV_PAR01, 3, "0" )
    cCongela := MV_PAR02
    cTipo    := MV_PAR03
    cCalculo := MV_PAR04
    cReducao := MV_PAR05

    If lSobMed
        Processa( {|| SobMedida() }, "Aguarde...", "Calculando valores para os Sob-Medida...",.F.)
    Else
        Processa( {|| fMarfil(,,cSemana) }, "Aguarde...", "Calculando valores para a marfil...",.F.)
    Endif

Return

//------------------------
Static Function fMarfil(cProduto, cTp,cSemana)
    Local cAlias  := GetNextAlias()
    Local cQry    := ""
    Local cTabRef := "Z"+substr(cSemana,02,02)
    Local cTabGer := ""
    Local cItem   := ""
    Local _cProd  := ""
    Local _nCusto := 0
    Local _nVenda := 0
    Local lSemi   := .F.

    DEFAULT cProduto := ""
    DEFAULT cTp    := ""

    If cTp <> ""
        cTipo := cTp
    EndIf

    If cCalculo == "Simulacao"

        // A lógica da query para buscar os produtos continua a mesma
        cQry := "SELECT * FROM (SELECT CASE WHEN B1_TIPO = 'MP' OR LENGTH(TRIM(LEADING 0 FROM B1_COD)) <= 5 THEN 'MATERIA-PRIMA' WHEN B5_XSEMIAC = '1' OR (SELECT COUNT(*) AS REGISTROS FROM SIGA.SG1030 SG WHERE SG.G1_COMP = B1_COD AND SG.D_E_L_E_T_ = ' ' AND SG.G1_FILIAL = '02') > 0 OR (B1_TIPO IN ('MD', 'MB') AND B1_XMODELO = '999999' ) THEN 'SEMI-ACABADO' ELSE 'ACABADO' END AS TIPO, B1_XSEGMEN, B1_GRUPO, B1_TIPO, B1_COD, B1_DESC, B1_XALT, B1_XLARG, B1_XCOMP, B1_XQTDEMB, BM_MARKUP AS MARKUP, BM_XCONGP AS CONGELA, BM_XORDMIX, NVL( RMZA.ORDEM, 0 ) AS ORDEM_LINHA, RMZD.ORDEM AS ORDEM_MODELO, BM_XSUBGRU, NVL(RMZA.DESCRI, 0) AS LINHA, B1_XMODELO, RMZD.DESCRI AS MODELO FROM SIGA.SB1030 B1, SIGA.SBM200 SBM, SIGA.SB5030 SB5, SIGA.REGRASMAR RMZD, SIGA.REGRASMAR RMZA WHERE B1_FILIAL = '  ' AND B1.D_E_L_E_T_ = ' ' AND SB5.D_E_L_E_T_ (+) = ' ' AND B5_FILIAL (+) = '02' AND B1_MSBLQL <> '1' AND B5_COD (+) = B1_COD AND (B1_XFORLIN = ' ' OR  B1_XFORLIN >= TO_CHAR(ADD_MONTHS(SYSDATE, -12),'YYYYMMDD') ) AND B1_XCODBAS = ' ' AND BM_GRUPO = B1_GRUPO AND SBM.D_E_L_E_T_ = ' ' AND BM_FILIAL = '  ' AND RMZD.D_E_L_E_T_ = ' ' AND RMZD.TABELA = 'ZD' AND RMZD.CHAVE = B1_XMODELO AND RMZA.D_E_L_E_T_ (+)= ' ' AND RMZA.TABELA (+)= 'ZA' AND RMZA.CHAVE (+)= BM_XSUBGRU "
        If cProduto <> ''
            If cTp == 'A'
                cQry += "           AND B1_COD = '"+cProduto+"'"
            else
                cQry += "           AND B1_COD in '"+cProduto+"'"
            EndIf
        EndIf
        cQry += "           AND EXISTS (SELECT 'X' FROM SIGA.REGRASMAR RM WHERE RM.TABELA = 'SBM' AND RM.D_E_L_E_T_ = ' ' AND RM.CHAVE = B1_GRUPO AND RM.MARFIL = 'S')) WHERE 1=1 "
        If cTipo == 'ACABADO'
            cQry += "   AND TIPO = 'ACABADO' OR B1_XMODELO = '000011'"
        Endif
        If cTipo == 'SEMI-ACABADO'
            cQry += "   AND TIPO = 'SEMI-ACABADO'"
        Endif
        If cTipo == 'MATERIA-PRIMA'
            cQry += "   AND TIPO = 'MATERIA-PRIMA'"
        Endif
        If cTipo == 'SEMI-ACABADO e MATERIA-PRIMA'
            cQry += "   AND TIPO in ('MATERIA-PRIMA', 'SEMI-ACABADO')"
        Endif
        cQry += " ORDER BY TIPO, B1_XSEGMEN, BM_XORDMIX, ORDEM_MODELO, ORDEM_LINHA, B1_GRUPO, B1_XLARG, B1_COD"

        cAlias := U_ORTQUERY(cQry,cAlias)

        If cTipo == 'ACABADO'
            cTabGer := cSemana
            lSemi   := .F.
        Endif
        If cTipo == 'SEMI-ACABADO' .OR. cTipo == 'MATERIA-PRIMA' .OR. cTipo == 'SEMI-ACABADO e MATERIA-PRIMA'
            cTabGer := "Z"+substr(cSemana,02,02)
            lSemi   := .T.
        Endif

        Begin Transaction
            cItem := "0000"
            Do While  !(cAlias)->(EOF())
                IncProc()
                cItem   := soma1(cItem)
                _cProd  := (cAlias)->B1_COD

                aPreco := CalcPr(_cProd, cTabRef)
                _nCusto := aPreco[1]
                _nVenda := aPreco[2]

                If _nCusto > 0
                    GravaPr(cTabGer, cItem, _cProd, _nVenda, _nCusto)
                Endif

                (cAlias)->(dbskip())
            EndDo
        End Transaction

        (cAlias)->(DBCLOSEAREA())

    ElseIf cCalculo <> "Simulacao"
        UPDATEDA1(cSemana)
    Endif

    msgInfo("Processo finalizado!","Sucesso")

Return

//------------------------
Static Function SobMedida()
    Local cQry := ""
    Local cAlias := ""
    Local aPrecoM3 := {}
    Local _cGrupo := ""
    Local cItem := "0000"

    cQry := " SELECT DISTINCT CHAVE FROM SIGA.REGRASMAR WHERE TABELA = 'SBM' AND SOBMED = 'S' AND D_E_L_E_T_ = ' ' "
    cAlias := U_ORTQUERY(cQry)

    Do While  !(cAlias)->(EOF())
        _cGrupo := (cAlias)->CHAVE
        aPrecoM3 := CalcSM(_cGrupo, cSemana)

        If aPrecoM3[1] > 0
            cItem := soma1(cItem)
            GrvPrSM(cSemana, _cGrupo, aPrecoM3[2], aPrecoM3[1])
        Endif

        (cAlias)->(dbskip())
    EndDo

    (cAlias)->(DBCLOSEAREA())

    msgInfo("Processo finalizado!","Sucesso")
Return

//ROTINA DE GRAVAÇÃO
Static Function fGeraMov(cTab)
    MvDa1(cTab)
Return


//ROTINA DE ATUALIZAÇÃO
Static Function UPDATEDA1(cTab)
    UpdPda1(cTab)
Return


//-------------------------------------------------------------------
// Funções para a tabela de Produtos (SB1)
//-------------------------------------------------------------------

Static Function GetPrd(cProduto)
    Local aProduto := {}
    Local cProd := ALLTRIM(cProduto)
    dbSelectArea("SB1")
    dbSetOrder(1) // Ordem por Filial+Produto
    If dbSeek(xFilial("SB1") + cProd)
        aProduto := {;
            SB1->B1_COD,;
            SB1->B1_DESC,;
            SB1->B1_GRUPO,;
            SB1->B1_XMODELO,;
            SB1->B1_XLARG,;
            SB1->B1_XCOMP,;
            SB1->B1_XALT;
        }
    Endif
RETURN aProduto

//-------------------------------------------------------------------
// Funções para a tabela de Composição (SG1)
//-------------------------------------------------------------------

Static Function CompGet(cProduto)
    Local aComponentes := {}
    Local aAreaSG1     := SG1->(GetArea())
    dbSelectArea("SG1")
    dbSetOrder(1) // Ordem por Filial+ProdutoPai+Componente
    If dbSeek(xFilial("SG1") + cProduto)
        While !EOF() .and. Alltrim(G1_FILIAL + G1_COD) == xFilial("SG1") + cProduto
            AAdd(aComponentes, {SG1->G1_COMP, SG1->G1_QUANT})
            dbSkip()
        EndDo
    Endif

    RestArea(aAreaSG1)

RETURN aComponentes

//-------------------------------------------------------------------
// Funções para a tabela de Custos (ZZM e DA1)
//-------------------------------------------------------------------

Static Function GetCs(cProduto, cTabela)
    Local nCusto := 0
    Local cQry := ""
    Local cAlias := ""
    Local nComps := 0

    // 1. Tenta buscar o custo na ZZM
    cQry  := "SELECT ZZM_TOTAL FROM (SELECT ZZM_COD, ZZM_DESC, ZZM_DATA, ZZM_TOTAL, ROWNUM AS LINHA FROM (SELECT * FROM SIGA.ZZM030 ZZM WHERE ZZM.D_E_L_E_T_ = ' ' AND ZZM_FILIAL = '  ' AND ZZM_COD = '"+cProduto+"' AND ZZM_ANOTAB = '"+ alltrim(str(Year(dDataBase))) + "' AND ZZM_CODTAB = '"+cTabela+"' ORDER BY ZZM_COD, ZZM_DATA DESC, ZZM_PICM DESC, R_E_C_N_O_)) WHERE LINHA = 1"
    cAlias := U_ORTQUERY(cQry, "EXZZMT")
    If  !(cAlias)->(EOF())
        nCusto := (cAlias)->ZZM_TOTAL
    Else
        If aScan(a_Comps,{|x| x=cProduto}) = 0
            nComps := Len(CompGet(ALLTRIM(cProduto)))
            u_ortsmail("dyonathan.carrilho@ortobom.com.br", "Problema com o custo do produto "+cProduto+ "Componentes :"+cValToChar(nComps),"Problema com custo!","")
            AADD(a_Comps,cProduto)
        EndIf
    Endif
    (cAlias)->(DBCLOSEAREA())

    // 2. Se não encontrou na ZZM, busca na DA1
    If nCusto == 0
        cQry := "SELECT DA1_XCUSTO FROM SIGA.DA1030 WHERE D_E_L_E_T_ = ' ' AND DA1_FILIAL = '"+xFilial("DA1")+"' AND DA1_CODTAB = '"+cTabela+"' AND DA1_CODPRO = '"+cProduto+"'"
        cAlias := U_ORTQUERY(cQry,"RETDA1")
        If !(cAlias)->(EOF())
            nCusto := (cAlias)->DA1_XCUSTO
        Endif
        (cAlias)->(DBCLOSEAREA())
    Endif

RETURN nCusto

//-------------------------------------------------------------------
// Funções para a tabela de Grupos de Produto (SBM)
//-------------------------------------------------------------------

Static Function GrpInfo(cGrupo)
    Local aGrupoInfo := {}
    Local aAreaSBM := SBM->(GetArea())
    dbSelectArea("SBM")
    dbSetOrder(1) // Ordem por Filial+Grupo
    If dbSeek(xFilial("SBM") + cGrupo)
        aGrupoInfo := {;
            SBM->BM_GRUPO,;
            SBM->BM_MARKUP,;
            SBM->BM_XGERSOB,;
            SBM->BM_XPRDPAD;
        }
    Endif

    RestArea(aAreaSBM)

RETURN aGrupoInfo

//-------------------------------------------------------------------
// Funções para cálculo de preço
//-------------------------------------------------------------------

Static Function CalcPr(cProduto, cTabelaRef)
    Local i      := 0
    Local nCusto := 0
    Local nPrecoVenda := 0
    Local nMarkup := 1
    Local aProduto
    Local aGrupoProduto
    Local aComponentes
    Local aComponente
    Local aAreaSB1 := SB1->(GetArea())

    aProduto := GetPrd(cProduto)
    If Empty(aProduto)
        Return {0, 0}
    Endif

    aGrupoProduto := GrpInfo(aProduto[3])
    If !Empty(aGrupoProduto) .And. aGrupoProduto[2] > 0 .And. nMarkup > 0
        nMarkup := aGrupoProduto[2]
    Endif

    aComponentes := CompGet(ALLTRIM(cProduto))

    If Len(aComponentes) > 0
        For i=1 to Len(aComponentes)
            nCusto += CalcPr(aComponente[1], cTabelaRef)[1] * aComponente[2]
            i++
        Next
    Else
        nCusto := GetCs(cProduto, cTabelaRef)
    Endif

    If cTipo == 'SEMI-ACABADO e MATERIA-PRIMA' 
        nCusto := nCusto * 1.05
    Endif

    nPrecoVenda := nCusto * nMarkup

    RestArea(aAreaSB1)

RETURN {Round(nCusto, 2), Round(nPrecoVenda, 2)}

//-------------------------------------------------------------------
// Funções para cálculo de preço de sob medida
//-------------------------------------------------------------------

Static Function CalcSM(cGrupo, cTabelaRef)
    Local nCustoM3 := 0
    Local nVendaM3 := 0
    Local aGrupoProduto
    Local aProdutoBase
    Local nVolumeBase := 0
    Local nCustoBase := 0
    Local nMarkup := 1

    aGrupoProduto := GrpInfo(cGrupo)
    If Empty(aGrupoProduto) .or. Empty(aGrupoProduto[4])
        Return {0, 0}
    Endif

    aProdutoBase := GetPrd(aGrupoProduto[4])
    If Empty(aProdutoBase)
        Return {0, 0}
    Endif

    aCustoBase := CalcPr(aProdutoBase[1], cTabelaRef)
    nCustoBase := aCustoBase[1]
    nVolumeBase := aProdutoBase[5] * aProdutoBase[6] * aProdutoBase[7]
    nMarkup := aGrupoProduto[2]

    If nVolumeBase == 0
        Return {0, 0}
    Endif

    nCustoM3 := ((nCustoBase / nVolumeBase) * 1.15)
    nVendaM3 := nCustoM3 * nMarkup

    nCustoM3 := (Floor(nCustoM3 / 100) * 100) + 1
    nVendaM3 := (Floor(nVendaM3 / 100) * 100) + 1

RETURN {nCustoM3, nVendaM3}

//-------------------------------------------------------------------
// Função para movimentação de preço
//-------------------------------------------------------------------

Static Function MvDa1(cTabela)
    Local cQry := ""
    Local cAlias := GetNextAlias()

    cQry := "SELECT * FROM SIGA.PREDA1030 WHERE DA1_CODTAB = '" + cTabela + "'"
    cAlias := U_ORTQUERY(cQry, cAlias)

    If !(cAlias)->(EOF())
        MsgInfo("Iniciando a movimentação de dados da tabela temporária para a principal. Tabela: " + cTabela)
    Else
        MsgInfo("Nenhum registro encontrado na tabela temporária (PREDA1030) com DA1_CODTAB = '" + cTabela + "'.")
        (cAlias)->(dbCloseArea())
        Return
    Endif

    Begin Transaction
    Do While !(cAlias)->(EOF())
        RecLock("DA1", .T.)
        DA1->DA1_FILIAL := xFilial("DA1")
        DA1->DA1_CODTAB := (cAlias)->DA1_CODTAB
        DA1->DA1_CODPRO := (cAlias)->DA1_CODPRO
        DA1->DA1_ITEM   := (cAlias)->DA1_ITEM
        DA1->DA1_PRCVEN := (cAlias)->DA1_XMARCS //Campo para TESTE
        DA1->DA1_XCUSTO := (cAlias)->DA1_XMARPR //Campo para TESTE
        DA1->DA1_DTUMOV := dDatabase
        DA1->DA1_HRUMOV := Time()
        DA1->DA1_ATIVO  := "1"
        DA1->DA1_TPOPER := "4"
        DA1->DA1_QTDLOT := 999999.99
        DA1->DA1_INDLOT := "000000000999999.99"
        DA1->DA1_MOEDA  := 1
        DA1->DA1_PERDES := 0
        MsUnLock()
        (cAlias)->(dbSkip())
    EndDo
    End Transaction

    (cAlias)->(dbCloseArea())
    MsgInfo("Movimentação de dados finalizada com sucesso!")
RETURN

//-------------------------------------------------------------------
// Função para gravação da simulação PREDA1
//-------------------------------------------------------------------

Static Function GravaPr(cTabela, cItem, cProduto, nPrecoVenda, nCusto)
    Local cInsert := "INSERT INTO SIGA.PREDA1030 (DA1_CODTAB, DA1_ITEM, DA1_CODPRO, DA1_PRCVEN, DA1_XCUSTO, DA1_DTUMOV, DA1_HRUMOV) VALUES ('"+cTabela+"','"+cItem+"','"+cProduto+"', "+Alltrim(Str(nPrecoVenda))+", "+Alltrim(Str(nCusto))+", '"+dtos(dDatabase)+"','"+time()+"')"
    TcSqlExec(cInsert)
RETURN

Static Function GrvPrSM(cTabela, cGrupo, nVendaM3, nCustoM3)
    RecLock("SZV",.T.)
    SZV->ZV_FILIAL  := xFilial("SZV")
    SZV->ZV_GRUPO   := cGrupo
    SZV->ZV_TABELA  := cTabela
    SZV->ZV_CUSTO   := nCustoM3
    SZV->ZV_VENDA   := nVendaM3
    SZV->ZV_VENAME  := nVendaM3
    MsUnLock()
RETURN

//-------------------------------------------------------------------
// Função para atualização de custo na DA1
//-------------------------------------------------------------------

Static Function AtuCSDA1(cTabela, cProduto, nNovoCusto)
    Local cChave := xFilial("DA1") + cTabela + cProduto
    Local lEncontrado := .F.
    Local lRecLockOk := .F.

    dbSelectArea("DA1")
    dbSetOrder(7) // Ordem por Filial+Tabela+Produto

    lEncontrado := dbSeek(cChave)

    If lEncontrado
        lRecLockOk := RecLock("DA1", .F.)
        If lRecLockOk
            DA1->DA1_XCUSTO := nNovoCusto
            DA1->(MsUnLock())
        EndIf
    EndIf
RETURN

Static Function UpdPda1(cTabela)
    Local cQry := ""
    Local cAlias := GetNextAlias()
    Local cChave := ""
    Local lEncontrado := .F.
    Local lRecLockOk := .F.

    cQry := "SELECT DA1_CODTAB, DA1_CODPRO, DA1_ITEM, DA1_XCUSTO, DA1_PRCVEN FROM SIGA.PREDA1030 WHERE DA1_CODTAB <= '" + cTabela + "'"
    cAlias := U_ORTQUERY(cQry, cAlias)

    If !(cAlias)->(EOF())
        MsgInfo("Iniciando a atualização da tabela de preço '" + cTabela + "'. Por favor, aguarde...")
    Else
        MsgInfo("Nenhum registro encontrado na tabela de origem (PREDA1030) com DA1_CODTAB = '" + cTabela + "'.")
        (cAlias)->(dbCloseArea())
        Return
    Endif

    Begin Transaction
    Do While !(cAlias)->(EOF())
        cChave := xFilial("DA1") + (cAlias)->DA1_CODTAB + (cAlias)->DA1_CODPRO
        dbSelectArea("DA1")
        dbSetOrder(7) // Ordem por Filial+Tabela+Produto

        lEncontrado := dbSeek(cChave)

        If lEncontrado
            lRecLockOk := RecLock("DA1", .F.)
            If lRecLockOk
                DA1->DA1_XCUSTO := (cAlias)->DA1_XCUSTO
                DA1->DA1_PRCVEN := (cAlias)->DA1_PRCVEN
                DA1->(MsUnLock())
            EndIf
        Else
            RecLock("DA1", .T.)
            DA1->DA1_FILIAL := xFilial("DA1")
            DA1->DA1_CODTAB := (cAlias)->DA1_CODTAB
            DA1->DA1_CODPRO := (cAlias)->DA1_CODPRO
            DA1->DA1_ITEM   := (cAlias)->DA1_ITEM
            DA1->DA1_PRCVEN := (cAlias)->DA1_XMARCS //Campo para TESTE
            DA1->DA1_XCUSTO := (cAlias)->DA1_XMARPR //Campo para TESTE
            DA1->DA1_DTUMOV := dDatabase
            DA1->DA1_HRUMOV := Time()
            DA1->DA1_ATIVO  := "1"
            DA1->DA1_TPOPER := "4"
            DA1->DA1_QTDLOT := 999999.99
            DA1->DA1_INDLOT := "000000000999999.99"
            DA1->DA1_MOEDA  := 1
            DA1->DA1_PERDES := 0
            MsUnLock()
            (cAlias)->(dbSkip())
        EndIf
    EndDo
    End Transaction

    (cAlias)->(dbCloseArea())
    MsgInfo("Processo de atualização finalizado com sucesso!")
RETURN

User Function ORTP169A(lNext,lPrev)
	Local cTab    := space(3)
	Local cQry    := ""
	Local cAlias  := ""
	Default lNext := .F.
	Default lPrev := .F.

	cQry := "SELECT MAX(DA0_CODTAB) as CODTAB FROM SIGA.DA0030 WHERE DA0_DATDE <= '"+dtos(ddatabase)+"' AND DA0_DATATE >= '"+dtos(ddatabase)+"' AND D_E_L_E_T_ = ' '

	cAlias := U_ORTQUERY(cQry)

	If  !(cAlias)->(EOF())
		cTab := (cAlias)->CODTAB
	Endif

	If lNext
		If VAL(cTab)+1 >= 52
			cTab := '001'
		Else
			cTab := STRZERO(VAL(cTab)+1,3)
		Endif
	Endif

	If lPrev
		If VAL(cTab)-1 <= 0
			cTab := '052'
		Else
			cTab := STRZERO(VAL(cTab)-1,3)
		Endif
	Endif

	(cAlias)->(DBCLOSEAREA())

Return cTab
