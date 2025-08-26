#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "functions.prw"

User Function ORTP169(lSobMed)
    Local aPergs     := {}
    Local aRet       := {}
    Private cTitulo  := "Geracao Marfil"
    Private cSemana  := ""
    Private cCongela := ""
    Private cTipo    := ""
    Private cCalculo := ""
    Default lSobMed  := .F.

    If cEmpAnt <> "03"
        MsgBox("O Acesso a esta rotina é exclusivo da unidade 51", "Unidade Invalida", "INFO")
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
User Function fMarfil(cProduto, cTp)
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

                aPreco := Calculo_Preco(_cProd, cTabRef)
                _nCusto := aPreco[1]
                _nVenda := aPreco[2]

                If _nCusto > 0
                    Gravacao_GravaPreco(cTabGer, cItem, _cProd, _nVenda, _nCusto)
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
        aPrecoM3 := Calculo_SobMedida(_cGrupo, cTabRef)

        If aPrecoM3[1] > 0
            cItem := soma1(cItem)
            Gravacao_GravaPrecoSobMedida(cSemana, _cGrupo, aPrecoM3[2], aPrecoM3[1])
        Endif

        (cAlias)->(dbskip())
    EndDo

    (cAlias)->(DBCLOSEAREA())

    msgInfo("Processo finalizado!","Sucesso")
Return

//ROTINA DE GRAVAÇÃO
Static Function fGeraMov(cTab)
    Movimentacao_MoveParaDa1(cTab)
Return


//ROTINA DE ATUALIZAÇÃO
Static Function UPDATEDA1(cTab)
    Atualizacao_AtualizaCustosFromPreda(cTab)
Return