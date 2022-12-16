{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-deferred-type-errors #-}
{-# OPTIONS_GHC -Wno-deferred-out-of-scope-variables #-}
module Handler.Hospitais where

import Import
import Text.Cassius

-- /admin/hospitais       ListarhR        GET

getListarhR :: Handler Html
getListarhR = do
    hospitais <- runDB $ selectList [] [Asc UsuarioHEmail]
    msg <- getMessage
    defaultLayout $ do
        setTitle "Lista de Usuários - Controle de Doação de Sangue"
        addStylesheet (StaticR css_bootstrap_css)
        addScript (StaticR js_bootstrap_js)
        toWidgetHead $(cassiusFile "templates/menu.cassius")
        toWidgetHead $(cassiusFile "templates/content.cassius")
        $(whamletFile "templates/menuAdmin.hamlet")
        [whamlet|
            $maybe mensa <- msg
                ^{mensa}
        |]
        $(whamletFile "templates/listarhospital.hamlet")
        $(whamletFile "templates/footer.hamlet")

-- /admin/hospital/#UsuarioHId/remover          ApagarhR        POST
postApagarhR :: UsuarioHId -> Handler Html
postApagarhR did = do
    runDB $ delete did
    setMessage [shamlet|
        <div class="alert alert-success container-lg mt-5 my-3" role="alert">
            Usuário removido com sucesso!
    |]
    redirect ListarhR