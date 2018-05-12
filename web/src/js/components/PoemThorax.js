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
    let titleLinks = R.addIndex(R.map)((poem, idx) => {
      return (
	<div key={idx}>
	  <Link to={`/poems/${poem.normalisedTitle}`}>{poem.title}</Link>
	</div>
      );
    }, this.props.poems);
    let poemLinksStyle = {
      fontSize: "1.5em"
    };
    if(poemListCompressed) {
      poemLinksStyle = R.merge(poemLinksStyle, {
	overflow: 'auto',
	height: "5em"
      });
    }
    return (
      <div>
	<div className="col-md-3">
	  <h2>Poems -</h2>
	  <hr />
	  <div style={poemLinksStyle}>
	    {titleLinks}
	  </div>
	</div>
	<div className="col-md-6 push-md-3">
	  <Route path="/poems/:poem" component={VPoem} />
	</div>
      </div>
    );
  }
}

export default PoemThorax;
