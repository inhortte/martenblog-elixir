'use strict';

import R from 'ramda';
import React, { Component } from 'react';
import { withRouter } from 'react-router-dom';
import { push } from 'react-router-redux';

class Home extends Component {
  render() {
    this.props.dispatch(push("/blog/1"));
    return (
      <div>
	DEATH!
      </div>
    );
  }
}

export default Home;
