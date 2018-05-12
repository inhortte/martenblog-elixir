import R from 'ramda';
import { connect } from 'react-redux';
import EntryPane from '../components/EntryPane';
import { analPageNumbers, currentPage } from '../utils';
import { maxPageNumbersToDisplay } from '../config';
import { changePage } from '../actions';
import { sbToggle } from '../external/sidebar';

const mapStateToProps = (state, ownProps) => {
  let cp = currentPage(state.mbApp.pages);  
  return {
    eFormat: state.mbApp.eFormat,
    currentPage: cp
  };
};

const mapDispatchToProps = dispatch => {
  return {
    dispatch
  };
};

const VEntryPane = connect(
  mapStateToProps
)(EntryPane);

export default VEntryPane;
