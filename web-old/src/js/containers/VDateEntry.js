'use strict';

import { connect } from 'react-redux';
import { removeTopic } from '../actions';
import DateEntry from '../components/DateEntry';

const mapStateToProps = (state, ownProps) => {
  return {
    entries: state.mbApp.entries
  };
};

const mapDispatchToProps = dispatch => {
  return {
    dispatch: dispatch
  };
};

const VDateEntry = connect(
  mapStateToProps,
  mapDispatchToProps
)(DateEntry);

export default VDateEntry;
