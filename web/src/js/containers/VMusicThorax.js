import R from 'ramda';
import { withRouter } from 'react-router';
import { connect } from 'react-redux';
import MusicThorax from '../components/MusicThorax';

const mapStateToProps = (state, ownProps) => {
  return {
    state
  };
};

const mapDispatchToProps = dispatch => {
};

const VMusicThorax =
	connect(
	  mapStateToProps
	)(MusicThorax);

export default VMusicThorax;
