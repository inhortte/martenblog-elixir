'use strict';

import { connect } from 'react-redux';
import Topic from '../components/Topic';
import { addTopicThunk } from '../actions';

const mapStateToProps = (state, ownProps) => {
  return {
    topic: ownProps.topic
  };
};

const mapDispatchToProps = dispatch => {
  return {
    addTopic: topic => dispatch(addTopicThunk(topic))
  };
};

const VTopic = connect(
  mapStateToProps,
  mapDispatchToProps
)(Topic);

export default VTopic;
