#include "protheus.ch"
User Function CadastroClientes()
Local oForm := Nil
Local oBrowser := Nil
Local oEdit := Nil
Local oButton := Nil
Local cNome := ""
Local cCidade := ""
Local cUF := ""
Local nTelefone := 0
Local nCodCli := 0
Local lNovo := .F.
Local lAlterou := .F.

// Criação do formulário
oForm := TOTVS.CreateWindow("Cadastro de Clientes", 700, 500)

// Criação do browser
oBrowser := TOTVS.CreateBrowser(oForm, "Browser", 0, 0, 600, 450)
oBrowser:ColumnsAdd("Código", 80)
oBrowser:ColumnsAdd("Nome", 200)
oBrowser:ColumnsAdd("Cidade", 150)
oBrowser:ColumnsAdd("UF", 50)
oBrowser:ColumnsAdd("Telefone", 100)

// Criação dos campos de edição
oEdit := TOTVS.CreateEdit(oForm, "Codigo", "Código", 620, 20, 50, 20, .F.)
oEdit:Enabled := .F.
oEdit := TOTVS.CreateEdit(oForm, "Nome", "Nome", 620, 50, 300, 20, .T.)
oEdit := TOTVS.CreateEdit(oForm, "Cidade", "Cidade", 620, 80, 200, 20, .T.)
oEdit := TOTVS.CreateEdit(oForm, "UF", "UF", 830, 80, 50, 20, .T.)
oEdit := TOTVS.CreateEdit(oForm, "Telefone", "Telefone", 620, 110, 100, 20, .T.)

// Criação dos botões
oButton := TOTVS.CreateButton(oForm, "Novo", "Novo", 630, 150, 80, 30, "BTN_NOVO")
oButton := TOTVS.CreateButton(oForm, "Salvar", "Salvar", 720, 150, 80, 30, "BTN_SALVAR")
oButton := TOTVS.CreateButton(oForm, "Excluir", "Excluir", 810, 150, 80, 30, "BTN_EXCLUIR")
oButton := TOTVS.CreateButton(oForm, "Fechar", "Fechar", 720, 200, 80, 30, "BTN_FECHAR")

// Carregamento dos dados
SELECT CLIENTES
INTO CURSOR crsClientes
ORDER BY CODIGO

IF _TALLY > 0
    lNovo := .F.
    nCodCli := crsClientes->CODIGO[_TALLY] + 1
    oBrowser:AddItem({ nCodCli, "", "", "", "" })
    oBrowser:RowSelect(_TALLY + 1)
ELSE
    lNovo := .T.

// Tratamento dos eventos dos botões
User Function BTN_NOVO()
    oBrowser:RowSelect(-1)
    oEdit:CLEAR()
    lNovo := .T.
    lAlterou := .F.

User Function BTN_SALVAR()
    IF lNovo
        SELECT CLIENTES
        APPEND BLANK
        nCodCli := MAX(CLIENTES->CODIGO) + 1
    ELSE
        SELECT CLIENTES
        LOCATE FOR CODIGO = oBrowser:GetSelectedColumnValue(1)
    ENDIF

    cNome := oEdit:Value("Nome")
    cCidade := oEdit:Value("Cidade")
    cUF := oEdit:Value("UF")
    nTelefone := Val(oEdit:Value("Telefone"))

    CLIENTES->CODIGO := nCodCli
    CLIENTES->NOME := cNome
    CLIENTES->CIDADE := cCidade
    CLIENTES->UF := cUF
    CLIENTES->TELEFONE := nTelefone

    IF lNovo
        oBrowser:ReplaceSelected({ nCodCli, cNome, cCidade, cUF, nTelefone })
        oBrowser:RowSelect(_TALLY + 1)
    ELSE
        oBrowser:ReplaceSelected({ nCodCli, cNome, cCidade, cUF, nTelefone })
        lAlterou := .T.
    ENDIF

User Function BTN_EXCLUIR()
    IF oBrowser:RowSelected() > 0
        IF MsgYesNo("Deseja excluir o registro selecionado?") = 6
            SELECT CLIENTES
            LOCATE FOR CODIGO = oBrowser:GetSelectedColumnValue(1)
            DELETE
            oBrowser:RowDelete()
            oEdit:CLEAR()
            lNovo := .T.
            lAlterou := .F.
        ENDIF
    ENDIF

User Function BTN_FECHAR()
    IF lAlterou
        MsgYesNo("Deseja salvar as alterações antes de sair?")
        IF _YESNO = 6
            BTN_SALVAR()
        ENDIF
    ENDIF
    oForm:Release()
