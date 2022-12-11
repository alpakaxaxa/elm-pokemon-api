module Pokemon exposing (Pokemon, getFirst150, getPokedexId, getPokemon, getPokemonName, getPokemonPicture, getPokemonTypes, initEmptyPokemon, viewPokemonList)

import Html exposing (Html)
import Html.Attributes exposing (alt, class, src)
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (required, requiredAt)
import Route.Path


type alias PokeRecord =
    { name : String
    , order : Int
    , picture : String
    , types : List String
    }


type Pokemon
    = Pokemon PokeRecord


createPokemon : PokeRecord -> Pokemon
createPokemon pokeRecord =
    Pokemon pokeRecord


getFirst150 : { onResponse : Result Http.Error (List Pokemon) -> msg } -> Cmd msg
getFirst150 options =
    Http.get
        { url = "http://localhost:5000/api/v2/pokemon?limit=150"
        , expect = Http.expectJson options.onResponse pokeApiDecoder
        }


initEmptyPokemon : Pokemon
initEmptyPokemon =
    createPokemon { name = "", order = 0, picture = "", types = [] }


getPokemon : { name : String, onResponse : Result Http.Error Pokemon -> msg } -> Cmd msg
getPokemon options =
    Http.get
        { url = "http://localhost:5000/api/v2/pokemon/" ++ options.name
        , expect = Http.expectJson options.onResponse pokemonDetailsDecoder
        }


pokeApiDecoder : Json.Decode.Decoder (List Pokemon)
pokeApiDecoder =
    Json.Decode.field "results" (Json.Decode.list pokemonNameDecoder)


pokemonNameDecoder =
    Json.Decode.field "name" Json.Decode.string |> Json.Decode.andThen pokemonFromString


pokemonFromString : String -> Json.Decode.Decoder Pokemon
pokemonFromString pokeName =
    Json.Decode.succeed (createPokemon (PokeRecord pokeName 0 "" []))


pokemonFromPokeRecord : String -> Int -> String -> List String -> Json.Decode.Decoder Pokemon
pokemonFromPokeRecord name order pictureUrl types =
    Json.Decode.succeed (createPokemon (PokeRecord name order pictureUrl types))



{- pokemonDetailsDecoder : Json.Decode.Decoder Pokemon
   pokemonDetailsDecoder =
       Json.Decode.map3 pokemonFromPokeRecord
           (Json.Decode.at [ "name" ] Json.Decode.string)
           (Json.Decode.at [ "order" ] Json.Decode.int)
           (Json.Decode.at [ "sprites", "other", "official-artwork", "front_default" ] Json.Decode.string)
-}


pokemonDetailsDecoder : Json.Decode.Decoder Pokemon
pokemonDetailsDecoder =
    let
        pokeRecordDecoder =
            Json.Decode.map4 PokeRecord
                (Json.Decode.field "name" Json.Decode.string)
                (Json.Decode.field "order" Json.Decode.int)
                (Json.Decode.field "sprites" spriteUrlFieldDecoder)
                (Json.Decode.field "types" typesFieldDecoder)
    in
    Json.Decode.map Pokemon pokeRecordDecoder



{- Json.Decode.succeed pokemonFromPokeRecord
   |> required "name" Json.Decode.string
   |> required "order" Json.Decode.int
   |> requiredAt [ "sprites", "other", "official-artwork", "front_default" ] Json.Decode.string
   |> required "types" (Json.Decode.list pokemonTypeDecoder)
-}
{- Json.Decode.succeed
   (\name order pictureUrl types -> pokemonFromPokeRecord name order pictureUrl types)
   |> required "name" Json.Decode.string
   |> required "order" Json.Decode.int
   |> requiredAt [ "sprites", "other", "official-artwork", "front_default" ] Json.Decode.string
   |> required "types" (Json.Decode.list pokemonTypeDecoder)
-}
{- Json.Decode.map4 pokemonFromPokeRecord
   (Json.Decode.field "name" Json.Decode.string)
   (Json.Decode.field "order" Json.Decode.int)
   (Json.Decode.at [ "sprites", "other", "official-artwork", "front_default" ] Json.Decode.string)
   (Json.Decode.field "types" (Json.Decode.list pokemonTypeDecoder))
-}


nameFieldDecoder =
    Json.Decode.field "name" Json.Decode.string


pokeIdFieldDecoder =
    Json.Decode.field "order" Json.Decode.int


spriteUrlFieldDecoder : Json.Decode.Decoder String
spriteUrlFieldDecoder =
    --[ "sprites", "other", "official-artwork", "front_default" ]
    Json.Decode.at
        [ "other", "official-artwork", "front_default" ]
        Json.Decode.string


typesFieldDecoder : Json.Decode.Decoder (List String)
typesFieldDecoder =
    Json.Decode.list pokemonTypeDecoder


pokemonTypeDecoder =
    Json.Decode.at [ "type", "name" ] Json.Decode.string


viewPokemonList : List Pokemon -> Html msg
viewPokemonList listOfPokemon =
    Html.div [ class "container py-6 p-5" ]
        [ Html.div [ class "columns is-multiline" ]
            (List.indexedMap viewPokemon listOfPokemon)
        ]


viewPokemon : Int -> Pokemon -> Html msg
viewPokemon index pokemon =
    let
        pokedexNumber : Int
        pokedexNumber =
            index + 1

        pokemonImageUrl : String
        pokemonImageUrl =
            "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/"
                ++ String.fromInt pokedexNumber
                ++ ".png"

        pokemonDetailRoute : Route.Path.Path
        pokemonDetailRoute =
            Route.Path.Pokemon__Name_
                -- don't forget to save
                { name = getPokemonName pokemon
                }
    in
    Html.div [ class "column is-4-desktop is-6-tablet" ]
        [ Html.a [ Route.Path.href pokemonDetailRoute ]
            [ Html.div [ class "card" ]
                [ Html.div [ class "card-content" ]
                    [ Html.div [ class "media" ]
                        [ Html.div [ class "media-left" ]
                            [ Html.figure [ class "image is-64x64" ]
                                [ Html.img [ src pokemonImageUrl, alt (getPokemonName pokemon) ] []
                                ]
                            ]
                        , Html.div [ class "media-content" ]
                            [ Html.p [ class "title is-4" ] [ Html.text (getPokemonName pokemon) ]
                            , Html.p [ class "subtitle is-6" ] [ Html.text ("No. " ++ String.fromInt pokedexNumber) ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


getPokemonName : Pokemon -> String
getPokemonName pokemon =
    case pokemon of
        Pokemon pokeRecord ->
            pokeRecord.name


getPokedexId : Pokemon -> Int
getPokedexId pokemon =
    case pokemon of
        Pokemon pokeRecord ->
            pokeRecord.order


getPokemonPicture : Pokemon -> String
getPokemonPicture pokemon =
    case pokemon of
        Pokemon pokeRecord ->
            pokeRecord.picture


getPokemonTypes : Pokemon -> List String
getPokemonTypes pokemon =
    case pokemon of
        Pokemon pokeRecord ->
            pokeRecord.types
