import R from 'ramda';
import { withRouter } from 'react-router';
import { connect } from 'react-redux';
import PoemThorax from '../components/PoemThorax';

const mapStateToProps = (state, ownProps) => {
  return {
    poems: state.mbApp.poems
  };
};

const mapDispatchToProps = dispatch => {
};

const VPoemThorax =
	connect(
	  mapStateToProps
	)(PoemThorax);

export default VPoemThorax;
