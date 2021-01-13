module Combo exposing
    ( Config, Model, State, config, init, value
    , view
    )

{-| Combobox component.


# Data

@docs Config, Model, State, config, init, value


# View

@docs view

-}

import Array exposing (fromList)
import Html exposing (..)
import Html.Attributes exposing (class, href, type_)
import Html.Events exposing (..)
import Json.Decode as Json
import Maybe exposing (withDefault)


{-| Combo options.
-}
type alias Model =
    List String


{-| Opaque type to manage the states of component.
-}
type State
    = State
        { show : Bool -- show the values
        , value : String
        , search : Maybe String
        , select : Int
        }


{-| Get the selected value.
-}
value : State -> String
value (State state) =
    state.value


{-| Initialize the component state.
-}
init : String -> State
init val =
    State { show = False, value = val, search = Nothing, select = -1 }


{-| Opaque type to configure the component (construct with the `config` function).
-}
type Config msg
    = Config
        { pipe : State -> msg
        , items : List String
        }


{-| Config constructor.
-}
config : (State -> msg) -> List String -> Config msg
config pipe items =
    Config { pipe = pipe, items = items }


{-| Component view.
-}
view : Config msg -> State -> Html msg
view (Config c) (State state) =
    let
        onShow =
            c.pipe <| State { state | show = not state.show }

        onSearch =
            \s -> c.pipe <| State { state | show = True, search = Just s, value = s }

        onSelect =
            \s -> c.pipe <| State { select = -1, show = False, value = s, search = Nothing }

        onHighlight =
            \k ->
                case k of
                    -- arrow down
                    38 ->
                        c.pipe <| State { state | show = True, select = state.select - 1 }

                    -- arrow up
                    40 ->
                        c.pipe <| State { state | show = True, select = state.select + 1 }

                    -- enter
                    13 ->
                        onSelect (at c.items state.select)

                    _ ->
                        c.pipe <| State { state | select = -1 }

        filter =
            case state.search of
                Nothing ->
                    Basics.identity

                Just s ->
                    List.filter (String.contains s)

        items =
            List.indexedMap (\i v -> viewItem onSelect (i == state.select) v) <|
                filter c.items
    in
    div [ class "grc-combo" ]
        [ div
            [ class "grc-values" ]
            [ span
                [ class "grc-search" ]
                [ input
                    [ type_ "text"
                    , Html.Attributes.value <| withDefault state.value state.search
                    , onFocus onShow
                    , onInput onSearch
                    , onKey onHighlight
                    ]
                    []
                ]
            , a
                [ class "grc-expand", onClick_ onShow, href "" ]
                [ text <| iff state.show "▲" "▼" ]
            ]
        , div [ class <| "grc-items " ++ iff state.show "grc-overlay" "is-hidden" ]
            [ ul [] items ]
        ]


viewItem : (String -> msg) -> Bool -> String -> Html msg
viewItem onSelect isSelected item =
    li [ class <| iff isSelected "grc-selected" "" ] [ a [ href "", onClick_ (onSelect item) ] [ text item ] ]


iff : Bool -> String -> String -> String
iff c t f =
    if c then
        t

    else
        f


onKey : (Int -> msg) -> Attribute msg
onKey toMsg =
    on "keyup" (Json.map toMsg keyCode)


at : List String -> Int -> String
at l i =
    Maybe.withDefault "" <| Array.get i (Array.fromList l)


onClick_ : msg -> Attribute msg
onClick_ m =
    custom "click" <|
        Json.succeed
            { message = m
            , stopPropagation = True
            , preventDefault = True
            }
