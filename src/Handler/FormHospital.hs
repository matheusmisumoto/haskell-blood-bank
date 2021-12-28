{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-deferred-type-errors #-}
{-# OPTIONS_GHC -Wno-deferred-out-of-scope-variables #-}
module Handler.FormHospital where

import Import
import Text.Cassius


-- /admin/hospital/novo     CadastrarhR     GET
formUsuarioH :: Maybe UsuarioH -> Form(UsuarioH , Text)
formUsuarioH usuario = renderDivs $ (,) 
    <$> (UsuarioH 
        <$> areq textField (FieldSettings "Email" (Just "Email") (Just "email") Nothing [("class","form-control mb-3")]) (fmap usuarioHEmail usuario)
        <*> areq passwordField (FieldSettings "Senha" (Just "Senha") (Just "senha") Nothing [("class","form-control mb-3")]) Nothing
        
        )
    <*> areq passwordField (FieldSettings "Confirmação de Senha" (Just "Confirmacao") (Just "confirmacao") Nothing [("class","form-control mb-3")]) Nothing

getCadastrarhR :: Handler Html
getCadastrarhR = do
    (widget,_) <- generateFormPost (formUsuarioH Nothing)
    msg <- getMessage 
    defaultLayout $ do
        setTitle "Cadastrar Usuário - Controle de Doação de Sangue"
        addStylesheet (StaticR css_bootstrap_css)
        addScript (StaticR js_bootstrap_js)
        toWidgetHead $(cassiusFile "templates/menu.cassius")
        $(whamletFile "templates/menuAdmin.hamlet")
        toWidgetHead $(cassiusFile "templates/form.cassius")
        [whamlet|
            $maybe mensa <- msg
                ^{mensa}
        |]
        $(whamletFile "templates/formhospital.hamlet")
        $(whamletFile "templates/footer.hamlet")


-- /admin/hospital/novo     CadastrarhR     POST
postCadastrarhR :: Handler Html
postCadastrarhR = do
    ((result,_),_) <- runFormPost (formUsuarioH Nothing)
    case result of
        FormSuccess (usuarioh@(UsuarioH email senha), conf) -> do
            usuarioExiste <- runDB $ getBy (UniqueEmail email)
            case usuarioExiste of
                Just _ -> do
                    setMessage [shamlet|
                        <div class="alert alert-success container-lg mt-5 my-3" role="alert">
                            E-mail já cadastrado!
                    |]
                    redirect CadastrarhR
                Nothing -> do
                    if senha == conf then do
                        _ <- runDB $ insert usuarioh
                        setMessage [shamlet|
                            <div class="alert alert-success container-lg mt-5 my-3" role="alert">
                                Usuário cadastrado com sucesso!
                        |]
                        redirect CadastrarhR
                    else do
                        setMessage [shamlet|
                            <div class="alert alert-danger container-lg mt-5 my-3" role="alert">
                                Senha e Confirmação diferentes!
                        |]
                        redirect CadastrarhR
        _ -> redirect HomeR

-- /admin/hospital/#UsuarioHId/editar    EditarhR        GET
getEditarhR :: UsuarioHId -> Handler Html
getEditarhR uid = do
    usuario <- runDB $ get404 uid
    (widget,_) <- generateFormPost (formUsuarioH (Just usuario))
    msg <- getMessage 
    defaultLayout $ do
        setTitle "Editar Usuário - Controle de Doação de Sangue"
        addStylesheet (StaticR css_bootstrap_css)
        addScript (StaticR js_bootstrap_js)
        toWidgetHead $(cassiusFile "templates/menu.cassius")
        $(whamletFile "templates/menuAdmin.hamlet")
        toWidgetHead $(cassiusFile "templates/form.cassius")
        [whamlet|
            $maybe mensa <- msg
                ^{mensa}
        |]
        $(whamletFile "templates/formeditarhospital.hamlet")
        $(whamletFile "templates/footer.hamlet")

-- /admin/hospital/#UsuarioHId/editar    EditarhR        POST
postEditarhR :: UsuarioHId -> Handler Html
postEditarhR uid = do
    usuarioAntigo <- runDB $ get404 uid
    ((result,_),_) <- runFormPost (formUsuarioH Nothing)
    case result of
        FormSuccess (usuarioh@(UsuarioH email senha), conf) -> do
            usuarioExiste <- runDB $ getBy (UniqueEmail email)
            case usuarioExiste of
                Just _ -> do
                    setMessage [shamlet|
                        <div class="alert alert-danger container-lg mt-5 my-3" role="alert">
                            E-mail já cadastrado!
                    |]
                    redirect (EditarhR uid)
                Nothing -> do
                    if senha == conf then do
                        _ <- runDB $ replace uid usuarioh
                        setMessage [shamlet|
                            <div class="alert alert-success container-lg mt-5 my-3" role="alert">
                                Usuário editado com sucesso!
                        |]
                        redirect ListarhR
                    else do
                        setMessage [shamlet|
                            <div class="alert alert-danger container-lg mt-5 my-3" role="alert">
                                Senha e Confirmação diferentes!
                        |]
                        redirect (EditarhR uid)
        _ -> redirect HomeR