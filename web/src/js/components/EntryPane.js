'use strict';

import R from 'ramda';
import React from 'react';
import { Route } from 'react-router';
import { Switch } from 'react-router-dom';
import { push } from 'react-router-redux';
import VEntries from '../containers/VEntries';
import VDateEntry from '../containers/VDateEntry';
import VDateHead from '../containers/VDateHead';
import VHeadWithinTheThorax from '../containers/VHeadWithinTheThorax';
import { EFormats } from '../config';
import { fetchEntries, fetchPageCount } from '../actions';

class EntryPane extends React.Component {
  componentDidMount() {
    let { dispatch, currentPage } = this.props;
    /*
      console.log(`EntryPane - fetching entries`);
      dispatch(fetchPageCount(currentPage));
      dispatch(fetchEntries());
      dispatch(push("/blog/1"));
      setTimeout(() => this.forceUpdate(), 1000);
    */
  }
  render() {
    return (
      <div>
	<Switch>
	  <Route exact path="/blog/:page" component={VHeadWithinTheThorax} />
	  <Route path="/blog/:y/:m/:d" component={VDateHead} />
	</Switch>
	<Switch>
	  <Route exact path="/blog/:page" component={VEntries} />
	  <Route path="/blog/:y/:m/:d" component={VDateEntry} />
	</Switch>
      </div>
    );
  }
};

export default EntryPane;
