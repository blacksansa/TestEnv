#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Produto
@description Data object para representar um produto
@author Gemini
@since 26/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS Produto FROM LongClassName
    DATA cCodigo AS CHARACTER
    DATA cDescricao AS CHARACTER
    DATA cGrupo AS CHARACTER
    DATA cModelo AS CHARACTER
    DATA nLargura AS NUMERIC
    DATA nComprimento AS NUMERIC
    DATA nAltura AS NUMERIC

    METHOD New(cCodigo, cDescricao, cGrupo, cModelo, nLargura, nComprimento, nAltura) CONSTRUCTOR

    METHOD GetCodigo() AS CHARACTER
    METHOD GetGrupo() AS CHARACTER
    METHOD GetLargura() AS NUMERIC
    METHOD GetComprimento() AS NUMERIC
    METHOD GetAltura() AS NUMERIC
ENDCLASS

METHOD New(cCodigo, cDescricao, cGrupo, cModelo, nLargura, nComprimento, nAltura) CLASS Produto
    ::cCodigo := cCodigo
    ::cDescricao := cDescricao
    ::cGrupo := cGrupo
    ::cModelo := cModelo
    ::nLargura := nLargura
    ::nComprimento := nComprimento
    ::nAltura := nAltura
RETURN self

METHOD GetCodigo() CLASS Produto
RETURN ::cCodigo

METHOD GetGrupo() CLASS Produto
RETURN ::cGrupo

METHOD GetLargura() CLASS Produto
RETURN ::nLargura

METHOD GetComprimento() CLASS Produto
RETURN ::nComprimento

METHOD GetAltura() CLASS Produto
RETURN ::nAltura

//-------------------------------------------------------------------
/*/{Protheus.doc} Componente
@description Data object para representar um componente de um produto
@author Gemini
@since 26/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS Componente FROM LongClassName
    DATA cCodigo AS CHARACTER
    DATA nQuantidade AS NUMERIC

    METHOD New(cCodigo, nQuantidade) CONSTRUCTOR

    METHOD GetCodigo() AS CHARACTER
    METHOD GetQuantidade() AS NUMERIC
ENDCLASS

METHOD New(cCodigo, nQuantidade) CLASS Componente
    ::cCodigo := cCodigo
    ::nQuantidade := nQuantidade
RETURN self

METHOD GetCodigo() CLASS Componente
RETURN ::cCodigo

METHOD GetQuantidade() CLASS Componente
RETURN ::nQuantidade

//-------------------------------------------------------------------
/*/{Protheus.doc} GrupoProduto
@description Data object para representar um grupo de produto
@author Gemini
@since 26/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS GrupoProduto FROM LongClassName
    DATA cGrupo AS CHARACTER
    DATA nMarkup AS NUMERIC
    DATA lSobMedida AS LOGICAL
    DATA cProdutoBase AS CHARACTER

    METHOD New(cGrupo, nMarkup, cSobMedida, cProdutoBase) CONSTRUCTOR

    METHOD GetMarkup() AS NUMERIC
    METHOD IsSobMedida() AS LOGICAL
    METHOD GetProdutoBase() AS CHARACTER
ENDCLASS

METHOD New(cGrupo, nMarkup, cSobMedida, cProdutoBase) CLASS GrupoProduto
    ::cGrupo := cGrupo
    ::nMarkup := nMarkup
    ::lSobMedida := (cSobMedida == 'S')
    ::cProdutoBase := cProdutoBase
RETURN self

METHOD GetMarkup() CLASS GrupoProduto
RETURN ::nMarkup

METHOD IsSobMedida() CLASS GrupoProduto
RETURN ::lSobMedida

METHOD GetProdutoBase() CLASS GrupoProduto
RETURN ::cProdutoBase

//-------------------------------------------------------------------
/*/{Protheus.doc} CalculoSobMedida
@description Classe para calcular o preço de produtos sob medida
@author Gemini
@since 26/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS CalculoSobMedida FROM LongClassName
    DATA oProdutoDAO AS OBJECT
    DATA oCustoDAO AS OBJECT
    DATA oGrupoProdutoDAO AS OBJECT
    DATA oCalculoPreco AS OBJECT

    METHOD New() CONSTRUCTOR
    METHOD Calcula(cGrupo, cTabelaRef)

ENDCLASS

METHOD New() CLASS CalculoSobMedida
    ::oProdutoDAO := ProdutoDAO():New()
    ::oCustoDAO := CustoDAO():New()
    ::oGrupoProdutoDAO := GrupoProdutoDAO():New()
    ::oCalculoPreco := CalculoPreco():New()
RETURN self

METHOD Calcula(cGrupo, cTabelaRef) CLASS CalculoSobMedida
    Local nCustoM3 := 0
    Local nVendaM3 := 0
    Local oGrupoProduto
    Local oProdutoBase
    Local nVolumeBase := 0
    Local nCustoBase := 0
    Local nMarkup := 1

    oGrupoProduto := ::oGrupoProdutoDAO:GetGrupoInfo(cGrupo)
    If oGrupoProduto == Nil .or. Empty(oGrupoProduto:GetProdutoBase())
        Return {0, 0}
    Endif

    oProdutoBase := ::oProdutoDAO:GetProduto(oGrupoProduto:GetProdutoBase())
    If oProdutoBase == Nil
        Return {0, 0}
    Endif

    aCustoBase := ::oCalculoPreco:Calcula(oProdutoBase:GetCodigo(), cTabelaRef)
    nCustoBase := aCustoBase[1]
    nVolumeBase := oProdutoBase:GetLargura() * oProdutoBase:GetComprimento() * oProdutoBase:GetAltura()
    nMarkup := oGrupoProduto:GetMarkup()

    If nVolumeBase == 0
        Return {0, 0}
    Endif

    nCustoM3 := ((nCustoBase / nVolumeBase) * 1.15)
    nVendaM3 := nCustoM3 * nMarkup

    nCustoM3 := (Floor(nCustoM3 / 100) * 100) + 1
    nVendaM3 := (Floor(nVendaM3 / 100) * 100) + 1

RETURN {nCustoM3, nVendaM3}


//-------------------------------------------------------------------
/*/{Protheus.doc} MovimentacaoPreco
@description Classe para movimentar os dados de preço da tabela temporária para a principal
@author Gemini
@since 26/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS MovimentacaoPreco FROM LongClassName

    METHOD New() CONSTRUCTOR
    METHOD MoveParaDa1(cTabela)

ENDCLASS

METHOD New() CLASS MovimentacaoPreco
RETURN self

/*
@method MoveParaDa1
@description Move os dados da tabela temporária PREDA1030 para a tabela principal DA1030
@param cTabela, character, Código da tabela de preço
*/
METHOD MoveParaDa1(cTabela) CLASS MovimentacaoPreco
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
/*/{Protheus.doc} GravacaoSimulacao
@description Classe para gravar os dados da simulação de preços
@author Gemini
@since 26/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS GravacaoSimulacao FROM LongClassName

    METHOD New() CONSTRUCTOR
    METHOD GravaPreco(cTabela, cItem, cProduto, nPrecoVenda, nCusto)

ENDCLASS

METHOD New() CLASS GravacaoSimulacao
RETURN self

/*
@method GravaPreco
@description Grava um novo preço na tabela temporária PREDA1030
@param cTabela, character, Código da tabela de preço
@param cItem, character, Item da tabela de preço
@param cProduto, character, Código do produto
@param nPrecoVenda, numeric, Preço de venda
@param nCusto, numeric, Custo do produto
*/
METHOD GravaPreco(cTabela, cItem, cProduto, nPrecoVenda, nCusto) CLASS GravacaoSimulacao
    Local cInsert := "INSERT INTO SIGA.PREDA1030 (DA1_CODTAB, DA1_ITEM, DA1_CODPRO, DA1_PRCVEN, DA1_XCUSTO, DA1_DTUMOV, DA1_HRUMOV) VALUES ('"+cTabela+"','"+cItem+"','"+cProduto+"', "+Alltrim(Str(nPrecoVenda))+", "+Alltrim(Str(nCusto))+", '"+dtos(dDatabase)+"','"+time()+"')"
    TcSqlExec(cInsert)
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} AtualizacaoCusto
@description Classe para atualizar os custos na tabela DA1030
@author Gemini
@since 26/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS AtualizacaoCusto FROM LongClassName

    METHOD New() CONSTRUCTOR
    METHOD AtualizaCustoDa1(cTabela, cProduto, nNovoCusto)
    METHOD AtualizaCustosFromPreda(cTabela)

ENDCLASS

METHOD New() CLASS AtualizacaoCusto
RETURN self

/*
@method AtualizaCustoDa1
@description Atualiza o custo de um produto na tabela DA1030
@param cTabela, character, Código da tabela de preço
@param cProduto, character, Código do produto
@param nNovoCusto, numeric, Novo custo do produto
*/
METHOD AtualizaCustoDa1(cTabela, cProduto, nNovoCusto) CLASS AtualizacaoCusto
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

/*
@method AtualizaCustosFromPreda
@description Atualiza os custos da tabela DA1030 com base nos dados da tabela temporária PREDA1030
@param cTabela, character, Código da tabela de preço
*/
METHOD AtualizaCustosFromPreda(cTabela) CLASS AtualizacaoCusto
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

//-------------------------------------------------------------------
/*/{Protheus.doc} ProdutoDAO
@description Classe de acesso a dados para a tabela de produtos (SB1)
@author Gemini
@since 26/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS ProdutoDAO FROM LongClassName
    METHOD New() CONSTRUCTOR
    METHOD GetProduto(cProduto)
ENDCLASS

METHOD New() CLASS ProdutoDAO
RETURN self

METHOD GetProduto(cProduto) CLASS ProdutoDAO
    Local oProduto := Nil
    dbSelectArea("SB1")
    dbSetOrder(1) // Ordem por Filial+Produto
    If dbSeek(xFilial("SB1") + cProduto)
        oProduto := Produto():New(SB1->B1_COD, SB1->B1_DESC, SB1->B1_GRUPO, SB1->B1_XMODELO, SB1->B1_XLARG, SB1->B1_XCOMP, SB1->B1_XALT)
    Endif
RETURN oProduto

//-------------------------------------------------------------------
/*/{Protheus.doc} ComposicaoDAO
@description Classe de acesso a dados para a tabela de composição (SG1)
@author Gemini
@since 26/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS ComposicaoDAO FROM LongClassName
    METHOD New() CONSTRUCTOR
    METHOD GetComponentes(cProduto)
ENDCLASS

METHOD New() CLASS ComposicaoDAO
RETURN self

METHOD GetComponentes(cProduto) CLASS ComposicaoDAO
    Local aComponentes := {}
    dbSelectArea("SG1")
    dbSetOrder(1) // Ordem por Filial+ProdutoPai+Componente
    If dbSeek(xFilial("SG1") + cProduto)
        While !EOF() .and. G1_FILIAL + G1_COD == xFilial("SG1") + cProduto
            AAdd(aComponentes, Componente():New(SG1->G1_COMP, SG1->G1_QUANT))
            dbSkip()
        EndDo
    Endif
RETURN aComponentes

//-------------------------------------------------------------------
/*/{Protheus.doc} CustoDAO
@description Classe de acesso a dados para a tabela de custos (ZZM e DA1)
@author Gemini
@since 26/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS CustoDAO FROM LongClassName
    METHOD New() CONSTRUCTOR
    METHOD GetCusto(cProduto, cTabela)
ENDCLASS

METHOD New() CLASS CustoDAO
RETURN self

METHOD GetCusto(cProduto, cTabela) CLASS CustoDAO
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
/*/{Protheus.doc} GrupoProdutoDAO
@description Classe de acesso a dados para a tabela de grupos de produto (SBM)
@author Gemini
@since 26/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS GrupoProdutoDAO FROM LongClassName
    METHOD New() CONSTRUCTOR
    METHOD GetGrupoInfo(cGrupo)
ENDCLASS

METHOD New() CLASS GrupoProdutoDAO
RETURN self

METHOD GetGrupoInfo(cGrupo) CLASS GrupoProdutoDAO
    Local oGrupoInfo := Nil
    dbSelectArea("SBM")
    dbSetOrder(1) // Ordem por Filial+Grupo
    If dbSeek(xFilial("SBM") + cGrupo)
        oGrupoInfo := GrupoProduto():New(SBM->BM_GRUPO, SBM->BM_MARKUP, SBM->BM_XSOBMED, SBM->BM_XPRDPAD)
    Endif
RETURN oGrupoInfo

//-------------------------------------------------------------------
/*/{Protheus.doc} CalculoPreco
@description Classe para calcular o preço de venda de um produto
@author Gemini
@since 26/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS CalculoPreco FROM LongClassName
    DATA oProdutoDAO AS OBJECT
    DATA oCustoDAO AS OBJECT
    DATA oComposicaoDAO AS OBJECT
    DATA oGrupoProdutoDAO AS OBJECT

    METHOD New() CONSTRUCTOR
    METHOD Calcula(cProduto, cTabelaRef)
ENDCLASS

METHOD New() CLASS CalculoPreco
    ::oProdutoDAO := ProdutoDAO():New()
    ::oCustoDAO := CustoDAO():New()
    ::oComposicaoDAO := ComposicaoDAO():New()
    ::oGrupoProdutoDAO := GrupoProdutoDAO():New()
RETURN self

METHOD Calcula(cProduto, cTabelaRef) CLASS CalculoPreco
    Local nCusto := 0
    Local nPrecoVenda := 0
    Local nMarkup := 1
    Local oProduto
    Local oGrupoProduto
    Local aComponentes
    Local oComponente

    oProduto := ::oProdutoDAO:GetProduto(cProduto)
    If oProduto == Nil
        Return {0, 0}
    Endif

    oGrupoProduto := ::oGrupoProdutoDAO:GetGrupoInfo(oProduto:GetGrupo())
    If oGrupoProduto != Nil
        nMarkup := oGrupoProduto:GetMarkup()
        If oGrupoProduto:IsSobMedida()
            // Lógica específica para sob medida
        Endif
    Endif

    aComponentes := ::oComposicaoDAO:GetComponentes(cProduto)

    If Len(aComponentes) > 0
        For each oComponente in aComponentes
            nCusto += ::Calcula(oComponente:GetCodigo(), cTabelaRef)[1] * oComponente:GetQuantidade()
        Next
    Else
        nCusto := ::oCustoDAO:GetCusto(cProduto, cTabelaRef)
    Endif

    nCusto := nCusto * 1.05 // Quebra

    nPrecoVenda := nCusto * nMarkup

RETURN {Round(nCusto, 2), Round(nPrecoVenda, 2)}

//-------------------------------------------------------------------
/*/{Protheus.doc} SobMedidaDAO
@description Classe de acesso a dados para a tabela de sob medida (SZV)
@author Gemini
@since 26/08/2025
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS SobMedidaDAO FROM LongClassName
    METHOD New() CONSTRUCTOR
    METHOD GravaPrecoM3(cTabela, cGrupo, nVendaM3, nCustoM3)
ENDCLASS

METHOD New() CLASS SobMedidaDAO
RETURN self

METHOD GravaPrecoM3(cTabela, cGrupo, nVendaM3, nCustoM3) CLASS SobMedidaDAO
    RecLock("SZV",.T.)
    SZV->ZV_FILIAL  := xFilial("SZV")
    SZV->ZV_GRUPO   := cGrupo
    SZV->ZV_TABELA  := cTabela
    SZV->ZV_CUSTO   := nCustoM3
    SZV->ZV_VENDA   := nVendaM3
    SZV->ZV_VENAME  := nVendaM3
    MsUnLock()
RETURN