module Main exposing (..)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import MainTypes
    exposing
        ( Model
        , Msg(..)
        , SignupFormField(..)
        , UserData
        , userDataWithHandle
        , userDataWithName
        , userDataWithPassword
        )
import Mux
import Routes exposing (Route(..), parse)
import String exposing (fromInt)
import Url exposing (Url)



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = LinkChanged
        , onUrlRequest = LinkClicked
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- INIT


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( Model (Routes.parse url) key (UserData "" "" "") Nothing
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkChanged url ->
            ( { model | route = parse url }
            , Cmd.none
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External href ->
                    ( model
                    , Nav.load href
                    )

        SignupFormKeyDown field str ->
            let
                _ =
                    Debug.log "user data" model.userData
            in
            case field of
                Handle ->
                    ( { model | userData = userDataWithHandle model.userData str }
                    , Cmd.none
                    )

                Name ->
                    ( { model | userData = userDataWithName model.userData str }
                    , Cmd.none
                    )

                Password ->
                    ( { model | userData = userDataWithPassword model.userData str }
                    , Cmd.none
                    )

        SignupFormSubmit jsonData ->
            ( model
            , Http.post
                { url = "/api/signup"
                , body = Http.jsonBody jsonData
                , expect = Http.expectString UserSignupResult
                }
            )

        UserSignupResult result ->
            case result of
                Ok _ ->
                    ( { model | userSignupResult = Just True }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | userSignupResult = Just False }
                    , Cmd.none
                    )

        Nop _ ->
            ( model
            , Cmd.none
            )



-- PORTS
-- port info : String -> Cmd msg
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Mess"
    , body = Mux.mux model
    }
