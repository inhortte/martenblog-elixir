'use strict';

import R from 'ramda';
import marked from 'marked';
import React, { Component } from 'react';
import { Route } from 'react-router';
import { Link } from 'react-router-dom';
import { withRouter } from 'react-router-dom';
import VPoem from '../containers/VPoem';

class Poem extends Component {
  render() {
    const titleStyle = {
      fontSize: "2em"
    };
    const poemStyle = {
      fontSize: "1.5em",
      margin: '0 0 0.5em 0',
      padding: '0.5em 1em 0.5em 1em',
      backgroundColor: '#b0c4de',
      'WebkitBorderRadius': 10,
      'MozBorderRadius': 10,
      'borderRadius': 10,
      color: "#5A5C3E"
    };
    // console.log(JSON.stringify(this.props.poem));
    let title = this.props.poem && this.props.poem.title || "Nic";
    let poem = this.props.poem && marked(R.replace(/\n/g, "<br />", this.props.poem.poem)) || "Nic";
    return (
      <div>
	<h2>
	  {title} -
	</h2>
	<hr />
	<div style={poemStyle}>
	  <p dangerouslySetInnerHTML={{ __html: poem }} />
	</div>
      </div>
    );
  }
}

export default Poem;
