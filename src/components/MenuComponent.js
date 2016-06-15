'use strict';

import React from 'react';
import Divider from 'material-ui/Divider';
import {List, ListItem, MakeSelectable} from 'material-ui/List';
import Subheader from 'material-ui/Subheader';
import KeyboardArrowDown from 'material-ui/svg-icons/hardware/keyboard-arrow-down';
import KeyboardArrowUp from 'material-ui/svg-icons/hardware/keyboard-arrow-up';

require('styles/Menu.scss');

let SelectableList = MakeSelectable(List);

class MenuComponent extends React.Component {
    handleModeChange = (event, index) => {
        const { store } = this.context;
        store.dispatch({type: 'SET_MODE', mode: index});
    };

    handleVelocityModeChange = (event, index) => {
        const { store } = this.context;
        store.dispatch({type: 'SET_VELOCITY_MODE', mode: index});
    };

    handleDistanceUnitChange = (event, index) => {
        const { store } = this.context;
        store.dispatch({type: 'SET_DISTANCE_UNIT', unit: index});
    };

    handleTimeUnitChange = (event, index) => {
        const { store } = this.context;
        store.dispatch({type: 'SET_TIME_UNIT', unit: index});
    };

    handlePaceUnitChange = (event, index) => {
        const { store } = this.context;
        store.dispatch({type: 'SET_PACE_UNIT', unit: index});
    };

    handleSpeedUnitChange = (event, index) => {
        const { store } = this.context;
        store.dispatch({type: 'SET_SPEED_UNIT', unit: index});
    };

    handleModeClick = () => {
        const { store } = this.context;
        store.dispatch({type: 'TOGGLE_MODE_MENU'});
    };

    handleUnitsClick = () => {
        const { store } = this.context;
        store.dispatch({type: 'TOGGLE_UNIT_MENU'});
    };

    render() {
        const { store } = this.context;
        return (
            <div>
                <List style={{paddingBottom:0}}>
                    <ListItem
                        primaryText="Mode"
                        rightIcon={
                            store.getState().menu.mode_open?<KeyboardArrowUp />:<KeyboardArrowDown />
                        }
                        onTouchTap={this.handleModeClick}
                        />
                </List>
                <div style={{display: (store.getState().menu.mode_open?'block':'none')}}>
                    <SelectableList
                        style={{paddingTop:0}}
                        value={store.getState().app.mode}
                        onChange={this.handleModeChange}>
                        <ListItem value={'velocity'} primaryText="Velocity" />
                        <ListItem value={'distance'} primaryText="Distance" />
                        <ListItem value={'time'} primaryText="Time" />
                    </SelectableList>
                    <Divider />
                    <SelectableList
                        value={store.getState().app.velocity_mode}
                        onChange={this.handleVelocityModeChange}>
                        <Subheader>Velocity Mode</Subheader>
                        <ListItem value={'pace'} primaryText="Pace" />
                        <ListItem value={'speed'} primaryText="Speed" />
                    </SelectableList>
                </div>
                <List style={{paddingBottom:0}}>
                    <ListItem
                        primaryText="Units"
                        rightIcon={
                            store.getState().menu.unit_open?<KeyboardArrowUp />:<KeyboardArrowDown />
                        }
                        onTouchTap={this.handleUnitsClick}
                        />
                </List>
                <div style={{display: (store.getState().menu.unit_open?'block':'none')}}>
                    <SelectableList
                        style={{paddingTop:0}}
                        value={store.getState().app.units.distance_unit}
                        onChange={this.handleDistanceUnitChange}>
                        <Subheader>Distance</Subheader>
                        <ListItem value={'meter'} primaryText="m" />
                        <ListItem value={'kilometer'} primaryText="km" />
                        <ListItem value={'yard'} primaryText="yd" />
                        <ListItem value={'mile'} primaryText="mi" />
                    </SelectableList>
                    <SelectableList
                        value={store.getState().app.units.time_unit}
                        onChange={this.handleTimeUnitChange}>
                        <Subheader>Time</Subheader>
                        <ListItem value={'second'} primaryText="s" />
                        <ListItem value={'hms'} primaryText="h:mm:ss" />
                    </SelectableList>
                    <SelectableList
                        value={store.getState().app.units.speed_unit}
                        onChange={this.handleSpeedUnitChange}>
                        <Subheader>Speed</Subheader>
                        <ListItem value={'meterspersecond'} primaryText="m/s" />
                        <ListItem value={'kph'} primaryText="km/h" />
                        <ListItem value={'mph'} primaryText="mi/h" />
                    </SelectableList>
                    <SelectableList
                        value={store.getState().app.units.pace_unit}
                        onChange={this.handlePaceUnitChange}>
                        <Subheader>Pace</Subheader>
                        <ListItem value={'meter'} primaryText="time/m" />
                        <ListItem value={'kilometer'} primaryText="time/km" />
                        <ListItem value={'yard'} primaryText="time/yd" />
                        <ListItem value={'mile'} primaryText="time/mi" />
                    </SelectableList>
                </div>
            </div>
        );
    }
}

MenuComponent.displayName = 'Menu';

// Uncomment properties you need
// MenuComponent.propTypes = {};
// MenuComponent.defaultProps = {};

MenuComponent.contextTypes = {
    store: React.PropTypes.object
}

export default MenuComponent;
