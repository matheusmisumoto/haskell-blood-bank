{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-deferred-type-errors #-}
{-# OPTIONS_GHC -Wno-deferred-out-of-scope-variables #-}
module Handler.FormDoador where

import Import
import Text.Cassius

-- /cadastrardoador     CadastrardR     GET POST
formDoador :: Maybe Doador -> Form Doador
formDoador doador = renderDivs $ Doador
    <$> areq textField (FieldSettings "Nome do Doador" (Just "Nome do Doador") (Just "doador") Nothing [("class","form-control mb-3")]) (fmap doadorNome doador)
    <*> areq textField (FieldSettings "CPF" (Just "CPF") (Just "cpf") Nothing [("class","form-control mb-3")]) (fmap doadorCpf doador)
    <*> areq intField (FieldSettings "Idade" (Just "Idade") (Just "idade") Nothing [("class","form-control mb-3")]) (fmap doadorIdade doador)
    <*> areq (selectField $ optionsPairs [("A" :: Text, "A"),("B", "B"),("AB", "AB"),("O", "O")]) (FieldSettings "Tipo Sanquineo" (Just "Tipo Sanquineo") (Just "Tipo Sanquineo") Nothing [("class","form-select mb-3")]) (fmap doadorTipoS doador)
    <*> areq (selectField $ optionsPairs [("+" :: Text, "+"),("-", "-")]) (FieldSettings "RH" (Just "RH") (Just "RH") Nothing [("class","form-select mb-3")]) (fmap doadorRh doador)

getCadastrardR :: Handler Html
getCadastrardR = do
    (widget,_) <- generateFormPost (formDoador Nothing)
    msg <- getMessage 
    defaultLayout $ do
        setTitle "Cadastrar Doador - Controle de Doação de Sangue"
        addStylesheet (StaticR css_bootstrap_css)
        addScript (StaticR js_bootstrap_js)
        toWidgetHead $(cassiusFile "templates/menu.cassius")
        toWidgetHead $(cassiusFile "templates/content.cassius")
        $(whamletFile "templates/menu.hamlet")
        toWidgetHead $(cassiusFile "templates/form.cassius")
        [whamlet|
            $maybe mensa <- msg
                <div class="alert alert-success container-lg mt-5 my-3" role="alert">
                    ^{mensa}
        |]
        $(whamletFile "templates/formdoador.hamlet")
        $(whamletFile "templates/footer.hamlet")

postCadastrardR :: Handler Html
postCadastrardR = do
    ((result,_),_) <- runFormPost (formDoador Nothing)
    case result of
        FormSuccess doador -> do
            _ <- runDB $ insert doador
            setMessage [shamlet|
                Doador cadastrado com sucesso!
            |]
            redirect CadastrardR
        _ -> redirect HomeR


-- /doador/#DoadorId/editar              EditardR        GET POST
getEditardR :: DoadorId -> Handler Html
getEditardR did = do
    doador <- runDB $ get404 did
    (widget,_) <- generateFormPost (formDoador (Just doador))
    msg <- getMessage 
    defaultLayout $ do
        setTitle "Editar Doador - Controle de Doação de Sangue"
        addStylesheet (StaticR css_bootstrap_css)
        addScript (StaticR js_bootstrap_js)
        toWidgetHead $(cassiusFile "templates/menu.cassius")
        toWidgetHead $(cassiusFile "templates/content.cassius")
        $(whamletFile "templates/menu.hamlet")
        toWidgetHead $(cassiusFile "templates/form.cassius")
        [whamlet|
            $maybe mensa <- msg
                <div class="alert alert-success container-lg mt-5 my-3" role="alert">
                    ^{mensa}
        |]
        $(whamletFile "templates/formeditardoador.hamlet")
        $(whamletFile "templates/footer.hamlet")

postEditardR :: DoadorId -> Handler Html
postEditardR did = do
    doadorAntigo <- runDB $ get404 did
    ((result,_),_) <- runFormPost (formDoador Nothing)
    case result of
        FormSuccess novoCliente -> do
            runDB $ replace did novoCliente
            setMessage [shamlet|
                Doador editado com sucesso!
            |]
            redirect ListardR
        _ -> redirect HomeR