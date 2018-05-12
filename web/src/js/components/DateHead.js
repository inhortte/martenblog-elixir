'use strict';

import R from 'ramda';
import React from 'react';
import { Link } from 'react-router-dom';
import { getFormattedDate } from '../utils';
import { dateOpts } from '../config';
import { fetchSurroundingDates } from '../actions';

class DateHead extends React.Component {
  componentDidMount() {
    setTimeout(() => this.props.dispatch(fetchSurroundingDates(this.props.curDate)), 2000);
  }
  render() {
    let { curDate, prevDate, nextDate, changePage, goToDate } = this.props;
    let dateString, prevDateLink, nextDateLink;
    if(curDate) {
      dateString = getFormattedDate(curDate, dateOpts).dateString;
    }
    if(prevDate) {
      let { dateLink, dateString, y, m, d } = getFormattedDate(prevDate, dateOpts);
      prevDateLink = <span><span className="glyphicon glyphicon-chevron-left"></span><Link to={dateLink} onClick={() => goToDate(prevDate, y, m, d)}>{dateString}</Link></span>;
       }
    if(nextDate) {
      let { dateLink, dateString, y, m, d } = getFormattedDate(nextDate, dateOpts);
      nextDateLink = <span><Link to={dateLink} onClick={() => goToDate(nextDate, y, m, d)}>{dateString}</Link><span className="glyphicon glyphicon-chevron-right"></span></span>;
    }
    let communalStyle = {
      backgroundColor: '#b0c4de',
      WebkitBorderRadius: 5,
      MozBorderRadius: 5,
      borderRadius: 5,
      fontSize: 'larger',
      marginBottom: 5
    };
    let stylePrevDate = R.merge({}, { textAlign: 'left' });
    let styleCurDate = R.merge({}, { textAlign: 'center' });
    let styleNextDate = R.merge({}, { textAlign: 'right' });
    return (
      <div>
	<div className="row">
	  <div className="col-md-4 col-md-offset-4" style={styleCurDate}>
	    <Link to={"/blog/1"} onClick={() => changePage(1)}><span className="glyphicon glyphicon-arrow-up"></span></Link>
	  </div>
	</div>
	<div className="row" style={communalStyle}>
	  <div className="col-md-4" style={stylePrevDate}>
	    {prevDate ? prevDateLink : ''}
	  </div>
	  <div className="col-md-4" style={styleCurDate}>
	    {dateString}
	  </div>
	  <div className="col-md-4" style={styleNextDate}>
	    {nextDate ? nextDateLink : ''}
	  </div>
	</div>
      </div>
    );
  }
};

export default DateHead;
