'use strict';

import R from 'ramda';
import React from 'react';
import { Link } from 'react-router-dom';
import { fetchPageCount } from '../actions';

class HeadWithinTheThorax extends React.Component {
  componentWillReceiveProps() {
    // console.log(`head within the thorax - component will receive props`);
  }
  componentDidMount() {
    let { dispatch, currentPage } = this.props;
  }
  render() {
    const { pages, currentPage, hasPrevPageLink, hasNextPageLink, changePage } = this.props;
    let prevPageThurk = hasPrevPageLink ?
	<li><Link to={`/blog/${currentPage - 1}`} aria-label="Previous" onClick={() => changePage(currentPage - 1)}><span aria-hidden="true">&laquo;</span></Link></li> :
	'';
    let pageThurks = R.map(p => {
      let liClass = p.selected ? 'active' : '';
      return <li className={liClass} key={p.pNum}><Link to={`/blog/${p.pNum}`} onClick={() => changePage(p.pNum)}>{p.pNum}</Link></li>;
    }, pages);
    let nextPageThurk = hasNextPageLink ?
	<li><Link to={`/blog/${currentPage + 1}`} aria-label="Next"><span aria-hidden="true" onClick={() => changePage(currentPage + 1)}>&raquo;</span></Link></li> :
	'';
    return (
      <div className="col-md-12">
	<div className="col-md-10">
	  <nav>
	    <ul className="pagination">
	      {prevPageThurk}
	      {pageThurks}
	      {nextPageThurk}
	    </ul>
	  </nav>
	</div>
      </div>
    );
  }
};

export default HeadWithinTheThorax;

