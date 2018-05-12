'use strict';

import React from 'react';
import R from 'ramda';
import VTopic from '../containers/VTopic';
import VCurTopics from '../containers/VCurTopics';

const searchPlaceholders = [
  'Kill Christian', 'Shave your goat', 'The bog encroaches', 'Mrdat', 'Dissolving Petuitary',
  'I snorted your dung', 'Stapleguns aloft', 'Excoriate the woman'
];

const TopicPane = ({ sbOpen, filteredTopics, curTopics, searchChange, searchSubmit, topicFilterChange, closeSidebar }) => {
  let style = { position: 'relative', opacity: 1.0, zIndex: 9999 };
  let aStyles = { position: 'absolute', top: 5, right: 5 };
  let h3Style = { color: '#ccccdd' };
  let fTopicsViewDivStyle = { marginTop: 5 };
  let fTopicsView = R.map(t => <VTopic topic={t} key={t.topic} />, filteredTopics);
  console.log(`sbOpen: ${sbOpen}`);
  let button = sbOpen ? <button style={aStyles} className="btn btn-default btn-md" aria-label="Topics" onClick={closeSidebar}><span className="glyphicon glyphicon-flash" aria-hidden="true"></span></button> : '';
  return (
    <div style={style}>
      {button}
      <div className="sidebar-brand sidebar-brand-bg sidebar-p-x form-group">
	<h3>Search</h3>
	<input className="form-control" type="text" placeholder={searchPlaceholders[Math.floor(Math.random() * searchPlaceholders.length)]} onChange={searchChange} onKeyPress={searchSubmit} />
      </div>
      <div className="sidebar-brand sidebar-brand-bg sidebar-p-x form-group">
	<h3>Topics</h3>
	<VCurTopics />
	<input className="form-control" type="text" placeholder={searchPlaceholders[Math.floor(Math.random() * searchPlaceholders.length)]} onChange={topicFilterChange} />
	<div className="list-group" style={fTopicsViewDivStyle}>
	  {fTopicsView}
	</div>
      </div>
    </div>
  );
};

export default TopicPane;
