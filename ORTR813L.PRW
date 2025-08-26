#include "protheus.ch"

/*-----------------------------------------------------------
  Function: ORTR813L()
  Description: Importação de Planilha fora de Linha
-----------------------------------------------------------*/
User Function ORTR813L()    
    Private aDados := {}
    Private MatchingCodes := {}
    Private MatchingDates := {}
    Private InvalidProducts := {}

	GetDataFromCsv()
	CheckData()
	UpdateFields(MatchingCodes,MatchingDates)
	If(Len(InvalidProducts) > 0 )
		cMensagem := GeraMensagem(InvalidProducts)
		msgInfo(cMensagem)
	endif

Return

Static Function CheckData()
	Local hasData := Len(aDados) > 0
	if(hasData)
		ValidateData()
	else
		msgInfo("Arquivo incorreto | Vazio ou estrura est� errada")
	endif
Return
Static Function ConverteData(cDataOriginal)
    Local cDataConvertida := ""
    Local cAno := Substr(cDataOriginal, 1, 4)
    Local cMes := Substr(cDataOriginal, 6, 2)
    Local cDia := Substr(cDataOriginal, 9, 2)
    cDataConvertida := cAno + cMes + cDia
Return cDataConvertida 
Static Function GetDataFromCsv()
    Local nHandle
    Local cLinha
    Local fLine := .T.
    Local cArqPath
    cArqPath := cGetFile("*.csv", "Selecione o arquivo para importar")
    If Empty(cArqPath)
        MsgInfo("Importação cancelada pelo usuário.", "Aviso")
        Return .F.
    EndIf
    nHandle := FT_FUSE(cArqPath) // 2. Tenta abrir o arquivo para leitura
    If nHandle < 0
        MsgStop("Não foi possível abrir o arquivo.", "Erro")
        Return .F.
    EndIf
    FT_FGoToP() //Posiciona na primeira Linha
    While !FT_FEOF()
        cLinha := FT_FREADLN()
        If (fLine)
            fline := .F.
        Else
            AADD(aDados, Separa(cLinha,';',.T.)) 
        EndIf
        FT_FSKIP() //Pula para proxima linha
    EndDo
    FT_FUSE() //Libera o arquivo
return .T.
Static Function SearchSB1(CodigoProduto)
    Local cChave := xFilial("SB1") + CodigoProduto
    // 1. Seleciona a área de trabalho
    DbSelectArea("SB1")
    // 2. Define o índice de busca
    DbSetOrder(1)
    // 3. Executa a busca e retorna o resultado
    If DbSeek(cChave)
        // O registro foi encontrado, a função retorna verdadeiro.
        // Opcional: DbCloseArea("SG1")
        Return .T.
    Else
        // O registro não foi encontrado, a função retorna falso.
        Return .F.
    EndIf
Return .F.
Static Function ValidateData()
	Local Counter := 1
	Local ArraySize := Len(aDados)
	Local CurrentInteraction
	Local aCode
	Local code
	Local date
	While (Counter <= ArraySize)
		CurrentInteraction := aDados[Counter]
		aCode := Separa(CurrentInteraction[1])
		code := aCode[1]
		date := ConverteData(aCode[2])
		isMatch := SearchSB1(code)
		If(isMatch)
			AADD(MatchingCodes,code)
			AADD(MatchingDates,date)
		Else
			AADD(InvalidProducts,code)
		EndIf
		Counter++
	EndDo
Return
Static Function UpdateFields(ProductCodes, CurrentForLinDate)
	Local cChave      := ""
	Local lRecLockOk  := .F.
	Local lUpdateOK   := .T.
	Local Counter     := 1
	Local cDataStr    := ""

	// Inicia a transação para garantir que todas as atualizações
	// sejam feitas ou nenhuma seja feita (caso de erro)
	Begin Transaction

		Do While (Len(ProductCodes) >= Counter)
			// 1. Garante que a string está limpa
			cDataStr := Alltrim(CurrentForLinDate[Counter])

			// 2. Verifica se a string tem o tamanho correto antes de converter
			If Len(cDataStr) == 8

				cChave := xFilial("SB1") + ProductCodes[Counter]
				DbSelectArea("SB1")
				DbSetOrder(1)

				If DbSeek(cChave)
					lRecLockOk := RecLock("SB1", .F.)

					If lRecLockOk
						// 3. Conversão segura da string para data
						SB1->B1_XFORLIN := sToD(cDataStr)

						// O MsUnlock() salva e libera o registro
						MsUnLock()
					Else
						// Se falhar o bloqueio, encerra a transação para não ter dados inconsistentes
						lUpdateOK := .F.
						MsgAlert("Falha ao bloquear o registro: " + cChave)
					EndIf
				Else
					lUpdateOK := .F.
					MsgAlert("Registro não encontrado para o produto: " + ProductCodes[Counter])
				EndIf
			Else
				lUpdateOK := .F.
				MsgAlert("String de data inválida para o item " + cValToChar(Counter) + ": '" + cDataStr + "'")
			EndIf

			Counter++
		EndDo

		// Finaliza a transação. Se lUpdateOK for falso, o Rollback é executado.
	End Transaction(lUpdateOK)

	MsgInfo("Processo finalizado. Sucesso: " + cValToChar(lUpdateOK))

Return

Static Function GeraMensagem(aCodigos)
    Local cMensagem   := ""
    Local cCodigosStr := ""
    Local nI          := 0

    // Verifica se o array tem apenas um item
    If Len(aCodigos) == 1
        // Formata a mensagem para um �nico c�digo
        cMensagem := "O Codigo: " + Alltrim(aCodigos[1]) + " foi cadastrado"
    Else
        // Se houver mais de um item, monta a lista de c�digos
        For nI := 1 To Len(aCodigos)
            // Concatena o c�digo atual � string
            cCodigosStr += Alltrim(aCodigos[nI])

            // Adiciona uma v�rgula e um espa�o, exceto no �ltimo item
            If nI < Len(aCodigos)
                cCodigosStr += ", "
            EndIf
        Next nI

        // Formata a mensagem com a lista de c�digos n�o cadastrados
        cMensagem := "Os seguintes codigos n�o est�o cadastrados: " + cCodigosStr
    EndIf
    Return cMensagem
