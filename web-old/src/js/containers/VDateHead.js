import R from 'ramda';
import { connect } from 'react-redux';
import DateHead from '../components/DateHead';
import { changePage, fetchDateEntry, fetchSurroundingDates } from '../actions';
import { push } from 'react-router-redux';

const mapStateToProps = state => {
  return {
    curDate: state.mbApp.entries && state.mbApp.entries[0] && state.mbApp.entries[0].createdAt,
    prevDate: state.mbApp.prevDate,
    nextDate: state.mbApp.nextDate
  };
};

const mapDispatchToProps = dispatch => {
  return {
    dispatch: dispatch,
    goToDate: (date, y, m, d) => {
      dispatch(fetchDateEntry(y, m, d));
      dispatch(fetchSurroundingDates(date));
    },
    changePage: pNum => {
      dispatch(changePage(pNum));
      push("/blog/1");
    }
  };
};

const VDateHead = connect(
  mapStateToProps,
  mapDispatchToProps
)(DateHead);

export default VDateHead;
