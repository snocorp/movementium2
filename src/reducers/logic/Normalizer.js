import Qty from 'js-quantities';

function matchToSeconds(match) {
    var h = typeof match[1] === 'undefined' ? 0 : parseInt(match[1],10);
    var m = typeof match[2] === 'undefined' ? 0 : parseInt(match[2],10);
    var s = typeof match[3] === 'undefined' ? 0 : parseInt(match[3],10);

    return ((h * 60) + m) * 60 + s;
}

/**
 * Takes a string an attempts to determine a duration in seconds from it.
 *
 * Time might be written as:
 * * h:mm:ss
 * * m:ss
 * * s
 * * h [hours/hr/h] m [minutes/min/mins/m] s [seconds/sec/s]
 *
 * Unless the last number is qualified, it will be assumed to be seconds, the second last will be minutes, third
 * last will be hours. No bigger units are supported.
 *
 * @param t A string representing a duration
 */
export function normalizeTime(t) {
    if (typeof t === 'undefined') {
        return null;
    }

    t = String(t).trim();

    var colon_re = /(?:(?:(\d+):)?(\d{1,2}):)?(\d{1,2})$/;
    var text_re = /(?:(\d+)\s*(?:hours|hr|hrs|h)\s*)?(?:(\d+)\s*(?:minutes|min|mins|m)\s*)?(?:(\d+)\s*(?:seconds|sec|s))?/;

    var match = t.match(colon_re);
    if (match === null) {
        match = t.match(text_re);
        if (match === null) {
            return null;
        }
    }

    return new Qty(matchToSeconds(match) + ' s');
}

/**
 * Takes a string and attempts to determine a speed in m/s from it.
 *
 * Speed might be written as
 * * # [distance_unit]/[time_unit]
 * * # [distance_unit] per [time_unit]
 *
 * @param v A string representing a speed
 */
export function normalizeSpeed(v) {
    var per_re = /\s*per\s*/;

    v = v.replace(per_re, '/');

    var speed = null;

    try {
        speed = new Qty(v);

        speed = speed.to('m/s');
    } catch (e) {
        return null;
    }

    if (speed) {
      return speed;
    }

    return null;
}

/**
 * Takes a string and attempts to determine a speed in m/s from it.
 *
 * Speed might be written as
 * * # [distance_unit]/[time_unit]
 * * # [distance_unit] per [time_unit]
 *
 * @param v A string representing a speed
 */
export function normalizePace(v) {
    var per_re = /\s*per\s*/;

    v = v.replace(per_re, '/');

    var colon_re = /(?:(?:(\d+):)?(\d{1,2}):)?(\d{1,2})\/([a-z\-]*)/;
    var text_re = /(?:(\d+)\s*(?:hours|hr|hrs|h)\s*)?(?:(\d+)\s*(?:minutes|min|mins|m)\s*)?(?:(\d+)\s*(?:seconds|sec|s))?\/([a-z\-]*)/;

    var match = v.match(colon_re);
    if (match === null) {
        match = v.match(text_re);
    }

    if (match !== null) {
        v = matchToSeconds(match) + ' s/' + match[4];
    } else if (v.match(/\d+\s*\/[a-z\-]*/) === null) {
        //avoid unparseable values
        return null;
    }

    var pace = null;

    try {
        pace = new Qty(v);

        pace = pace.to('s/m');
    } catch (e) {
        return null;
    }

    if (pace) {
      return pace;
    }

    return null;
}

export function normalizeDistance(d) {
    var per_re = /\s*per\s*/;

    d = d.replace(per_re, '/');

    var distance = null;

    try {
        distance = new Qty(d);

        distance = distance.to('m');
    } catch (e) {
        return null;
    }

    if (distance) {
      return distance;
    }

    return null;
}
