'use strict';

import React from 'react';
import Paper from 'material-ui/Paper';
import TextField from 'material-ui/TextField';

require('styles//UnitDisplay.scss');

class UnitDisplayComponent extends React.Component {
  render() {
    return (
      <div className="unitdisplay-component">
        <Paper style={{maxWidth: '400px', margin: '10px auto', padding: '20px'}}>
            <TextField
                value={this.props.value}
                hintText={this.props.type}
                onChange={this.props.onChange}
                disabled={!this.props.isInput} />
            <p>{this.props.example}</p>
        </Paper>
      </div>
    );
  }
}

UnitDisplayComponent.displayName = 'UnitDisplayComponent';

// Uncomment properties you need
UnitDisplayComponent.propTypes = {
    type: React.PropTypes.string.isRequired,
    example: React.PropTypes.string.isRequired,
    onChange: React.PropTypes.func,
    isInput: React.PropTypes.bool
};
// UnitDisplayComponent.defaultProps = {};

export default UnitDisplayComponent;
