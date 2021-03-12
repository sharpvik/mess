module Main exposing (..)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Elements
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Location
import Page.Auth
import Page.Home
import Page.Profile
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)



-- MAIN


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = LinkChanged
        , onUrlRequest = LinkClicked
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type Model
    = Redirect Session Route
    | Home Session
    | Signup Session Page.Auth.Model
    | Profile Session


toKey : Model -> Nav.Key
toKey model =
    model |> toSession |> Session.toKey


toSession : Model -> Session
toSession model =
    case model of
        Redirect session _ ->
            session

        Home session ->
            session

        Signup session _ ->
            session

        Profile session ->
            session



-- MSG


type Msg
    = LinkClicked UrlRequest
    | LinkChanged Url
    | GotAuthMsg Page.Auth.Msg
    | GotSession (Result Http.Error Session.Info)



-- INIT


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        route =
            Route.fromUrl url
    in
    mux route (Redirect (Session.DidNotCheckYet key) route)


mux : Route -> Model -> ( Model, Cmd Msg )
mux route model =
    -- We use this multiplexer to control virtual routing within the app.
    let
        norm :
            (subModel -> model)
            -> (subMsg -> msg)
            -> ( subModel, Cmd subMsg )
            -> ( model, Cmd msg )
        norm toModel toMsg ( subModel, cmd ) =
            ( toModel subModel, Cmd.map toMsg cmd )

        session =
            toSession model

        -- We need this function because basic redirections trough recursive
        -- calls to mux leave browser URL unattended, which is improper.
        redirectToRouteIfNotLoggedIn redirectLocation loggedIn =
            case session of
                Session.User _ _ ->
                    loggedIn

                _ ->
                    ( model
                    , Nav.pushUrl (toKey model) redirectLocation
                    )
    in
    case ( route, session ) of
        ( _, Session.DidNotCheckYet _ ) ->
            ( Redirect session route
            , Http.get
                { url = Location.apiProfile
                , expect = Http.expectJson GotSession Session.decoder
                }
            )

        ( Route.Home, _ ) ->
            ( Home session, Cmd.none )

        ( Route.Auth subRoute, _ ) ->
            norm
                (Signup session)
                GotAuthMsg
                (Page.Auth.init subRoute)

        ( Route.Profile, _ ) ->
            redirectToRouteIfNotLoggedIn
                Location.home
                -- ▲ redirecting Home if user is just a guest
                -- ▼ or to Profile if user is logged in
                ( Profile session, Cmd.none )



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

        Home session ->
            Page.Home.view session

        Signup _ signupModel ->
            norm GotAuthMsg (Page.Auth.view signupModel)

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

        key =
            toKey model
    in
    case ( msg, model ) of
        ( LinkChanged url, _ ) ->
            mux (Route.fromUrl url) model

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl key (Url.toString url)
                    )

                External href ->
                    ( model
                    , Nav.load href
                    )

        ( GotAuthMsg signupMsg, Signup session signupModel ) ->
            Page.Auth.update signupMsg signupModel
                |> norm (Signup session) GotAuthMsg

        ( GotSession result, Redirect _ route ) ->
            case result of
                Ok info ->
                    mux route <| Redirect (Session.User key info) route

                Err _ ->
                    mux route <| Redirect (Session.Guest key) route

        _ ->
            ( model, Cmd.none )



-- UNUSED


type alias Flags =
    ()


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
