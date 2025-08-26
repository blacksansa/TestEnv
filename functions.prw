#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
// Funções para a tabela de Produtos (SB1)
//-------------------------------------------------------------------

Static Function Produto_Get(cProduto)
    Local aProduto := {}
    dbSelectArea("SB1")
    dbSetOrder(1) // Ordem por Filial+Produto
    If dbSeek(xFilial("SB1") + cProduto)
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

Static Function Composicao_GetComponentes(cProduto)
    Local aComponentes := {}
    dbSelectArea("SG1")
    dbSetOrder(1) // Ordem por Filial+ProdutoPai+Componente
    If dbSeek(xFilial("SG1") + cProduto)
        While !EOF() .and. G1_FILIAL + G1_COD == xFilial("SG1") + cProduto
            AAdd(aComponentes, {SG1->G1_COMP, SG1->G1_QUANT})
            dbSkip()
        EndDo
    Endif
RETURN aComponentes

//-------------------------------------------------------------------
// Funções para a tabela de Custos (ZZM e DA1)
//-------------------------------------------------------------------

Static Function Custo_Get(cProduto, cTabela)
    Local nCusto := 0
    Local cQry := ""
    Local cAlias := ""

    // 1. Tenta buscar o custo na ZZM
    cQry  := "SELECT ZZM_TOTAL FROM (SELECT ZZM_COD, ZZM_DESC, ZZM_DATA, ZZM_TOTAL, ROWNUM AS LINHA FROM (SELECT * FROM SIGA.ZZM030 ZZM WHERE ZZM.D_E_L_E_T_ = ' ' AND ZZM_FILIAL = '  ' AND ZZM_COD = '"+cProduto+"' AND ZZM_ANOTAB = '"+ alltrim(str(Year(dDataBase))) + "' AND ZZM_CODTAB = '"+cTabela+"' ORDER BY ZZM_COD, ZZM_DATA DESC, ZZM_PICM DESC, R_E_C_N_O_)) WHERE LINHA = 1"
    cAlias := U_ORTQUERY(cQry, "EXZZMT")
    If  !(cAlias)->(EOF())
        nCusto := (cAlias)->ZZM_TOTAL
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

Static Function GrupoProduto_GetInfo(cGrupo)
    Local aGrupoInfo := {}
    dbSelectArea("SBM")
    dbSetOrder(1) // Ordem por Filial+Grupo
    If dbSeek(xFilial("SBM") + cGrupo)
        aGrupoInfo := {;
            SBM->BM_GRUPO,;
            SBM->BM_MARKUP,;
            SBM->BM_XSOBMED,;
            SBM->BM_XPRDPAD;
        }
    Endif
RETURN aGrupoInfo

//-------------------------------------------------------------------
// Funções para o cálculo de preço
//-------------------------------------------------------------------

Static Function Calculo_Preco(cProduto, cTabelaRef)
    Local nCusto := 0
    Local nPrecoVenda := 0
    Local nMarkup := 1
    Local aProduto
    Local aGrupoProduto
    Local aComponentes
    Local aComponente

    aProduto := Produto_Get(cProduto)
    If Empty(aProduto)
        Return {0, 0}
    Endif

    aGrupoProduto := GrupoProduto_GetInfo(aProduto[3]) // 3 is the index of the group
    If !Empty(aGrupoProduto)
        nMarkup := aGrupoProduto[2] // 2 is the index of the markup
    Endif

    aComponentes := Composicao_GetComponentes(cProduto)

    If Len(aComponentes) > 0
        For each aComponente in aComponentes
            nCusto += Calculo_Preco(aComponente[1], cTabelaRef)[1] * aComponente[2]
        Next
    Else
        nCusto := Custo_Get(cProduto, cTabelaRef)
    Endif

    nCusto := nCusto * 1.05 // Quebra

    nPrecoVenda := nCusto * nMarkup

RETURN {Round(nCusto, 2), Round(nPrecoVenda, 2)}

//-------------------------------------------------------------------
// Funções para o cálculo de preço sob medida
//-------------------------------------------------------------------

Static Function Calculo_SobMedida(cGrupo, cTabelaRef)
    Local nCustoM3 := 0
    Local nVendaM3 := 0
    Local aGrupoProduto
    Local aProdutoBase
    Local nVolumeBase := 0
    Local nCustoBase := 0
    Local nMarkup := 1

    aGrupoProduto := GrupoProduto_GetInfo(cGrupo)
    If Empty(aGrupoProduto) .or. Empty(aGrupoProduto[4]) // 4 is the index of the base product
        Return {0, 0}
    Endif

    aProdutoBase := Produto_Get(aGrupoProduto[4])
    If Empty(aProdutoBase)
        Return {0, 0}
    Endif

    aCustoBase := Calculo_Preco(aProdutoBase[1], cTabelaRef)
    nCustoBase := aCustoBase[1]
    nVolumeBase := aProdutoBase[5] * aProdutoBase[6] * aProdutoBase[7] // width * length * height
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
// Funções para a movimentação de preços
//-------------------------------------------------------------------

Static Function Movimentacao_MoveParaDa1(cTabela)
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
        DA1->DA1_PRCVEN := (cAlias)->DA1_PRCVEN
        DA1->DA1_XCUSTO := (cAlias)->DA1_XCUSTO
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
// Funções para a gravação da simulação
//-------------------------------------------------------------------

Static Function Gravacao_GravaPreco(cTabela, cItem, cProduto, nPrecoVenda, nCusto)
    Local cInsert := "INSERT INTO SIGA.PREDA1030 (DA1_CODTAB, DA1_ITEM, DA1_CODPRO, DA1_PRCVEN, DA1_XCUSTO, DA1_DTUMOV, DA1_HRUMOV) VALUES ('"+cTabela+"','"+cItem+"','"+cProduto+"', "+Alltrim(Str(nPrecoVenda))+", "+Alltrim(Str(nCusto))+", '"+dtos(dDatabase)+"','"+time()+"')"
    TcSqlExec(cInsert)
RETURN

Static Function Gravacao_GravaPrecoSobMedida(cTabela, cGrupo, nVendaM3, nCustoM3)
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
// Funções para a atualização de custos
//-------------------------------------------------------------------

Static Function Atualizacao_AtualizaCustoDa1(cTabela, cProduto, nNovoCusto)
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

Static Function Atualizacao_AtualizaCustosFromPreda(cTabela)
    Local cQry := ""
    Local cAlias := GetNextAlias()
    Local cChave := ""
    Local lEncontrado := .F.
    Local lRecLockOk := .F.

    cQry := "SELECT DA1_CODTAB, DA1_CODPRO, DA1_ITEM, DA1_XCUSTO, DA1_PRCVEN FROM SIGA.PREDA1030 WHERE DA1_CODTAB <= '" + cTabela + "'"
    cAlias := U_ORTQUERY(cQry, cAlias)

    If !(cAlias)->(EOF())
        MsgInfo("Iniciando a atualização das tabelas de preço até a '" + cTabela + "'. Por favor, aguarde...")
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
        EndIf
        (cAlias)->(dbSkip())
    EndDo
    End Transaction

    (cAlias)->(dbCloseArea())
    MsgInfo("Processo de atualização finalizado com sucesso!")
RETURN
