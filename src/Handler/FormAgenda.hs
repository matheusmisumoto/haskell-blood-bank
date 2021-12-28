{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-deferred-type-errors #-}
{-# OPTIONS_GHC -Wno-deferred-out-of-scope-variables #-}
module Handler.FormAgenda where

import Import
import Text.Cassius

-- /agendamento/novo               Cadastrara1R     GET POST

data Documento = Documento
    { cpf :: Text
    }
  deriving Show

formCPF :: Form Documento
formCPF = renderDivs $ Documento
    <$> areq textField (FieldSettings "CPF" (Just "CPF") (Just "cpf") Nothing [("class","form-control mb-3")]) Nothing

getCadastrara1R :: Handler Html
getCadastrara1R = do
    (widget,_) <- generateFormPost formCPF
    msg <- getMessage 
    defaultLayout $ do
        setTitle "Agendamento de Doação - Busca por Doador - Controle de Doação de Sangue"
        addStylesheet (StaticR css_bootstrap_css)
        addScript (StaticR js_bootstrap_js)
        toWidgetHead $(cassiusFile "templates/menu.cassius")
        $(whamletFile "templates/menu.hamlet")
        toWidgetHead $(cassiusFile "templates/form.cassius")
        [whamlet|
            $maybe mensa <- msg
                <div class="alert alert-success container-lg mt-5 my-3" role="alert">
                    ^{mensa}
        |]
        $(whamletFile "templates/formagendamento.hamlet")
        $(whamletFile "templates/footer.hamlet")

postCadastrara1R :: Handler Html
postCadastrara1R = do
    ((result,_),_) <- runFormPost formCPF
    case result of
        FormSuccess documento -> do
            doadores <- runDB $ selectFirst [DoadorCpf <-. [(cpf documento)]] [LimitTo 1]
            defaultLayout $ do
                setTitle "Agendamento de Coleta - Busca por Doador - Controle de Doação de Sangue"
                addStylesheet (StaticR css_bootstrap_css)
                addScript (StaticR js_bootstrap_js)
                toWidgetHead $(cassiusFile "templates/menu.cassius")
                $(whamletFile "templates/menu.hamlet")
                $(whamletFile "templates/buscardoador.hamlet")
                $(whamletFile "templates/footer.hamlet")
        _ -> redirect HomeR


-- /agendamento/novo/#DoadorId       Cadastrara2R     GET POST

formAgenda :: DoadorId -> Maybe Agenda -> Form Agenda
formAgenda doadorId agenda = renderDivs $ Agenda
    <$> pure doadorId
    <*> areq textField (FieldSettings "Ponto de coleta" (Just "Hospital") (Just "hospital") Nothing [("class","form-control mb-3")]) (fmap agendaHospital agenda)
    <*> areq dayField  (FieldSettings "Dia da Coleta" (Just "Coleta") (Just "coleta") Nothing [("class","form-control mb-3")]) (fmap agendaDtColeta agenda)

getCadastrara2R :: DoadorId -> Handler Html
getCadastrara2R did = do
    doador <- runDB $ get404 did
    (widget,_) <- generateFormPost $ formAgenda did Nothing
    defaultLayout $ do
        setTitle "Agendamento de Coleta - Novo Horário - Controle de Doação de Sangue"
        addStylesheet (StaticR css_bootstrap_css)
        addScript (StaticR js_bootstrap_js)
        toWidgetHead $(cassiusFile "templates/menu.cassius")
        $(whamletFile "templates/menu.hamlet")
        $(whamletFile "templates/formagendamento1.hamlet")
        $(whamletFile "templates/footer.hamlet")

postCadastrara2R :: DoadorId -> Handler Html
postCadastrara2R did = do
    ((result,_),_) <- runFormPost $ formAgenda did Nothing
    case result of
        FormSuccess agenda -> do
            _ <- runDB $ insert agenda
            setMessage [shamlet|
                Coleta agendada com sucesso!
            |]
            redirect Cadastrara1R
        _ -> redirect HomeR


-- /agendamentos/#AgendaId/editar        Editara2R       GET POST
getEditara2R :: AgendaId -> DoadorId -> Handler Html
getEditara2R aid did = do
    doador <- runDB $ get404 did
    agenda <- runDB $ get404 aid
    (widget,_) <- generateFormPost (formAgenda did (Just agenda))
    msg <- getMessage 
    defaultLayout $ do
        setTitle "Editar Agenda - Controle de Doação de Sangue"
        addStylesheet (StaticR css_bootstrap_css)
        addScript (StaticR js_bootstrap_js)
        toWidgetHead $(cassiusFile "templates/menu.cassius")
        $(whamletFile "templates/menu.hamlet")
        toWidgetHead $(cassiusFile "templates/form.cassius")
        $(whamletFile "templates/formeditaragendamento1.hamlet")
        $(whamletFile "templates/footer.hamlet")

postEditara2R :: AgendaId -> DoadorId -> Handler Html
postEditara2R aid did = do
    agendaAntiga <- runDB $ get404 aid
    ((result,_),_) <- runFormPost (formAgenda did Nothing)
    case result of
        FormSuccess novoAgendamento -> do
            runDB $ replace aid novoAgendamento
            setMessage [shamlet|
                Coleta remarcada com sucesso!
            |]
            redirect AgendamentosR
        _ -> redirect HomeR