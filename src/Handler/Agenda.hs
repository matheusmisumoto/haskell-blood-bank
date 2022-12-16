{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-deferred-type-errors #-}
{-# OPTIONS_GHC -Wno-deferred-out-of-scope-variables #-}
module Handler.Agenda where

import Import
import Database.Persist.MySQL
import Text.Cassius

-- /agendamentos                   AgendamentosR   GET
getAgendamentosR :: Handler Html
getAgendamentosR = do
    msg <- getMessage      
    let sql = "SELECT ??, ?? FROM doador \
            \ INNER JOIN agenda ON agenda.doador = doador.id \
            \ ORDER BY agenda.dt_coleta DESC"
    agendamentos <- runDB $ rawSql sql [] :: Handler [(Entity Doador, Entity Agenda)]
    defaultLayout $ do
        setTitle "Agenda de Coleta - Controle de Doação de Sangue"
        addStylesheet (StaticR css_bootstrap_css)
        addScript (StaticR js_bootstrap_js)
        toWidgetHead $(cassiusFile "templates/menu.cassius")
        toWidgetHead $(cassiusFile "templates/content.cassius")
        $(whamletFile "templates/menu.hamlet")
        [whamlet|
            $maybe mensa <- msg
                <div class="alert alert-success container-lg mt-5 my-3" role="alert">
                    ^{mensa}
        |]
        $(whamletFile "templates/listaragendamentos.hamlet")
        $(whamletFile "templates/footer.hamlet")

-- /agendamentos/#AgendaId               AgendaR       GET
getAgendaR :: AgendaId -> Handler Html
getAgendaR aid = do
    let sql = "SELECT ??, ?? FROM doador \
            \ INNER JOIN agenda ON agenda.doador = doador.id \
            \ WHERE agenda.id = ?"
    agendamento <- runDB $ rawSql sql [toPersistValue aid] :: Handler [(Entity Doador, Entity Agenda)]
    defaultLayout $ do
        setTitle "Agendamento de Doação - Controle de Doação de Sangue"
        addStylesheet (StaticR css_bootstrap_css)
        addScript (StaticR js_bootstrap_js)
        toWidgetHead $(cassiusFile "templates/menu.cassius")
        toWidgetHead $(cassiusFile "templates/content.cassius")
        $(whamletFile "templates/menu.hamlet")
        $(whamletFile "templates/dadosagendamento.hamlet")
        $(whamletFile "templates/footer.hamlet")


-- /agendamentos/#AgendaId/Apagar  ApagarAgenR     POST

postApagarAgenR :: AgendaId -> Handler Html
postApagarAgenR aid = do
    runDB $ delete aid
    setMessage [shamlet|
        Agendamento removido com sucesso!
    |]
    redirect AgendamentosR
