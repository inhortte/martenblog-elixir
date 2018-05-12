'use strict';

import R from 'ramda';
import React, { Component } from 'react';
import { Route } from 'react-router';
import { Link } from 'react-router-dom';
import { withRouter } from 'react-router-dom';
import { poemListCompressed } from '../config';

class MusicThorax extends Component {
  render() {
    let musicStyle = {
      fontSize: "1.5em"
    };
    return (
      <div>
	<div className="col-md-3" style={musicStyle}>
	  <h2>Musics -</h2>
	  <hr />
	  <div>
	    This space intentionally left for the <strong>void</strong>.<br /><br />
	    Were you not compressed by the singularity, please visit <a href="https://flavigula.bandcamp.com" target="_blank">the <strong>Flavigula</strong> bandcamp</a> page.
	  </div>
	</div>
      </div>
    );
  }
}

export default MusicThorax;
