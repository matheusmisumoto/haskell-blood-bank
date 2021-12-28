{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-deferred-type-errors #-}
{-# OPTIONS_GHC -Wno-deferred-out-of-scope-variables #-}
module Handler.Home where

import Import
import Text.Cassius

import Database.Persist.Postgresql

getHomeR :: Handler Html
getHomeR = do
    today <- liftIO (map utctDay getCurrentTime)
    let sql = "SELECT ??, ?? FROM doador \
            \ INNER JOIN agenda ON agenda.doador = doador.id \
            \ WHERE agenda.dt_coleta = ? \
            \ ORDER BY doador.nome ASC"
    agendamentos <- runDB $ rawSql sql [toPersistValue today] :: Handler [(Entity Doador, Entity Agenda)]
    defaultLayout $ do
        -- email <- lookupSession "_ID"
        setTitle "Dashboard - Controle de Doação de Sangue"
        addStylesheet (StaticR css_bootstrap_css)
        addScript (StaticR js_bootstrap_js)
        toWidgetHead $(cassiusFile "templates/menu.cassius")
        $(whamletFile "templates/menu.hamlet")
        $(whamletFile "templates/home.hamlet")
        $(whamletFile "templates/footer.hamlet")
