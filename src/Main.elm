module Main exposing (main)

import Browser
import Distance exposing (distanceUnitInMeters, distanceView, formatDistance, normalizeDistance)
import Html exposing (Html, div, header)
import Model exposing (..)
import Round
import Time exposing (formatTime, normalizeTime, timeView)
import Velocity exposing (formatPace, formatVelocity, normalizePace, normalizeVelocity, paceView, velocityFromMetersPerSecondToUnit, velocityView)
import View exposing (calcModePickerView, pureFormStacked, pureGrid)



-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }


{-|

    A record to store the current state of the parsed and normalized values from the form.

-}
type alias TimeDistanceVelocity =
    { time : Float
    , distance : Float
    , velocity : Float
    }


{-|

    Initialize the model.

-}
init : Model
init =
    { calcMode = DistanceCalcMode
    , distanceInput = "0"
    , distanceUnit = Kilometer
    , velocityInput = "0"
    , velocityUnit = KilometersPerHour
    , paceInput = "0"
    , paceUnit = Kilometer
    , timeInput = "0"
    }


{-|

    Calculates the time, distance, and velocity by parsing and normalizing the given inputs.
    If any value is invalid or cannot be parsed, 0.0 will be used.

    calcTDV "1:00:00" "1 km" "1 km/h" == { time=3600.0, distance=1000, velocity=0.27778 }

-}
calcTDV : String -> String -> String -> TimeDistanceVelocity
calcTDV time distance velocity =
    let
        d =
            Maybe.withDefault 0.0 <|
                Maybe.map .value (normalizeDistance distance)

        t =
            Maybe.withDefault 0.0 <|
                normalizeTime time

        v =
            Maybe.withDefault 0.0 <|
                Maybe.map .value (normalizeVelocity velocity)
    in
    { time = t
    , distance = d
    , velocity = v
    }


{-|

    Update the input values on the model based on the calculation mode. The
    calculation mode determines the variable value and the other two are
    considered to be static inputs. Pace and velocity are both updated with
    VelocityCalcMode enabled.

-}
updateInputs : Model -> Model
updateInputs model =
    let
        tdv : TimeDistanceVelocity
        tdv =
            calcTDV model.timeInput model.distanceInput model.velocityInput

        distanceInput : String
        distanceInput =
            case model.calcMode of
                DistanceCalcMode ->
                    -- format the distance in the user's chosen unit
                    formatDistance
                        (Just
                            { value = tdv.time * tdv.velocity / distanceUnitInMeters model.distanceUnit
                            , unit = model.distanceUnit
                            }
                        )

                _ ->
                    model.distanceInput

        timeInput : String
        timeInput =
            case model.calcMode of
                TimeCalcMode ->
                    formatTime (Just (tdv.distance / tdv.velocity))

                _ ->
                    model.timeInput

        velocityInput : String
        velocityInput =
            case model.calcMode of
                VelocityCalcMode ->
                    -- if time is zero then velocity is not defined
                    if tdv.time == 0.0 then
                        ""

                    else
                        -- format the velocity in the user's chosen format
                        formatVelocity
                            (Just
                                { value = velocityFromMetersPerSecondToUnit (tdv.distance / tdv.time) model.velocityUnit
                                , unit = model.velocityUnit
                                }
                            )

                _ ->
                    model.velocityInput

        paceInput : String
        paceInput =
            case model.calcMode of
                VelocityCalcMode ->
                    -- if distance is zero then pace is not defined
                    if tdv.distance == 0.0 then
                        ""

                    else
                        -- format the pace using the user's chosen unit
                        formatPace
                            (Just
                                { s = distanceUnitInMeters model.paceUnit * tdv.time / tdv.distance
                                , unit = model.paceUnit
                                }
                            )

                _ ->
                    model.paceInput
    in
    { model
        | distanceInput = distanceInput
        , timeInput = timeInput
        , velocityInput = velocityInput
        , paceInput = paceInput
    }


{-|

    Update the model based on the given action.

-}
update : Msg -> Model -> Model
update msg model =
    case msg of
        -- set the calculation mode
        SetMode calcMode ->
            { model | calcMode = calcMode }

        -- set the distance unit for output
        SetDistanceUnit unit ->
            updateInputs { model | distanceUnit = unit }

        -- set the velocity unit for output
        SetVelocityUnit unit ->
            updateInputs { model | velocityUnit = unit }

        -- set the pace unit for output
        SetPaceUnit unit ->
            updateInputs { model | paceUnit = unit }

        -- set the distance
        SetDistance newValue ->
            updateInputs { model | distanceInput = newValue }

        -- set the time
        SetTime newValue ->
            updateInputs { model | timeInput = newValue }

        -- set the velocity
        SetVelocity newValue ->
            let
                velocity : Maybe Velocity
                velocity =
                    normalizeVelocity newValue

                -- update the pace input if we are setting the velocity
                paceInput : String
                paceInput =
                    case velocity of
                        Just v ->
                            -- if the velocity is zero, then the pace is not defined
                            if v.value == 0 then
                                ""

                            else
                                -- format the pace in the user's chosen unit
                                formatPace
                                    (Just
                                        { s = distanceUnitInMeters model.paceUnit / v.value
                                        , unit = model.paceUnit
                                        }
                                    )

                        Nothing ->
                            ""
            in
            updateInputs { model | velocityInput = newValue, paceInput = paceInput }

        -- set the pace
        SetPace newValue ->
            let
                pace : Maybe Pace
                pace =
                    normalizePace newValue

                -- update the velocity input if we are setting the pace
                velocityInput : String
                velocityInput =
                    case pace of
                        Just p ->
                            -- if the pace is zero then the velocity is not defined
                            if p.s == 0 then
                                ""

                            else
                                -- format the velocity in the user's chosen unit
                                formatVelocity
                                    (Just
                                        { value = velocityFromMetersPerSecondToUnit (1 / p.s) model.velocityUnit
                                        , unit = model.velocityUnit
                                        }
                                    )

                        Nothing ->
                            ""
            in
            updateInputs { model | paceInput = newValue, velocityInput = velocityInput }


{-|

    Construct the view

-}
view : Model -> Html Msg
view model =
    div []
        [ header [] [ calcModePickerView model ]
        , pureFormStacked
            [ pureGrid
                [ distanceView model
                , timeView model
                , velocityView model
                , paceView model
                ]
            ]
        ]
