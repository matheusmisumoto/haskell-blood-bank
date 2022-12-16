{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-deferred-type-errors #-}
{-# OPTIONS_GHC -Wno-deferred-out-of-scope-variables #-}
module Handler.Doador where

import Import
import Text.Cassius

-- /doadores    ListardR    GET
getListardR :: Handler Html
getListardR = do
    msg <- getMessage
    doadores <- runDB $ selectList [] [Asc DoadorNome]
    defaultLayout $ do
        setTitle "Lista de Doadores - Controle de Doação de Sangue"
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
        $(whamletFile "templates/listardoador.hamlet")
        $(whamletFile "templates/footer.hamlet")


-- /doador/#DoadorId               DoadorR       GET
getDoadorR :: DoadorId -> Handler Html
getDoadorR did = do
    doador <- runDB $ get404 did
    defaultLayout $ do
        setTitle "Registro de Doador - Controle de Doação de Sangue"
        addStylesheet (StaticR css_bootstrap_css)
        addScript (StaticR js_bootstrap_js)
        toWidgetHead $(cassiusFile "templates/menu.cassius")
        toWidgetHead $(cassiusFile "templates/content.cassius")
        $(whamletFile "templates/menu.hamlet")
        $(whamletFile "templates/dadosdoador.hamlet")
        $(whamletFile "templates/footer.hamlet")


-- /doador/#DoadorId/remover       ApagardR      POST
postApagardR :: DoadorId -> Handler Html
postApagardR did = do
    runDB $ delete did
    setMessage [shamlet|
        Doador removido com sucesso!
    |]
    redirect ListardR