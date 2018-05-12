'use strict';

import R from 'ramda';
import { connect } from 'react-redux';
import Entry from '../components/Entry';
import { addTopicThunk, toggleExpand, fetchDateEntry, setEFormat } from '../actions';
import { EFormats } from '../config';

const mapStateToProps = (state, ownProps) => {
  return {
    entry: ownProps.entry,
    topics: ownProps.entry.topics,
    expanded: ownProps.expanded,
    noContract: ownProps.noContract 
  };
};

const mapDispatchToProps = dispatch => {
  return {
    addTopic: topic => dispatch(addTopicThunk(topic)),
    toggleExpand: entryId => dispatch(toggleExpand(entryId)),
    goToDate: (y, m, d) => {
      dispatch(setEFormat(EFormats.BY_DATE));
      dispatch(fetchDateEntry(y, m, d));
    }
  };
};

const VEntry = connect(
  mapStateToProps,
  mapDispatchToProps
)(Entry);

export default VEntry;
