import R from 'ramda';
import { withRouter } from 'react-router';
import { connect } from 'react-redux';
import Home from '../components/Home';

const mapStateToProps = (state, ownProps) => {
  return state;
};

const mapDispatchToProps = dispatch => {
};

const VHome =
	connect(
	  mapStateToProps
	)(Home);

export default VHome;
