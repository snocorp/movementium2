require('normalize.css/normalize.css');
require('styles/App.css');

import AppBar from 'material-ui/AppBar';
import Drawer from 'material-ui/Drawer';
import Menu from './MenuComponent';
import UnitDisplay from './UnitDisplayComponent';

import React from 'react';

class AppComponent extends React.Component {
    constructor() {
        super();
    }

    render() {
        const { store } = this.context;
        const mode = store.getState().app.mode;
        const velocity_mode = store.getState().app.velocity_mode;
        return (
            <div className='index'>
                <AppBar
                    title='Movementium'
                    iconClassNameRight='muidocs-icon-navigation-expand-more'
                    onLeftIconButtonTouchTap={this.handleMenuTouchTap}
                />
                <Drawer
                    docked={false}
                    open={store.getState().menu.open}
                    onRequestChange={this.handleRequestMenuChange}>
                    <Menu />
                </Drawer>
                <UnitDisplay
                    value={store.getState().app.time.value}
                    type="time"
                    example={store.getState().app.time.example}
                    isInput={mode !== 'time'}
                    onChange={this.handleTimeChange}
                    />
                <UnitDisplay
                    value={store.getState().app.distance.value}
                    type="distance"
                    example={store.getState().app.distance.example}
                    isInput={mode !== 'distance'}
                    onChange={this.handleDistanceChange}
                    />
                <UnitDisplay
                    value={store.getState().app.pace.value}
                    type="pace"
                    example={store.getState().app.pace.example}
                    isInput={mode !== 'velocity' && velocity_mode==='pace'}
                    onChange={this.handlePaceChange}
                    />
                <UnitDisplay
                    value={store.getState().app.speed.value}
                    type="speed"
                    example={store.getState().app.speed.example}
                    isInput={mode !== 'velocity' && velocity_mode==='speed'}
                    onChange={this.handleSpeedChange}
                    />
            </div>
        );
    }

    handleTimeChange = (event) => {
        const { store } = this.context;
        store.dispatch({type: 'SET_TIME', value: event.target.value})
    }

    handleDistanceChange = (event) => {
        const { store } = this.context;
        store.dispatch({type: 'SET_DISTANCE', value: event.target.value})
    }

    handlePaceChange = (event) => {
        const { store } = this.context;
        store.dispatch({type: 'SET_PACE', value: event.target.value})
    }

    handleSpeedChange = (event) => {
        const { store } = this.context;
        store.dispatch({type: 'SET_SPEED', value: event.target.value})
    }

    handleMenuTouchTap = () => {
        console.log('handleMenuTouchTap');
        const { store } = this.context;
        store.dispatch({type: 'TOGGLE_MENU'})
    }

    handleRequestMenuChange = (open) => {
        console.log('handleRequestMenuChange');
        const { store } = this.context;
        store.dispatch({type: 'SET_MENU', open: open})
    }
}

AppComponent.defaultProps = {
};

AppComponent.contextTypes = {
    store: React.PropTypes.object
}

export default AppComponent;
