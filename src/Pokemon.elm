module Pokemon exposing (Pokemon, getFirst150, viewPokemonList)

import Html exposing (Html)
import Html.Attributes exposing (alt, class, src)
import Http
import Json.Decode
import Route.Path


type alias PokeRecord =
    { name : String
    }


type Pokemon
    = Pokemon PokeRecord


createPokemon : { name : String } -> Pokemon
createPokemon pokeRecord =
    Pokemon pokeRecord


getFirst150 : { onResponse : Result Http.Error (List Pokemon) -> msg } -> Cmd msg
getFirst150 options =
    Http.get
        { url = "http://localhost:5000/api/v2/pokemon?limit=150"
        , expect = Http.expectJson options.onResponse pokeApiDecoder
        }


pokeApiDecoder : Json.Decode.Decoder (List Pokemon)
pokeApiDecoder =
    Json.Decode.field "results" (Json.Decode.list pokemonDecoder)


pokemonDecoder =
    Json.Decode.field "name" Json.Decode.string |> Json.Decode.andThen pokemonFromString


pokemonFromString : String -> Json.Decode.Decoder Pokemon
pokemonFromString pokeName =
    Json.Decode.succeed (createPokemon (PokeRecord pokeName))


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
