import R from 'ramda';
import { connect } from 'react-redux';
import TopicPane from '../components/TopicPane';
import { hideSidebar, toggleSidebar, tfChange, sChange, fetchPageCount, fetchEntries } from '../actions';
import { sbHide, sbToggle } from '../external/sidebar';

const mapStateToProps = state => {
  return {
    sbOpen: state.mbApp.sbOpen,
    filteredTopics: state.mbApp.filteredTopics || [],
    curTopics: state.mbApp.curTopics || []
  };
};

const mapDispatchToProps = dispatch => {
  return {
    searchChange: e => dispatch(sChange(e.target.value)),
    searchSubmit: e => {
      if(e && e.key === 'Enter') {
	dispatch(fetchPageCount());
	dispatch(fetchEntries());
      }
    },
    topicFilterChange: e => dispatch(tfChange(e.target.value)),
    closeSidebar: () => {
      sbHide();
      dispatch(hideSidebar());
    }
  };
};

const VTopicPane = connect(
  mapStateToProps,
  mapDispatchToProps
)(TopicPane);

export default VTopicPane;
