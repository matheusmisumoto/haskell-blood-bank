{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-deferred-type-errors #-}
{-# OPTIONS_GHC -Wno-deferred-out-of-scope-variables #-}
module Handler.Login where

import Import
import Text.Cassius

formLogin:: Form UsuarioH
formLogin = renderDivs $ UsuarioH
    <$> areq textField (FieldSettings "Email" (Just "Email") (Just "email") Nothing [("class","form-control mb-3")]) Nothing
    <*> areq passwordField (FieldSettings "Senha" (Just "Senha") (Just "senha") Nothing [("class","form-control mb-3")]) Nothing

getAutR :: Handler Html
getAutR = do
    (widget,_) <- generateFormPost formLogin
    msg <- getMessage 
    defaultLayout $ do
        setTitle "Login - Controle de Doação de Sangue"
        addStylesheet (StaticR css_bootstrap_css)
        toWidgetHead $(cassiusFile "templates/menu.cassius")
        -- toWidgetHead $(cassiusFile "templates/form.cassius")
        [whamlet|
            $maybe mensa <- msg
                <div class="alert alert-danger container-lg mt-5 my-3" role="alert">
                    ^{mensa}
        |]
        $(whamletFile "templates/formlogin.hamlet")
        $(whamletFile "templates/footer.hamlet")

postAutR :: Handler Html
postAutR = do
    ((result,_),_) <- runFormPost formLogin
    case result of
        FormSuccess (UsuarioH "root@root.com" "root") -> do
            setSession "_ID" "Admin"
            redirect AdminR
        FormSuccess (UsuarioH email senha) -> do
            usuarioExiste <- runDB $ getBy (UniqueEmail email)
            case usuarioExiste of
                Nothing -> do
                    setMessage [shamlet|
                        Usuario não cadastrado
                    |]
                    redirect AutR
                Just (Entity _ usuarioH) -> do
                    if senha == usuarioHSenha usuarioH then do
                        setSession "_ID" (usuarioHEmail usuarioH)
                        redirect HomeR
                    else do
                        setMessage [shamlet|
                            Usuário ou senha incorretos!
                        |]
                        redirect AutR
        _ -> redirect HomeR

postSairR :: Handler Html
postSairR = do
    deleteSession "_ID"
    redirect AutR