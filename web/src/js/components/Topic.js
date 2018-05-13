'use strict';

import React from 'react';

const Topic = ({ topic, addTopic }) => {
  let style = { border: 0, paddingLeft: 2, paddingRight: 2, paddingTop: 1, paddingBottom: 1, margin: 0, backgroundColor: '#b0c4de', color: '#333334' };
  let linkStyle = { cursor: 'pointer' };
  return (
    <div className="list-group-item" style={style}>
      <span className="badge">{topic.count}</span>
      <span style={linkStyle} onClick={() => addTopic(topic)}>{topic.topic}</span>
    </div>
  );
};

export default Topic;

