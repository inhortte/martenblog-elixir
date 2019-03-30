'use strict';

import R from 'ramda';
import marked from 'marked';
import React from 'react';
import { Link } from 'react-router-dom';
import { dateTimeOpts } from '../config';
import { getFormattedDate } from '../utils';

const Entry = ({ entry, topics, expanded, noContract, addTopic, toggleExpand, goToDate }) => {
  let entryStyle = {
    fontSize: "1.2em",
    margin: '0 0 5px 0',
    paddingTop: 5,
    backgroundColor: '#b0c4de',
    'WebkitBorderRadius': 10,
    'MozBorderRadius': 10,
    'borderRadius': 10
  };
  let subjectStyle = {
    fontSize: 'larger',
    fontWeight: 'bold',
    textAlign: 'left',
    paddingBottom: 5 
  };
  let dateStyle = {
    fontSize: 'smaller',
    fontStyle: 'oblique',
    textAlign: 'right'
  };
  let expandCollapseStyle = {
    textAlign: 'right',
    fontSize: 'smaller',
    fontWeight: 'bold'
  };
  let topicViews = R.compose(R.map(t => {
    return (
      <span key={t._id}>
	<span className="glyphicon glyphicon-grain"></span>
	{' '}
	<a href="#" onClick={() => addTopic(t)}>{t.topic}</a>
	{' '}
      </span>
    );
  }))(topics);
  let entryHtml = {
    __html: expanded ? marked(entry.entry) : `${entry.entry.slice(0, 200)}...`
  };
  let { dateLink, dateString, y, m, d } = getFormattedDate(entry.createdAt, dateTimeOpts);
  let expandContract = noContract ? '' : (
    <div style={expandCollapseStyle}>
      <a href="#" onClick={e => { e.preventDefault(); toggleExpand(entry._id);}}>
	{expanded ? 'contract' : 'expand'}
      </a>
    </div>
  );
  return (
    <div className="col-md-8 col-md-push-2 entry" style={entryStyle}>
      <div className="row">
	<div className="col-md-12" style={subjectStyle}>
	  <Link to={dateLink} onClick={() => goToDate(y, m, d)}>{entry.subject}</Link>
	</div>
      </div>
      <div className="row">
	<div className="col-md-8">
	  Topics: {topicViews}
	</div>
	<div className="col-md-4">
	  <div style={dateStyle}>{dateString}</div>
	  {expandContract}
	</div>
      </div>
      <hr />
      <div className="row">
	<div className="col-md-12" dangerouslySetInnerHTML={entryHtml} />
      </div>
    </div>
  );
};

export default Entry;

