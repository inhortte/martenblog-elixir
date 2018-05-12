'use strict';

import R from 'ramda';
import React from 'react';
import VEntry from '../containers/VEntry';
import { fetchDateEntry } from '../actions';

class DateEntry extends React.Component {
  render() {
    let { entries } = this.props;
    let entryViews = R.map(e => {
      return <VEntry key={e._id} entry={e} expanded={true} noContract={true} />;
    }, entries);
    return (
      <div id="entries">
	{entryViews}
      </div>
    );
  }
}

export default DateEntry;


