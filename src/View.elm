module View exposing (..)

import Html exposing (Html, a, div, fieldset, input, label, li, span, text, ul)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Model exposing (CalcMode(..), InputRecord, Model, Msg(..))


{-|

    Build a view that allows the user to view/modify a variable.

-}
inputView : Model -> InputRecord -> Html Msg
inputView model inputRecord =
    let
        roAttr =
            if model.calcMode == inputRecord.calcMode then
                [ readonly True ]

            else
                []

        inputAttrs =
            List.append
                [ id inputRecord.id
                , value inputRecord.value
                , onInput inputRecord.action
                ]
                roAttr
    in
    div [ class "mm-block" ]
        [ inputRecord.dropdownMenu
        , label [ for inputRecord.id ] [ text inputRecord.label ]
        , input inputAttrs []
        , span [ class "pure-form-message" ] [ text ("e.g. " ++ inputRecord.example) ]
        ]


{-|

    Build a dropdown menu that allows the user to choose a unit.

-}
unitMenu : String -> List (Html Msg) -> Html Msg
unitMenu unitSymbol menuItems =
    div [ class "pure-menu pure-menu-horizontal mm-float" ]
        [ ul [ class "pure-menu-list" ]
            [ li [ class "pure-menu-item pure-menu-has-children pure-menu-allow-hover" ]
                [ a [ href "#", class "pure-menu-link" ] [ text ("Unit: " ++ unitSymbol) ]
                , ul [ class "pure-menu-children" ] menuItems
                ]
            ]
        ]


{-|

    Build a grid that is 1, 2 or 4 across based on screen width.

-}
pureGrid : List (Html Msg) -> Html Msg
pureGrid items =
    let
        gridUnit : Html Msg -> Html Msg
        gridUnit item =
            div [ class "pure-u-1 pure-u-md-1-2 pure-u-xl-1-4" ] [ item ]

        contents : List (Html Msg)
        contents =
            List.map gridUnit items
    in
    div [ class "pure-g" ] contents


{-|

    Build a form that is stacked.

-}
pureFormStacked : List (Html Msg) -> Html Msg
pureFormStacked contents =
    Html.form [ class "pure-form pure-form-stacked" ]
        [ fieldset [] contents ]


{-|

    Build a menu item.

-}
pureMenuItem : String -> Bool -> Msg -> Html Msg
pureMenuItem itemText selected onClickAction =
    let
        itemClassList =
            [ ( "pure-menu-item", True )
            , ( "pure-menu-selected", selected )
            ]
    in
    li [ classList itemClassList ]
        [ a [ href "#", class "pure-menu-link", onClick onClickAction ] [ text itemText ] ]


{-|

    Build a view to let the user choose the calculation mode. Also includes the header link.

-}
calcModePickerView : Model -> Html Msg
calcModePickerView model =
    div [ class "pure-menu pure-menu-horizontal" ]
        [ a [ href "#", class "pure-menu-heading pure-menu-link" ]
            [ text "Movementium" ]
        , ul [ class "pure-menu-list" ]
            [ li [ class "pure-menu-item pure-menu-has-children pure-menu-allow-hover" ]
                [ a [ href "#", class "pure-menu-link" ] [ text "Mode" ]
                , ul [ class "pure-menu-children" ]
                    [ pureMenuItem "Distance" (model.calcMode == DistanceCalcMode) (SetMode DistanceCalcMode)
                    , pureMenuItem "Velocity" (model.calcMode == VelocityCalcMode) (SetMode VelocityCalcMode)
                    , pureMenuItem "Time" (model.calcMode == TimeCalcMode) (SetMode TimeCalcMode)
                    ]
                ]
            ]
        ]
