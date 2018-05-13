'use strict';

import R from 'ramda';
import React, { Component } from 'react';
import { Route } from 'react-router';
import { Link } from 'react-router-dom';
import { withRouter } from 'react-router-dom';
import VPoem from '../containers/VPoem';
import { poemListCompressed } from '../config';

class PoemThorax extends Component {
  render() {
    let poemTitlesStyle = {
      fontSize: "1.5em",
      margin: '0 0 0.5em 0',
      padding: '0.5em 1em 0.5em 1em',
      backgroundColor: '#b0c4de',
      'WebkitBorderRadius': 10,
      'MozBorderRadius': 10,
      'borderRadius': 10
    };
    let titleLinks = R.addIndex(R.map)((poem, idx) => {
      return (
	<div key={idx}>
	  <Link to={`/poems/${poem.normalisedTitle}`}>{poem.title}</Link>
	</div>
      );
    }, this.props.poems);
    if(poemListCompressed) {
      poemTitlesStyle = R.merge(poemTitlesStyle, {
	overflow: 'auto',
	height: "5em"
      });
    }
    return (
      <div>
	<div className="col-md-2">
	  <h2>Poems -</h2>
	  <hr />
	  <div style={poemTitlesStyle}>
	    {titleLinks}
	  </div>
	</div>
	<div className="col-md-4">
	  <Route path="/poems/:poem" component={VPoem} />
	</div>
      </div>
    );
  }
}

export default PoemThorax;
