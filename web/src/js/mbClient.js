'use strict';

import R from 'ramda';
import React from 'react';
import { withRouter, Route  } from 'react-router';
import {  Switch, Link, Match } from 'react-router-dom';
import thunk from 'redux-thunk';
import { render } from 'react-dom';
import { Provider, connect } from 'react-redux';

import createHistory from 'history/createBrowserHistory';
import { ConnectedRouter, routerReducer, routerMiddleware, push } from 'react-router-redux';

import { createStore, combineReducers, applyMiddleware } from 'redux';
import VTopicPane from './containers/VTopicPane';
import VEntryPane from './containers/VEntryPane';
import VPoemThorax from './containers/VPoemThorax';
import VHome from './containers/VHome';
import { mbApp } from './reducers';
import { setEFormat, toggleSidebar, showSidebar, hideSidebar, fetchPageCount, fetchTopics, fetchPoems, fetchEntries, fetchDateEntry, fetchSurroundingDates, changePage } from './actions';
import { sbInit, sbHide, sbShow, sbToggle, setScrollable } from './external/sidebar';
import { entriesId, sidebarId, EFormats } from './config';

const bodyColors = [
  '#8fbc8f', '#66cdaa', '#cd5555', '#220040'
];
const Head = ({ sbOpen, openSidebar, toBlog }) => {
  let mStyles = {
    background: 'center/100% url("/images/gretel.jpg")',
    color: '#cccccc',
    position: 'relative'
  };
  let aStyles = {
    position: 'absolute',
    top: 5,
    right: 5
  };
  let button = sbOpen ? '' : <button style={aStyles} className="btn btn-default btn-md" aria-label="Topics" onClick={openSidebar}><span className="glyphicon glyphicon-flash" aria-hidden="true"></span></button>;
  return (
    <div className="col-md-12 jumbotron" style={mStyles}>
      <h1>Flavigula</h1>
      <p>Here lies Martes Flavigula, eternally beneath the splintered earth.</p>
      <p><Link to="/blog/1">blog</Link> | <Link to="/music">music</Link> | <Link to="/poems">poems</Link></p>
      {button}
    </div>
  );
};
const VHead = connect(
  state => {
    return {
      sbOpen: state.mbApp.sbOpen
    };
  },
  dispatch => {
    return {
      openSidebar: () => {
	sbShow();
	dispatch(showSidebar());
      },
      toBlog: () => {
	push("/blog/1");
	changePage(1);
      }
    };
  }
)(Head);

const BlogThorax = ({ y, m, d }) => {
  return (
    <div className="col-md-12">
      <VEntryPane />
    </div>
  );
};
const VBlogThorax = connect(
  (state, ownProps) => {
    return state;
  },
  dispatch => {
    console.log(`current URL: ${window.location.href}`);
    let pageMatch = R.match(/blog\/(\d+)$/, window.location.href);
    let dateMatch = R.match(/blog\/(\d+)\/(\d+)\/(\d+)$/, window.location.href);
    if(R.isEmpty(pageMatch) && R.isEmpty(dateMatch)) {
      dispatch(push("/blog/1"));
      dispatch(changePage(1));
    } else if(R.isEmpty(pageMatch)) {
      console.log(`changing to date: ${dateMatch[1]}/${dateMatch[2]}/${dateMatch[3]}`);
      dispatch(fetchDateEntry(dateMatch[1], dateMatch[2], dateMatch[3]));
      dispatch(fetchSurroundingDates(new Date(dateMatch[1], dateMatch[2], dateMatch[3]).getTime()));
    } else {
      console.log(`changing to page: ${pageMatch[1]}`);
      dispatch(changePage(pageMatch[1]));
    }
    return {
      dispatch: dispatch
    };
  }
)(BlogThorax);

const Abdomen = () => (
  <div className="col-md-12">
    <hr />
    <p className="well well-sm">
      <span>
        Along with martens, goulish goats and the rippling fen - these writings
        and any accompanying multimedia Copyright
      </span>
      {' '}
      <span className="glyphicon glyphicon-copyright-mark"></span>
      {' '}
      <span>Bob Murry Shelton 2016 - 2018.</span>
    </p>
  </div>
);

class Martenblog extends React.Component {
  componentDidMount() {
    let { dispatch } = this.props;
    document.body.style.background = bodyColors[Math.floor(Math.random() * bodyColors.length)];
    sbInit();
    dispatch(fetchTopics(true));
    dispatch(fetchPoems());
    dispatch(fetchPageCount(1));
    dispatch(fetchEntries());
    setTimeout(() => {
      dispatch(hideSidebar());
      sbHide();
    }, 500);
    setTimeout(() => {
      dispatch(hideSidebar());
      sbHide();
    }, 2000);
    setTimeout(() => {
      if(R.test(/blog\/1$/, window.location.href)) {
	console.log(`we're on the first page - forcing update`);
	this.forceUpdate();
      }
    }, 2000);
  }
  render() {
    let sidebarStyle = { overflow: 'hidden' };
    let sidebarContaitnerStyle = { backgroundColor: 'rgba(192, 192, 192, 0.5)' };
    return(
      <div id="martenblog-layout-container" className="layout-container">
	<div id="martenblog-content" className="layout-content">
	  <div className="container-fluid">
	    <VHead />
	    <Switch>
	      <Route exact path="/" component={VHome} />
	      <Route path="/poems" component={VPoemThorax} />
	      <Route path="/blog" component={VBlogThorax} />
	    </Switch>
	    <Abdomen />
	  </div>
	</div>
	<div id="martenblog-sidebar" className="sidebar sidebar-right sidebar-size-20c" data-position="right" style={sidebarStyle}>
	  <div className="container-fluid" style={sidebarContaitnerStyle}>
	    <VTopicPane />
	  </div>
	</div>
      </div>
    );
  };
}
const VMartenblog = connect(
  (state, ownProps) => {
    return state;
  },
  (dispatch, ownProps) => {
    return {
      dispatch: dispatch
    };
  }
)(Martenblog);

const history = createHistory();
const rMw = routerMiddleware(history);
const store = createStore(combineReducers({mbApp, router: routerReducer}), applyMiddleware(thunk, rMw));

render(
  <Provider store={store}>
    <ConnectedRouter history={history}>
      <VMartenblog />
    </ConnectedRouter>
  </Provider>,
  document.getElementById('martenblog')
);

/*
    <HashRouter>
      <VMartenblog />
    </HashRouter>

*

/*
      <div>
	<p><Link to="/blog">blog</Link> | <Link to="/music">music</Link> | <Link to="/poems">poems</Link></p>
	<Switch>
	  <Route exact path="/" component={VHome} />
	  <Route exact path="/poems" component={VPoemThorax} />
	  <Route exact path="/blog" component={VBlogThorax} />
	</Switch>
      </div>
      <div id="martenblog-layout-container" className="layout-container">
	<div id="martenblog-content" className="layout-content">
	  <div className="container-fluid">
	    <VHead />
	    <p><Link to="/blog">blog</Link> | <Link to="/music">music</Link> | <Link to="/poems">poems</Link></p>
	    <Route path="/poems" component={withRouter(PoemThorax)} />
	    <Route path="/blog" component={withRouter(BlogThorax)} />
	    <Abdomen />
	  </div>
	</div>
	<div id="martenblog-sidebar" className="sidebar sidebar-right sidebar-size-20c" data-position="right" style={sidebarStyle}>
	  <div className="container-fluid" style={sidebarContaitnerStyle}>
	    <VTopicPane />
	  </div>
	</div>
      </div>

*/
