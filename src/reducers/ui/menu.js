/* Define your initial state here.
 *
 * If you change the type from object to something else, do not forget to update
 * src/container/App.js accordingly.
 */
const initialState = {
    open: false,
    mode_open: false,
    unit_open: false
};

module.exports = function(state = initialState, action) {
  /* Keep the reducer clean - do not mutate the original state. */
  let nextState = Object.assign({}, state);

  switch(action.type) {
    case 'SET_MENU': {
      nextState.open = action.open;
      return nextState;
    }
    case 'TOGGLE_MENU': {
      nextState.open = !nextState.open;
      return nextState;
    }
    case 'TOGGLE_MODE_MENU': {
      nextState.mode_open = !nextState.mode_open;
      return nextState;
    }
    case 'TOGGLE_UNIT_MENU': {
      nextState.unit_open = !nextState.unit_open;
      return nextState;
    }
    default: {
      /* Return original state if no actions were consumed. */
      return state;
    }
  }
}
