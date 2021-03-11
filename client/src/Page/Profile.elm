module Page.Profile exposing (..)

import Browser exposing (Document)
import Elements
import Html exposing (..)
import Html.Attributes exposing (..)
import Location
import Session exposing (Session)


view : Session -> Document msg
view session =
    let
        withTopbar body =
            doc <| Elements.topbar "Profile" :: body

        doc body =
            { title = "Profile @Mess"
            , body = body
            }
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
            withTopbar
                [ div [ class "passage" ]
                    [ h1 [] [ text info.name ]
                    , p []
                        [ text "Let me guess, your nickname is "
                        , span [ class "inhi" ] [ text info.handle ]
                        , text " and you are the most unique human being in the galaxy. Am I right? Of course I am!"
                        ]
                    ]
                ]