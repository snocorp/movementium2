import {formatSecondsAsHMMSS} from './Formatter';
import {normalizeTime, normalizeSpeed, normalizePace, normalizeDistance} from './Normalizer';

const MODE_VELOCITY = 'velocity', MODE_DISTANCE = 'distance', MODE_TIME = 'time';
const MODE_SPEED = 'speed', MODE_PACE = 'pace';
const UNIT_METER = 'meter', UNIT_KILOMETER = 'kilometer', UNIT_YARD = 'yard', UNIT_MILE = 'mile',
      UNIT_SECOND = 'second', UNIT_HMS = 'hms',
      UNIT_METERSPERSECOND = 'meterspersecond', UNIT_KPH = 'kph', UNIT_MPH = 'mph';

/* Define your initial state here.
 *
 * If you change the type from object to something else, do not forget to update
 * src/container/App.js accordingly.
 */
 const initialUnits = {
     distance_unit: UNIT_KILOMETER,
     time_unit: UNIT_HMS,
     speed_unit: UNIT_KPH,
     pace_unit: UNIT_KILOMETER
};
const initialState = {
    mode: MODE_VELOCITY,
    velocity_mode: MODE_PACE,
    units: {
        distance_unit: UNIT_KILOMETER,
        time_unit: UNIT_HMS,
        speed_unit: UNIT_KPH,
        pace_unit: UNIT_KILOMETER
    },
    time: {
        value: '',
        example: generateExample(MODE_TIME, initialUnits),
        normalized: null
    },
    distance: {
        value: '',
        example: generateExample(MODE_DISTANCE, initialUnits),
        normalized: null
    },
    speed: {
        value: '',
        example: generateExample(MODE_SPEED, initialUnits),
        normalized: null
    },
    pace: {
        value: '',
        example: generateExample(MODE_PACE, initialUnits),
        normalized: null
    }
};

const modes = [MODE_VELOCITY, MODE_DISTANCE, MODE_TIME];
const velocity_modes = ['pace', 'speed'];
const distance_units = ['meter', 'kilometer', 'yard', 'mile'];
const time_units = ['second', 'hms'];
const speed_units = ['meterspersecond', 'kph', 'mph'];

function generateExample(example_mode, {distance_unit, time_unit, speed_unit, pace_unit}) {
    var example = '';
    if (example_mode === MODE_PACE) {
        var postfix = '';
        if (pace_unit === UNIT_METER) {
            postfix = '/m';
        } else if (pace_unit === UNIT_KILOMETER) {
            postfix = '/km';
        } else if (pace_unit === UNIT_YARD) {
            postfix = '/yd';
        } else if (pace_unit === UNIT_MILE) {
            postfix = '/mi';
        }

        if (time_unit === UNIT_HMS) {
            example = '0:05:25'+postfix;
        } else if (time_unit === UNIT_SECOND) {
            example = '625 s'+postfix;
        }
    } else if (example_mode === MODE_SPEED) {
        if (speed_unit === UNIT_METERSPERSECOND) {
            example = '3.3 m/s';
        } else if (speed_unit === UNIT_KPH) {
            example = '12 km/h';
        } else { //UNIT_MPH
            example = '7.5 mi/h';
        }
    } else if (example_mode === MODE_DISTANCE) {
        if (distance_unit === UNIT_METER) {
            example = '100 m';
        } else if (distance_unit === UNIT_KILOMETER) {
            example = '5 km';
        } else if (distance_unit === UNIT_YARD) {
            example = '100 yd';
        } else if (distance_unit === UNIT_MILE) {
            example = '13 mi';
        }
    } else if (example_mode === MODE_TIME) {
        example = '0:05:25';
    }

    return 'e.g. ' + example;
}

function getDistance(distance, units, input = null) {
    if (distance !== null) {
        distance = distance.to(units.distance_unit).toPrec('0.001 '+units.distance_unit);
    }

    return {
        value: input || distance.toString(),
        normalized: distance,
        example: distance === null ? generateExample(MODE_DISTANCE, units) : distance.toString()
    };
}

function getPace(pace, units, input = null) {
    let paceFmt = '';
    if (pace !== null) {
        pace = paceToUnit(pace, units.pace_unit);

        if (units.time_unit === UNIT_HMS) {
            paceFmt = formatSecondsAsHMMSS(pace.scalar) + getPacePostfix(units.pace_unit);
        } else {
            paceFmt = pace.toPrec('0.001 '+pace.units()).toString();
        }
    }

    return {
        value: input || paceFmt,
        normalized: pace,
        example: pace === null ? generateExample(MODE_PACE, units) : paceFmt
    };
}

function getSpeed(speed, units, input = null) {
    let speedFmt = '';
    if (speed !== null) {
        if (units.speed_unit === UNIT_KPH) {
            speedFmt = speed.to('km/h').toPrec('0.001 km/h');
        } else if (units.speed_unit === UNIT_MPH) {
            speedFmt = speed.to('mi/h').toPrec('0.001 mi/h');
        } else if (units.speed_unit === UNIT_METERSPERSECOND) {
            speedFmt = speed.to('m/s').toPrec('0.001 m/s');
        }
    }

    return {
        value: input || speedFmt,
        normalized: speed,
        example: speed === null ? generateExample(MODE_SPEED, units) : speedFmt.toString()
    };
}

function getTime(time, units, input = null) {
    let fmtTime = '';
    if (time !== null) {
        if (units.time_unit === UNIT_HMS) {
            fmtTime = formatSecondsAsHMMSS(time.scalar);
        } else {
            fmtTime = time.toPrec('0.001 s');
        }
    }

    return {
        value: input || fmtTime,
        normalized: time,
        example: time === null ? generateExample(MODE_TIME, units) : fmtTime.toString()
    };
}

function getUpdatedDistance(speed, time, units) {
    let distance = null;
    if (speed !== null && time !== null) {
        distance = time.mul(speed);
    }

    return getDistance(distance, units);
}

function getUpdatedTime(distance, speed, units) {
    let time = null;
    if (speed !== null && distance !== null) {
        time = distance.div(speed);
        console.log(time.toString());
    }

    return getTime(time, units);
}

function getUpdatedVelocity(distance, time, units) {
    let pace = null, speed = null;

    if (distance !== null && time !== null && time.scalar !== 0) {
        pace = time.div(distance);

        speed = distance.div(time);
    }

    return {
        pace: getPace(pace, units),
        speed: getSpeed(speed, units)
    };
}

function paceToUnit(pace, pace_unit) {
    if (pace_unit === UNIT_METER) {
        return pace.to('s/m');
    } else if (pace_unit === UNIT_KILOMETER) {
        return pace.to('s/km');
    } else if (pace_unit === UNIT_YARD) {
        return pace.to('s/yd');
    } else if (pace_unit === UNIT_MILE) {
        return pace.to('s/mi');
    }

    return pace;
}

function getPacePostfix(pace_unit) {
    if (pace_unit === UNIT_METER) {
        return '/m';
    } else if (pace_unit === UNIT_KILOMETER) {
        return '/km';
    } else if (pace_unit === UNIT_YARD) {
        return '/yd';
    } else if (pace_unit === UNIT_MILE) {
        return '/mi';
    }

    return '';
}

module.exports = function(state = initialState, action) {
    /* Keep the reducer clean - do not mutate the original state. */
    let nextState = Object.assign({}, state);

    switch(action.type) {
    case 'SET_DISTANCE_UNIT': {
      // Modify next state depending on the action and return it
      if (distance_units.indexOf(action.unit) > -1) {
          nextState.units.distance_unit = action.unit;
          nextState.distance = getDistance(state.distance.normalized, state.units);
      } else {
          console.warn('Invalid distance unit: ' + action.unit);
      }
      return nextState;
    }
    case 'SET_TIME_UNIT': {
      // Modify next state depending on the action and return it
      if (time_units.indexOf(action.unit) > -1) {
          nextState.units.time_unit = action.unit;
          nextState.time = getTime(state.time.normalized, state.units);
      } else {
          console.warn('Invalid time unit: ' + action.unit);
      }
      return nextState;
    }
    case 'SET_SPEED_UNIT': {
      // Modify next state depending on the action and return it
      if (speed_units.indexOf(action.unit) > -1) {
          nextState.units.speed_unit = action.unit;
          nextState.speed = getSpeed(state.speed.normalized, state.units);
      } else {
          console.warn('Invalid speed unit: ' + action.unit);
      }
      return nextState;
    }
    case 'SET_PACE_UNIT': {
      // Modify next state depending on the action and return it
      if (distance_units.indexOf(action.unit) > -1) {
          nextState.units.pace_unit = action.unit;
          nextState.pace = getPace(state.pace.normalized, state.units);
      } else {
          console.warn('Invalid pace unit: ' + action.unit);
      }
      return nextState;
    }
    case 'SET_MODE': {
      // Modify next state depending on the action and return it
      if (modes.indexOf(action.mode) > -1) {
          nextState.mode = action.mode;
      } else {
          console.warn('Invalid mode: ' + action.mode);
      }
      return nextState;
    }
    case 'SET_VELOCITY_MODE': {
      // Modify next state depending on the action and return it
      if (velocity_modes.indexOf(action.mode) > -1) {
          nextState.velocity_mode = action.mode;
      } else {
          console.warn('Invalid mode: ' + action.mode);
      }
      return nextState;
    }
    case 'SET_TIME': {
        let time = normalizeTime(action.value);
        if (time !== null) console.log(time.toString());

        nextState.time = getTime(time, state.units, action.value);

        if (state.mode === MODE_VELOCITY) {
            let {pace, speed} = getUpdatedVelocity(state.distance.normalized, time, state.units);
            nextState.pace = pace;
            nextState.speed = speed;
        } else if (state.mode === MODE_DISTANCE) {
            nextState.distance = getUpdatedDistance(state.speed.normalized, time, state.units);
        }

        return nextState;
    }
    case 'SET_DISTANCE': {
        let distance = normalizeDistance(action.value);
        if (distance !== null) console.log(distance.toString());

        nextState.distance = getDistance(distance, state.units, action.value);

        if (state.mode === MODE_VELOCITY) {
            let {pace, speed} = getUpdatedVelocity(distance, state.time.normalized, state.units);
            nextState.pace = pace;
            nextState.speed = speed;
        } else if (state.mode === MODE_TIME) {
            nextState.time = getUpdatedTime(distance, state.speed.normalized, state.units);
        }

        return nextState;
    }
    case 'SET_PACE': {
        let pace = normalizePace(action.value);
        if (pace !== null) console.log(pace);

        nextState.pace = getPace(pace, state.units, action.value);
        nextState.speed = getSpeed(pace === null ? null : pace.inverse(), state.units);

        if (state.mode === MODE_TIME) {
            nextState.time = getUpdatedTime(state.distance.normalized, state.speed.normalized, state.units);
        } else if (state.mode === MODE_DISTANCE) {
            nextState.distance = getUpdatedDistance(state.speed.normalized, state.time.normalized, state.units);
        }

        return nextState;
    }
    case 'SET_SPEED': {
        let speed = normalizeSpeed(action.value);
        if (speed !== null) console.log(speed);

        nextState.speed = getSpeed(speed, state.units, action.value);
        nextState.pace = getPace(speed === null ? null : speed.inverse(), state.units);

        if (state.mode === MODE_TIME) {
            nextState.time = getUpdatedTime(state.distance.normalized, state.speed.normalized, state.units);
        } else if (state.mode === MODE_DISTANCE) {
            nextState.distance = getUpdatedDistance(state.speed.normalized, state.time.normalized, state.units);
        }

        return nextState;
    }
    default: {
      /* Return original state if no actions were consumed. */
      return state;
    }
  }
}
