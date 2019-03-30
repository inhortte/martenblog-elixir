import R from 'ramda';
import { connect } from 'react-redux';
import HeadWithinTheThorax from '../components/HeadWithinTheThorax';
import { analPageNumbers, currentPage } from '../utils';
import { maxPageNumbersToDisplay } from '../config';
import { changePage } from '../actions';
import { sbToggle } from '../external/sidebar';

const mapStateToProps = (state, ownProps) => {
  let pages = analPageNumbers(state.mbApp.pages);
  let cp = currentPage(state.mbApp.pages);
  return {
    pages: pages,
    currentPage: parseInt(cp),
    hasPrevPageLink: cp > 1,
    hasNextPageLink: cp < state.mbApp.pages.length
  };
};

const mapDispatchToProps = dispatch => {
  return {
    dispatch,
    changePage: pNum => dispatch(changePage(pNum))
  };
};

const VHeadWithinTheThorax = connect(
  mapStateToProps,
  mapDispatchToProps
)(HeadWithinTheThorax);

export default VHeadWithinTheThorax;
