module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Task
import Time



-- MAIN


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Flags =
    Int


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    }


init : Flags -> ( Model, Cmd Msg )
init current =
    ( Model Time.utc (Time.millisToPosix current)
    , Task.perform AdjustTimeZone Time.here
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 Tick



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Mess"
    , body = body model
    }


body : Model -> List (Html Msg)
body model =
    [ header []
        [ h1 [] [ text "Mess" ]
        , time model
        ]
    , section [ class "warning" ]
        [ h1 [] [ text "Coming soon..." ]
        , p []
            [ text "Mess chat app is currently under construction. We're working hard to create a new way of building local communities using technology and internet."
            ]
        , a [ href "https://github.com/sharpvik/mess" ] [ text "Contribute" ]
        ]
    ]



-- UTIL


time : Model -> Html Msg
time model =
    let
        hour =
            timeFormat (Time.toHour model.zone model.time)

        minute =
            timeFormat (Time.toMinute model.zone model.time)

        second =
            timeFormat (Time.toSecond model.zone model.time)
    in
    pre [] [ text (hour ++ ":" ++ minute ++ ":" ++ second) ]


timeFormat : Int -> String
timeFormat i =
    let
        s =
            String.fromInt i
    in
    if String.length s == 1 then
        "0" ++ s

    else
        s
