'use strict';

import React from 'react';

const Topic = ({ topic, addTopic }) => {
  let style = { border: 0, paddingLeft: 2, paddingRight: 2, paddingTop: 1, paddingBottom: 1, margin: 0, backgroundColor: '#b0c4de', color: '#333334' };
  return (
    <div className="list-group-item" style={style}>
      <span className="badge">{topic.count}</span>
      <a href="#" onClick={() => addTopic(topic)}>{topic.topic}</a>
    </div>
  );
};

export default Topic;

