module Model exposing (..)

import Html exposing (Html)


{-|

    A record to help construct an input section on the interface.

-}
type alias InputRecord =
    { calcMode : CalcMode
    , label : String
    , id : String
    , value : String
    , example : String
    , action : String -> Msg
    , dropdownMenu : Html Msg
    }


{-|

    The calculation mode determines which variable is considered to be the output of the formula.

-}
type CalcMode
    = DistanceCalcMode
    | VelocityCalcMode
    | TimeCalcMode


{-|

    A set of supported distance units. If any are added, the interface and parser will also need to be updated.

-}
type DistanceUnit
    = Meter
    | Kilometer
    | Yard
    | Mile


{-|

    A distance record including the unit.

-}
type alias Distance =
    { value : Float
    , unit : DistanceUnit
    }


{-|

    A set of supported velocity units. If any are added, the interface and parser will also need to be updated.

-}
type VelocityUnit
    = MetersPerSecond
    | KilometersPerHour
    | MilesPerHour


{-|

    A velocity record including the unit.

-}
type alias Velocity =
    { value : Float
    , unit : VelocityUnit
    }


{-|

    A pace record including the distance unit. The value is always in seconds.

-}
type alias Pace =
    { s : Float
    , unit : DistanceUnit
    }


{-|

    The main model for the application.

-}
type alias Model =
    { calcMode : CalcMode
    , distanceInput : String
    , distanceUnit : DistanceUnit
    , velocityInput : String
    , velocityUnit : VelocityUnit
    , paceInput : String
    , paceUnit : DistanceUnit
    , timeInput : String
    }


{-|

    The update actions for the application.

-}
type Msg
    = SetMode CalcMode
    | SetDistance String
    | SetDistanceUnit DistanceUnit
    | SetTime String
    | SetVelocity String
    | SetVelocityUnit VelocityUnit
    | SetPace String
    | SetPaceUnit DistanceUnit
