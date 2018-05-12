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
      color: "#ddbbcc"
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
