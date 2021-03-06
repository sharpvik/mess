module Main exposing (..)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Elements
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Auth
import Page.Home
import Page.Profile
import Route exposing (Route)
import Session exposing (Session)
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
    mux Session.dummy (Route.fromUrl url) (Redirect key Session.dummy)


mux : Session -> Route -> Model -> ( Model, Cmd Msg )
mux session route model =
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
            ( Home (toKey model) (toSession model), Cmd.none )

        Route.Auth subRoute ->
            norm
                (Signup (toKey model) (toSession model))
                GotSignupMsg
                (Page.Auth.init subRoute)

        Route.Profile ->
            ( Profile (toKey model) (toSession model), Cmd.none )



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
        Redirect _ _ ->
            { title = "Redirecting..."
            , body = [ Elements.loader ]
            }

        Home _ session ->
            Page.Home.view session

        Signup _ _ signupModel ->
            norm GotSignupMsg (Page.Auth.view signupModel)

        Profile _ session ->
            Page.Profile.view session



-- TYPES


type Model
    = Redirect Nav.Key Session
    | Home Nav.Key Session
    | Signup Nav.Key Session Page.Auth.Model
    | Profile Nav.Key Session


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
            mux (toSession model) (Route.fromUrl url) model

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
                Signup key session signupModel ->
                    Page.Auth.update signupMsg signupModel
                        |> norm (Signup key session) GotSignupMsg

                _ ->
                    ( model, Cmd.none )


toKey : Model -> Nav.Key
toKey model =
    case model of
        Redirect key _ ->
            key

        Home key _ ->
            key

        Signup key _ _ ->
            key

        Profile key _ ->
            key


toSession : Model -> Session
toSession model =
    case model of
        Redirect _ session ->
            session

        Home _ session ->
            session

        Signup _ session _ ->
            session

        Profile _ session ->
            session


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
