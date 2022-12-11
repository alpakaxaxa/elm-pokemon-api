module Pages.Pokemon.Name_ exposing (Model, Msg, page)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Page exposing (Page)
import Route.Path
import View exposing (View)


page : { name : String } -> Page Model Msg
page params =
    Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view params
        }



-- INIT


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}
    , Cmd.none
    )



-- UPDATE


type Msg
    = ExampleMsgReplaceMe


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ExampleMsgReplaceMe ->
            ( model
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : { name : String } -> Model -> View Msg
view params model =
    { title = params.name ++ " | Pokemon"
    , body =
        [ Html.div [ class "hero is-danger py-6 has-text-centered" ]
            [ Html.h1 [ class "title is-1" ] [ Html.text params.name ]
            , Html.h2 [ class "subtitle is-6 is-underlined" ]
                [ Html.a [ Route.Path.href Route.Path.Home_ ]
                    [ Html.text "Back to Pokemon" ]
                ]
            ]
        ]
    }
