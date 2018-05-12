import R from 'ramda';
import { connect } from 'react-redux';
import Poem from '../components/Poem';

const mapStateToProps = (state, ownProps) => {
  // console.log(`match.poem: ${JSON.stringify(ownProps)}`);
  let poem = R.find(poem => poem.normalisedTitle === ownProps.match.params.poem, state.mbApp.poems);
  return {
    poem
  };
};

const mapDispatchToProps = dispatch => {
};

const VPoem =
	connect(
	  mapStateToProps
	)(Poem);

export default VPoem;
