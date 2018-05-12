'use strict';

import { connect } from 'react-redux';
import { removeTopicThunk } from '../actions';
import CurTopics from '../components/CurTopics';

const mapStateToProps = state => {
  return {
    curTopics: state.mbApp.curTopics
  };
};

const mapDispatchToProps = dispatch => {
  return {
    removeTopic: topic => dispatch(removeTopicThunk(topic))
  };
};

const VCurTopics = connect(
  mapStateToProps,
  mapDispatchToProps
)(CurTopics);

export default VCurTopics;
