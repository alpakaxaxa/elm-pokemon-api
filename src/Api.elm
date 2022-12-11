module Api exposing
    ( Data(..)
    , toUserFriendlyMessage
    )

import Html.Attributes exposing (value)
import Http


type Data value
    = Loading
    | Success value
    | Failure Http.Error


toUserFriendlyMessage : Http.Error -> String
toUserFriendlyMessage httpError =
    case httpError of
        Http.BadUrl _ ->
            "This page requested a bad URL"

        Http.Timeout ->
            "Request took too long to respond"

        Http.NetworkError ->
            "Could not connect to the API"

        Http.BadStatus code ->
            if code == 404 then
                "Item not found"

            else
                "API returned an error code"

        Http.BadBody _ ->
            "Unexpected response from API"
