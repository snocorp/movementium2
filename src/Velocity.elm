module Velocity exposing (formatPace, formatVelocity, normalizePace, normalizeVelocity, paceUnitMenu, paceView, velocityFromMetersPerSecondToUnit, velocityUnitMenu, velocityView)

import Distance exposing (distanceUnitInMeters, distanceUnitSymbol)
import Html exposing (Html)
import Model exposing (..)
import Parser exposing (..)
import Round
import Speed exposing (Speed)
import Time exposing (durationToSeconds, formatTime, normalizeTime)
import View exposing (inputView, pureMenuItem, unitMenu)


{-|

    Converts a velocity in meters per second into a value in the given unit.

-}
velocityFromMetersPerSecondToUnit : Float -> VelocityUnit -> Float
velocityFromMetersPerSecondToUnit value unit =
    case unit of
        MetersPerSecond ->
            value

        KilometersPerHour ->
            Speed.inKilometersPerHour (Speed.metersPerSecond value)

        MilesPerHour ->
            Speed.inMilesPerHour (Speed.metersPerSecond value)


{-|

    Build a menu to allow the user to choose the output unit for the velocity.

-}
velocityUnitMenu : Model -> Html Msg
velocityUnitMenu model =
    unitMenu (velocityUnitSymbol model.velocityUnit)
        [ pureMenuItem "m/s" (model.velocityUnit == MetersPerSecond) (SetVelocityUnit MetersPerSecond)
        , pureMenuItem "km/h" (model.velocityUnit == KilometersPerHour) (SetVelocityUnit KilometersPerHour)
        , pureMenuItem "mph" (model.velocityUnit == MilesPerHour) (SetVelocityUnit MilesPerHour)
        ]


{-|

    Build a view that displays the velocity input.

-}
velocityView : Model -> Html Msg
velocityView model =
    inputView model
        { calcMode = VelocityCalcMode
        , label = "Velocity"
        , id = "velocity"
        , value = model.velocityInput
        , example = "12 km/h"
        , action = SetVelocity
        , dropdownMenu = velocityUnitMenu model
        }


{-|

    Build a menu to allow the user to choose the output unit for the pace.

-}
paceUnitMenu : Model -> Html Msg
paceUnitMenu model =
    unitMenu (distanceUnitSymbol model.paceUnit)
        [ pureMenuItem "m" (model.paceUnit == Meter) (SetPaceUnit Meter)
        , pureMenuItem "km" (model.paceUnit == Kilometer) (SetPaceUnit Kilometer)
        , pureMenuItem "yd" (model.paceUnit == Yard) (SetPaceUnit Yard)
        , pureMenuItem "mi" (model.paceUnit == Mile) (SetPaceUnit Mile)
        ]


{-|

    Build a view that displays the pace input.

-}
paceView : Model -> Html Msg
paceView model =
    inputView model
        { calcMode = VelocityCalcMode
        , label = "Pace"
        , id = "pace"
        , value = model.paceInput
        , example = "5:00/km"
        , action = SetPace
        , dropdownMenu = paceUnitMenu model
        }


{-|

    Converts a velocity unit into its corresponsing symbol

-}
velocityUnitSymbol : VelocityUnit -> String
velocityUnitSymbol unit =
    case unit of
        MetersPerSecond ->
            "m/s"

        KilometersPerHour ->
            "km/h"

        MilesPerHour ->
            "mph"


{-|

    Formats a velocity as a string with its unit.

-}
formatVelocity : Maybe Velocity -> String
formatVelocity velocity =
    case velocity of
        Just v ->
            Round.round 2 v.value ++ " " ++ velocityUnitSymbol v.unit

        Nothing ->
            "(invalid)"


parseVelocity : String -> Result (List DeadEnd) Velocity
parseVelocity input =
    let
        value : Parser Float
        value =
            float

        unit : Parser VelocityUnit
        unit =
            oneOf
                [ Parser.map (\_ -> MetersPerSecond) (keyword "m/s")
                , Parser.map (\_ -> KilometersPerHour) (keyword "km/h")
                , Parser.map (\_ -> MilesPerHour) (keyword "mph")
                ]

        parser : Parser Velocity
        parser =
            succeed Velocity
                |= value
                |. spaces
                |= unit
    in
    run parser input


{-|

    Converts a velocity into a value in meters per second.

-}
velocityInMetersPerSecond : Velocity -> Float
velocityInMetersPerSecond velocity =
    let
        speed : Speed
        speed =
            case velocity.unit of
                MetersPerSecond ->
                    Speed.metersPerSecond velocity.value

                KilometersPerHour ->
                    Speed.kilometersPerHour velocity.value

                MilesPerHour ->
                    Speed.milesPerHour velocity.value
    in
    Speed.inMetersPerSecond speed


{-|

    Parses a velocity string and converts it to meters per second.

-}
normalizeVelocity : String -> Maybe Velocity
normalizeVelocity input =
    let
        convertToMetersPerSecond : Velocity -> Velocity
        convertToMetersPerSecond velocity =
            { value = velocityInMetersPerSecond velocity
            , unit = MetersPerSecond
            }
    in
    Maybe.map convertToMetersPerSecond <|
        Result.toMaybe (parseVelocity input)


{-|

    Parses a pace string.

-}
parsePace : String -> Maybe Pace
parsePace input =
    let
        split : List String
        split =
            String.split "/" (String.trim input)
    in
    case split of
        [ time, unitSymbol ] ->
            let
                seconds : Maybe Float
                seconds =
                    normalizeTime time

                unit : Maybe DistanceUnit
                unit =
                    case unitSymbol of
                        "m" ->
                            Just Meter

                        "km" ->
                            Just Kilometer

                        "yd" ->
                            Just Yard

                        "mi" ->
                            Just Mile

                        _ ->
                            Nothing
            in
            case ( seconds, unit ) of
                ( Just s, Just u ) ->
                    Just { s = s, unit = u }

                _ ->
                    Nothing

        _ ->
            Nothing


{-|

    Parses a pace string and converts it to seconds per meter.

-}
normalizePace : String -> Maybe Pace
normalizePace input =
    let
        pace =
            parsePace input

        convertToSecondsPerMeter : Pace -> Pace
        convertToSecondsPerMeter p =
            { s = p.s / distanceUnitInMeters p.unit
            , unit = Meter
            }
    in
    Maybe.map convertToSecondsPerMeter pace


{-|

    Formats a pace string as a time with the unit symbol

-}
formatPace : Maybe Pace -> String
formatPace pace =
    case pace of
        Just p ->
            formatTime (Just p.s) ++ "/" ++ distanceUnitSymbol p.unit

        Nothing ->
            "(invalid)"
