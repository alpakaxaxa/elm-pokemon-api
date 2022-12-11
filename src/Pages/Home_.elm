module Pages.Home_ exposing (Model, Msg, page)

import Api exposing (..)
import Html exposing (Html)
import Html.Attributes exposing (alt, class, src)
import Http
import Page exposing (Page)
import Pokemon exposing (Pokemon, getFirst150, viewPokemonList)
import View exposing (View)


page : Page Model Msg
page =
    Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { pokemonData : Api.Data (List Pokemon)
    , pokemon : List Pokemon
    }


init : ( Model, Cmd Msg )
init =
    ( { pokemonData = Api.Loading
      , pokemon = []
      }
    , Pokemon.getFirst150
        { onResponse = PokeApiResponded
        }
    )



-- UPDATE


type Msg
    = PokeApiResponded (Result Http.Error (List Pokemon))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PokeApiResponded (Ok listOfPokemon) ->
            ( { model | pokemonData = Api.Success [], pokemon = listOfPokemon }
            , Cmd.none
            )

        PokeApiResponded (Err httpError) ->
            ( { model | pokemonData = Api.Failure httpError }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pokemon"
    , body =
        [ Html.div [ class "hero is-danger py-6 has-text-centered" ]
            [ Html.h1 [ class "title is-1" ] [ Html.text "Pokemon" ]
            , Html.h2 [ class "subtitle is-4" ] [ Html.text "Gotta fetch em all!" ]
            ]
        , case model.pokemonData of
            Api.Loading ->
                Html.text "Loading..."

            Api.Failure httpError ->
                Html.div [ class "has-text-centered p-6" ]
                    [ Html.text (Api.toUserFriendlyMessage httpError) ]

            Api.Success _ ->
                viewPokemonList model.pokemon
        ]
    }
