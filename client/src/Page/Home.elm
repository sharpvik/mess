module Page.Home exposing (..)

import Browser exposing (Document)
import Elements
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Location
import Session exposing (Session)


view : Session -> Document msg
view session =
    let
        withHeaderRightSide rightSide =
            [ Elements.topbarWithRightSide "Mess" rightSide
            , section [ class "passage" ]
                [ h1 [] [ text "Coming soon..." ]
                , p []
                    [ text "Mess chat app is currently under construction. We're working hard to create a new way of building local communities using technology and internet."
                    ]
                , a
                    [ class "button"
                    , href Location.repo
                    ]
                    [ text "Contribute" ]
                ]
            ]
    in
    case session of
        Session.User _ info ->
            { title = "Home @Mess"
            , body =
                withHeaderRightSide <|
                    div []
                        [ a [ href Location.profile ]
                            [ text <| info.name ++ "'s Account" ]
                        ]
            }

        _ ->
            { title = "Home @Mess"
            , body =
                withHeaderRightSide <|
                    div []
                        [ a [ href Location.signup ] [ text "Sign Up" ]
                        , text " | "
                        , a [ href Location.login ] [ text "Log In" ]
                        ]
            }
