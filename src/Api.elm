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



{- import Json.Decode exposing (Decoder)
   import Json.Decode.Pipeline exposing (required)

   type alias Pokemon =
       { count : Int
       , next : String
       , previous : Maybe String
       , results : List PokemonResult
       }

   type alias PokemonResult =
       { name : String
       , url : String
       }

   decodePokemon : Decoder Pokemon
   decodePokemon =
       Json.object4
           Pokemon
           ("count" := required int)
           ("next" := required string)
           ("previous" := nullable string)
           ("results" := required (list decodePokemonResult))

   decodePokemonResult : Decoder PokemonResult
   decodePokemonResult =
       Json.object2
           PokemonResult
           ("name" := required string)
           ("url" := required string)

   decodePokemonList : String -> Result String Pokemon
   decodePokemonList json =
       Json.Decode.decodeString decodePokemon json
-}
