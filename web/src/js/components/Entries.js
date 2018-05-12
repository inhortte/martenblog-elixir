'use strict';

import R from 'ramda';
import React from 'react';
import VEntry from '../containers/VEntry';
import { setSurroundingDates, fetchEntries } from '../actions';

class Entries extends React.Component {
  componentDidMount() {
    let { dispatch, prevDate, nextDate } = this.props;
    if(prevDate || nextDate) {
      setTimeout(() => {
	dispatch(setSurroundingDates({ prevDate: null, nextDate: null }));
	dispatch(fetchEntries());
      }, 2000);
    }
  }
  render() {
    let { entries, expandedEntryIds } = this.props;
    let entryViews = R.map(e => {
      let expanded = expandedEntryIds.includes(e._id);
      return <VEntry key={e._id} entry={e} expanded={expanded} />;
    }, entries);
    let style = { overflow: 'scroll' };
    return (
      <div id="entries">
	{entryViews}
      </div>
    );
  }
};

export default Entries;


