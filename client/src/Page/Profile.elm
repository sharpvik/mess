module Page.Profile exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Elements
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import IO exposing (IO)
import Json.Encode as Encode
import Location
import Route
import Session exposing (Session(..))



-- MODEL


type Model
    = View Session
    | Edit Session UserData
    | EditResult Session (IO String String)


toSession : Model -> Session
toSession model =
    case model of
        View session ->
            session

        Edit session _ ->
            session

        EditResult session _ ->
            session


toUserData : Session -> UserData
toUserData session =
    case session of
        Session.User _ info ->
            UserData info.handle info.name ""

        _ ->
            UserData "" "" ""



-- MSG


type Msg
    = KeyDown FieldCase String
    | SubmitChanges Encode.Value
    | GotEditResult (Result String String)
    | Reload


type FieldCase
    = HandleField
    | NameField
    | PasswordField



-- INIT


init : Session -> Route.ProfileCase -> ( Model, Cmd Msg )
init session profileCase =
    case profileCase of
        Route.ViewProfile ->
            ( View session, Cmd.none )

        Route.EditProfile ->
            ( Edit session <| toUserData session, Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        session =
            toSession model
    in
    case msg of
        KeyDown field str ->
            case model of
                Edit _ userData ->
                    ( Edit session <| updateUserDataWith userData field str
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SubmitChanges json ->
            ( EditResult session IO.Loading
            , Http.post
                { url = Location.apiProfile
                , body = Http.jsonBody json
                , expect = expectResponseMessage GotEditResult
                }
            )

        GotEditResult result ->
            ( EditResult session <| IO.Finished result
            , Cmd.none
            )

        Reload ->
            ( model
            , Nav.load Location.logout
            )



-- VIEW


expectResponseMessage :
    (Result String String -> msg)
    -> Http.Expect msg
expectResponseMessage toMsg =
    Http.expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadStatus_ _ message ->
                    Err message

                Http.GoodStatus_ _ message ->
                    Ok message

                _ ->
                    Err "Something went terribly wrong... I'll try to fix it. Meanwhile, check your internet connection just in case!"


view : Model -> Document Msg
view model =
    let
        topbar =
            Elements.topbarWithRightSide "Profile" <|
                div [] [ a [ href Location.logout ] [ text "Log Out" ] ]

        withTopbar body =
            doc <| topbar :: body

        doc body =
            { title = "Profile @Mess"
            , body = body
            }

        session =
            toSession model
    in
    case session of
        Session.DidNotCheckYet _ ->
            doc [ Elements.loader ]

        Session.Guest _ ->
            withTopbar
                [ div [ class "passage" ]
                    [ h1 [] [ text "Hmm... How did you get here?" ]
                    , p []
                        [ text "It looks like you are not logged in. If you want to log in or create an account, check out the Auth Page!" ]
                    , p []
                        [ text "If you've just logged in, simply refresh the page." ]
                    , a [ class "button", href Location.login ] [ text "Auth Page" ]
                    ]
                ]

        Session.User _ info ->
            case model of
                View _ ->
                    viewProfile withTopbar info

                Edit _ userData ->
                    viewEdit withTopbar userData

                EditResult _ io ->
                    viewEditResult doc withTopbar io


viewEditResult :
    (List (Html Msg) -> Document Msg)
    -> (List (Html Msg) -> Document Msg)
    -> IO String String
    -> Document Msg
viewEditResult doc withTopbar io =
    case io of
        IO.Finished (Ok message) ->
            withTopbar
                [ Elements.passage
                    [ h1 [] [ text "Success!" ]
                    , p [] [ text message ]
                    , p [] [ text "You'll need to re-log in now." ]
                    , Elements.buttonLinkWithOnClick
                        "Logout"
                        Reload
                    ]
                ]

        IO.Finished (Err message) ->
            withTopbar
                [ Elements.passage
                    [ h1 [] [ text "Failure..." ]
                    , p [] [ text message ]
                    , Elements.buttonLink Location.profileEdit "Try Again"
                    , Elements.buttonLink Location.profile "Your Profile"
                    ]
                ]

        _ ->
            doc [ Elements.loader ]


viewProfile : (List (Html Msg) -> Document Msg) -> Session.Info -> Document Msg
viewProfile withTopbar info =
    withTopbar
        [ Elements.passage
            [ img [ src Location.apiAvatar ] []
            , h1 [] [ text info.name ]
            , p []
                [ text "Your nickname is "
                , span [ class "inhi" ] [ text info.handle ]
                ]
            , Elements.buttonLink Location.profileEdit "Edit"
            ]
        ]


viewEdit : (List (Html Msg) -> Document Msg) -> UserData -> Document Msg
viewEdit withTopbar user =
    let
        requiredInputField type__ name_ placeholder_ maxLength val onIn =
            input
                [ type_ type__
                , name name_
                , placeholder placeholder_
                , required True
                , value val
                , maxlength maxLength
                , onInput onIn
                ]
                []

        handleInput =
            requiredInputField "text" "handle" "Username" 100

        nameInput =
            requiredInputField "text" "name" "Your Name" 100

        passwordInput =
            requiredInputField "password" "password" "Password" 64

        submitButton =
            div []
                [ button
                    [ class "button"
                    , type_ "submit"
                    ]
                    [ text "Submit" ]
                ]
    in
    withTopbar
        [ Elements.passage
            [ img [ src Location.apiAvatar ] []
            ]
        , div [ class "creds-form-container" ]
            [ div [ class "tabs" ]
                [ a [ class "tab active" ] [ text "Edit" ]
                ]
            , Html.form
                [ class "creds-form"
                , onSubmit <| SubmitChanges <| jsonEncodeUserData user
                ]
                [ handleInput user.handle (KeyDown HandleField)
                , nameInput user.name (KeyDown NameField)
                , passwordInput user.password (KeyDown PasswordField)
                , submitButton
                ]
            ]
        ]



-- USER DATA


type alias UserData =
    { handle : String
    , name : String
    , password : String
    }


updateUserDataWith : UserData -> FieldCase -> String -> UserData
updateUserDataWith user field str =
    case field of
        HandleField ->
            { user | handle = str }

        NameField ->
            { user | name = str }

        PasswordField ->
            { user | password = str }


jsonEncodeUserData : UserData -> Encode.Value
jsonEncodeUserData data =
    Encode.object
        [ ( "handle", Encode.string data.handle )
        , ( "name", Encode.string data.name )
        , ( "password", Encode.string data.password )
        ]
