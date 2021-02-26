module Main exposing (..)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Elements
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Auth
import Page.Home
import Route exposing (Route)
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
    mux (Route.fromUrl url) (Redirect key)


mux : Route -> Model -> ( Model, Cmd Msg )
mux route model =
    let
        norm :
            (subModel -> model)
            -> (subMsg -> msg)
            -> ( subModel, Cmd subMsg )
            -> ( model, Cmd msg )
        norm toModel toMsg ( subModel, cmd ) =
            ( toModel subModel, Cmd.map toMsg cmd )
    in
    case route of
        Route.Home ->
            ( Home (toKey model), Cmd.none )

        Route.Auth subRoute ->
            norm (Signup (toKey model)) GotSignupMsg (Page.Auth.init subRoute)



-- VIEW


view : Model -> Document Msg
view model =
    let
        norm : (msg -> a) -> Document msg -> Document a
        norm toMsg { title, body } =
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Redirect _ ->
            { title = "Redirecting..."
            , body = [ Elements.loader ]
            }

        Home _ ->
            Page.Home.view

        Signup _ signupModel ->
            norm GotSignupMsg (Page.Auth.view signupModel)



-- TYPES


type Model
    = Redirect Nav.Key
    | Home Nav.Key
    | Signup Nav.Key Page.Auth.Model


type Msg
    = LinkClicked UrlRequest
    | LinkChanged Url
    | GotSignupMsg Page.Auth.Msg



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        norm :
            (subModel -> model)
            -> (subMsg -> msg)
            -> ( subModel, Cmd subMsg )
            -> ( model, Cmd msg )
        norm toModel toMsg ( subModel, cmd ) =
            ( toModel subModel, Cmd.map toMsg cmd )
    in
    case msg of
        LinkChanged url ->
            mux (Route.fromUrl url) model

        LinkClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl (toKey model) (Url.toString url)
                    )

                External href ->
                    ( model
                    , Nav.load href
                    )

        GotSignupMsg signupMsg ->
            case model of
                Signup key signupModel ->
                    Page.Auth.update signupMsg signupModel
                        |> norm (Signup key) GotSignupMsg

                _ ->
                    ( model, Cmd.none )


toKey : Model -> Nav.Key
toKey model =
    case model of
        Redirect key ->
            key

        Home key ->
            key

        Signup key _ ->
            key



-- PORTS
-- port info : String -> Cmd msg
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
