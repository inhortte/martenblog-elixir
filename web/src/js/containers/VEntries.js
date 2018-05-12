'use strict';

import { connect } from 'react-redux';
import { removeTopic } from '../actions';
import Entries from '../components/Entries';

const mapStateToProps = state => {
  return {
    entries: state.mbApp.entries,
    expandedEntryIds: state.mbApp.expandedEntryIds,
    prevDate: state.mbApp.prevDate,
    nextDate: state.mbApp.nextDate
  };
};

const mapDispatchToProps = dispatch => {
  return {
    dispatch: dispatch
  };
};

const VEntries = connect(
  mapStateToProps,
  mapDispatchToProps
)(Entries);

export default VEntries;
