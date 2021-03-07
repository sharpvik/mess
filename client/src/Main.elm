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



-- TYPES


type Model
    = Redirect Session
    | Home Session
    | Signup Session Page.Auth.Model
    | Profile Session


type Msg
    = LinkClicked UrlRequest
    | LinkChanged Url
    | GotSignupMsg Page.Auth.Msg



-- INIT


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        session =
            Session.dummy key
    in
    mux (Route.fromUrl url) (Redirect session)


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
            ( Home <| toSession model, Cmd.none )

        Route.Auth subRoute ->
            norm
                (Signup <| toSession model)
                GotSignupMsg
                (Page.Auth.init subRoute)

        Route.Profile ->
            ( Profile (toSession model), Cmd.none )



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

        Home session ->
            Page.Home.view session

        Signup _ signupModel ->
            norm GotSignupMsg (Page.Auth.view signupModel)

        Profile session ->
            Page.Profile.view session



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
                Signup session signupModel ->
                    Page.Auth.update signupMsg signupModel
                        |> norm (Signup session) GotSignupMsg

                _ ->
                    ( model, Cmd.none )


toKey : Model -> Nav.Key
toKey model =
    let
        session =
            toSession model
    in
    case session of
        Session.Guest key ->
            key

        Session.User key _ _ ->
            key


toSession : Model -> Session
toSession model =
    case model of
        Redirect session ->
            session

        Home session ->
            session

        Signup session _ ->
            session

        Profile session ->
            session


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
