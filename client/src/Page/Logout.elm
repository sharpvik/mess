module Page.Logout exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Elements
import Html exposing (..)
import Http
import Location
import Session exposing (Session)



-- MODEL


type Model
    = Waiting Session
    | LogoutResult Session (Result String ())


toKey : Model -> Nav.Key
toKey model =
    model |> toSession |> Session.toKey


toSession : Model -> Session
toSession model =
    case model of
        Waiting session ->
            session

        LogoutResult session _ ->
            session



-- MSG


type Msg
    = GotLogoutResult (Result Http.Error ())



-- INIT


init : Session -> ( Model, Cmd Msg )
init session =
    ( Waiting session
    , Http.get
        { url = Location.apiLogout
        , expect = Http.expectWhatever GotLogoutResult
        }
    )



-- VIEW


view : Model -> Document Msg
view model =
    let
        doc body =
            { title = "Logout @Mess", body = body }
    in
    case model of
        Waiting _ ->
            doc [ Elements.loader ]

        LogoutResult _ (Ok _) ->
            doc [ Elements.loader ]

        LogoutResult _ (Err message) ->
            doc
                [ Elements.passage
                    [ h1 [] [ text "🙀 Failed to log you out" ]
                    , p [] [ text message ]
                    , p [] [ text "If you're sure that your internet is OK, you can try again, or give up and go back to your profile page." ]
                    , Elements.buttonLink Location.logout "Try Again"
                    , Elements.buttonLink Location.profile "Your Profile"
                    ]
                ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        message =
            "Server decided to take a break and did not respond... I'm not saying it's your fault, but could you please check your internet connection?"

        session =
            toSession model
    in
    case ( msg, model ) of
        ( GotLogoutResult result, _ ) ->
            case result of
                Ok _ ->
                    ( LogoutResult (Session.Guest <| Session.toKey session) <| Ok ()
                    , Nav.load Location.home
                    )

                Err _ ->
                    ( LogoutResult session <| Err message
                    , Cmd.none
                    )
