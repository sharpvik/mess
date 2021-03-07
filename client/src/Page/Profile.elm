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
        topbar =
            Elements.topbar "Profile"

        page body =
            { title = "Profile @Mess"
            , body = topbar :: body
            }
    in
    case session of
        Session.Guest _ ->
            page
                [ div [ class "passage" ]
                    [ h1 [] [ text "Hmm... How did you get here?" ]
                    , p [] [ text "It looks like you are not logged in. Do you even have an account with me? In any case, check out the Auth Page!" ]
                    , a [ class "button", href Location.login ] [ text "Auth Page" ]
                    ]
                ]

        Session.User _ handle name ->
            page
                [ div [ class "passage" ]
                    [ h1 [] [ text name ]
                    , p []
                        [ text "Let me guess, your nickname is "
                        , span [ class "inhi" ] [ text handle ]
                        , text " and you are the most unique human being in the galaxy. Am I right? Of course I am!"
                        ]
                    ]
                ]
