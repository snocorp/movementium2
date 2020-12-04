module Main exposing (..)

-- Press buttons to increment and decrement a counter.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/buttons.html
--


import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)



-- MAIN


main : Program () Model Msg
main =
  Browser.sandbox { init = init, update = update, view = view }



-- MODEL
type CalcMode = Distance
  | Velocity
  | Pace
  | Time


type alias Model = {
  calcMode : CalcMode,
  distance : Float,    -- meters
  velocity : Float,    -- meters/second
  pace : Float        -- seconds/meter
  }


init : Model
init = {
  calcMode = Distance,
  distance = 0.0,
  velocity = 0.0,
  pace = 0.0
  }



-- UPDATE


type Msg
  = SetMode CalcMode


update : Msg -> Model -> Model
update msg model =
  case msg of
    SetMode calcMode ->
      { model | calcMode = calcMode }



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ button [ onClick (SetMode Distance) ] [ text "Distance" ]
    , button [ onClick (SetMode Velocity) ] [ text "Velocity" ]
    , button [ onClick (SetMode Pace) ] [ text "Pace" ]
    , button [ onClick (SetMode Time) ] [ text "Time" ]
    , div [] [ text (calcModeText model.calcMode) ]
    ]

calcModeText : CalcMode -> String
calcModeText calcMode =
  case calcMode of
    Distance ->
      "Distance"
    Velocity ->
      "Velocity"
    Pace ->
      "Pace"
    Time ->
      "Time"