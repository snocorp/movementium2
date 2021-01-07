module Distance exposing (..)

import Html exposing (Html)
import Length exposing (Length)
import Model exposing (..)
import Parser exposing (..)
import Round
import View exposing (inputView, pureMenuItem, unitMenu)


{-|

    Build a menu to allow the user to choose the output unit for the distance.

-}
distanceUnitMenu : Model -> Html Msg
distanceUnitMenu model =
    unitMenu (distanceUnitSymbol model.distanceUnit)
        [ pureMenuItem "m" (model.distanceUnit == Meter) (SetDistanceUnit Meter)
        , pureMenuItem "km" (model.distanceUnit == Kilometer) (SetDistanceUnit Kilometer)
        , pureMenuItem "yd" (model.distanceUnit == Yard) (SetDistanceUnit Yard)
        , pureMenuItem "mi" (model.distanceUnit == Mile) (SetDistanceUnit Mile)
        ]


{-|

    Build a view that displays the distance input.

-}
distanceView : Model -> Html Msg
distanceView model =
    inputView model
        { calcMode = DistanceCalcMode
        , label = "Distance"
        , id = "distance"
        , value = model.distanceInput
        , example = "42.2 km"
        , action = SetDistance
        , dropdownMenu = distanceUnitMenu model
        }


{-|

    Converts a distance unit into its corresponding symbol.

-}
distanceUnitSymbol : DistanceUnit -> String
distanceUnitSymbol unit =
    case unit of
        Meter ->
            "m"

        Kilometer ->
            "km"

        Yard ->
            "yd"

        Mile ->
            "mi"


{-|

    Formats a distance rounded to 2 decimals and includes the unit.
    Displays "(invalid)" if the distance is missing.

-}
formatDistance : Maybe Distance -> String
formatDistance distance =
    case distance of
        Just dist ->
            Round.round 2 dist.value ++ " " ++ distanceUnitSymbol dist.unit

        Nothing ->
            "(invalid)"


{-|

    Parse a distance from string.

-}
parseDistance : String -> Result (List DeadEnd) Distance
parseDistance input =
    let
        -- parser for the value
        value : Parser Float
        value =
            float

        -- parser for the unit
        unit : Parser DistanceUnit
        unit =
            oneOf
                [ Parser.map (\_ -> Meter) (keyword "m")
                , Parser.map (\_ -> Kilometer) (keyword "km")
                , Parser.map (\_ -> Yard) (keyword "yd")
                , Parser.map (\_ -> Mile) (keyword "mi")
                ]

        -- combined parser for the distance
        parser : Parser Distance
        parser =
            succeed Distance
                |= value
                |. spaces
                |= unit
    in
    run parser input


{-|

    Converts a distance into a float value in meters.

-}
distanceToMeters : Distance -> Float
distanceToMeters dist =
    let
        length : Length
        length =
            case dist.unit of
                Meter ->
                    Length.meters dist.value

                Kilometer ->
                    Length.kilometers dist.value

                Yard ->
                    Length.yards dist.value

                Mile ->
                    Length.miles dist.value
    in
    Length.inMeters length


{-|

    Parses a distance string and converts it to meters.

-}
normalizeDistance : String -> Maybe Distance
normalizeDistance input =
    let
        convertToMeters : Distance -> Distance
        convertToMeters dist =
            { value = distanceToMeters dist
            , unit = Meter
            }
    in
    Maybe.map convertToMeters <|
        Result.toMaybe (parseDistance input)


{-|

    Converts a unit of distance to its equivalent in meters.

-}
distanceUnitInMeters : DistanceUnit -> Float
distanceUnitInMeters unit =
    let
        length : Length
        length =
            case unit of
                Meter ->
                    Length.meter

                Kilometer ->
                    Length.kilometer

                Yard ->
                    Length.yard

                Mile ->
                    Length.mile
    in
    Length.inMeters length
