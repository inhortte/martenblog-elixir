'use strict';

import R from 'ramda';
import { contentServer, entriesPerPage, EFormats } from '../config';
import { currentPage } from '../utils';
import { apolloClient } from '../external/apollo';
import gql from 'graphql-tag';

export const selectPage = pNum => {
  return { type: 'SELECT_PAGE', pNum };
};
export const setPages = pageCount => {
  return { type: 'SET_PAGES', pageCount };
};
export const setTopics = topics => {
  return { type: 'SET_TOPICS', topics };
};
export const setEntries = entries => {
  return { type: 'SET_ENTRIES', entries };
};
export const tfChange = fText => {
  return { type: 'TOPIC_FILTER_CHANGE', fText };
};
export const sChange = sText => {
  return { type: 'SEARCH_CHANGE', sText };
};
export const addTopic = topic => {
  return { type: 'ADD_TOPIC', topic };
};
export const removeTopic = topic => {
  return { type: 'REMOVE_TOPIC', topic };
};
export const toggleExpand = entryId => {
  return { type: 'TOGGLE_EXPAND', entryId };
};
export const toggleSidebar = () => {
  return { type: 'TOGGLE_SIDEBAR' };
};
export const showSidebar = () => {
  return { type: 'SHOW_SIDEBAR' };
};
export const hideSidebar = () => {
  return { type: 'HIDE_SIDEBAR' };
};
export const setSurroundingDates = ([ prevDate, nextDate ]) => {
  return { type: 'SET_SURROUNDING_DATES', prevDate: prevDate, nextDate: nextDate };
};
export const setEFormat = eFormat => {
  return { type: 'SET_E_FORMAT', eFormat };
};

export const setPoems = poems => {
  return { type: 'SET_POEMS', poems };
};

/*
 * THUNKS
 */

export const changePage = (page = 1) => (dispatch, getState) => {
  dispatch(selectPage(page));
  dispatch(setEFormat(EFormats.BY_PAGE));
  dispatch(fetchEntries());
};
export const addTopicThunk = topic => (dispatch, getState) => {
  dispatch(addTopic(topic));
  dispatch(setEFormat(EFormats.BY_PAGE));  
  dispatch(fetchPageCount());
  dispatch(fetchEntries());
};
export const removeTopicThunk = topic => (dispatch, getState) => {
  dispatch(removeTopic(topic));
  dispatch(setEFormat(EFormats.BY_PAGE));  
  dispatch(fetchPageCount());
  dispatch(fetchEntries());
};

export const fetchPageCount = (page = 1) => (dispatch, getState) => {
  let data = {
    topicIds: R.compose(R.map(t => t._id), R.values)(getState().mbApp.curTopics),
    search: getState().mbApp.search
  };
  let query = gql`
query pCount(
  $search: String,
  $topicIds: [Int]
) {
  pCount(
    topicIds: $topicIds,
    search: $search
  )
}`;

  apolloClient.query({ query, variables: data }).then(aqr => {
    let pages = Math.floor(aqr.data.pCount / entriesPerPage) + 2;
    if(aqr.data.pCount % entriesPerPage === 0) {
      pages--;
    }
    dispatch(setPages(pages)); 
    // dispatch(changePage(page));
  }).catch(err => {
    console.log(`apollo error: ${err}`);
    throw err;
  });
};

export const fetchTopics = (init = false) => (dispatch, getState) => {
  let query = gql`
query allTopics {
  allTopics {
    _id,
    topic,
    count
  }
}`;
  apolloClient.query({ query }).then(aqr => {
    // console.log(`apollo data: ${JSON.stringify(aqr.data)}`);
    dispatch(setTopics(R.sort((a, b) => b.count - a.count, aqr.data.allTopics)));
    if(init) {
      dispatch(tfChange(''));
    }
  }).catch(err => {
    console.log(`apollo error: ${err}`);
    throw err;
  });
};

export const fetchPoems = () => (dispatch, getState) => {
  let query = gql`
query allPoems {
  allPoems {
    filename
    title
    fecha
    normalisedTitle
    poem
  }
}`;
  apolloClient.query({ query }).then(aqr => {
    dispatch(setPoems(aqr.data.allPoems));
  }).catch(err => {
    console.log(`fetchPoems err: ${err}`);
    throw err;
  });
};

export const fetchEntries = () => (dispatch, getState) => {
  let page = currentPage(getState().mbApp.pages);
  let data = {
    page: page,
    limit: entriesPerPage,
    topicIds: R.compose(R.map(t => t._id), R.values)(getState().mbApp.curTopics),
    search: getState().mbApp.search
  };

  let query = gql`
query entriesPaged(
  $page: Int,
  $limit: Int,
  $topicIds: [Int],
  $search: String
) {
  entriesPaged(
    page: $page,
    limit: $limit,
    topicIds: $topicIds,
    search: $search
  ) {
    _id,
    createdAt,
    subject,
    entry,
    topics {
      _id,
     topic
    }
  }
}`;

  apolloClient.query({ query, variables: data }).then(aqr => {
    dispatch(setEntries(aqr.data.entriesPaged));
  }).catch(err => {
    console.log(`apollo err: ${err}`);
    throw err;
  });
};

export const fetchDateEntry = (y, m, d) => (dispatch, getState) => {
  let data = { y: parseInt(y), m: parseInt(m), d: parseInt(d) };
  let query = gql`
query entriesByDate(
  $y: Int!,
  $m: Int!,
  $d: Int!
) {
  entriesByDate(
    y: $y,
    m: $m,
    d: $d
  ) {
    _id,
    createdAt,
    subject,
    entry,
    topics {
      _id,
     topic
    }
  }
}`;
  
  apolloClient.query({ query, variables: data }).then(aqr => {
    dispatch(setEntries(aqr.data.entriesByDate));
  }).catch(err => {
    console.log(`apollo err: ${err}`);
    throw err;
  });
};

export const fetchSurroundingDates = timestamp => (dispatch, getState) => {
  let data = { ts: timestamp };
  let query = gql`
query alrededores(
  $ts: Float!
) {
  alrededores(
    timestamp: $ts
  )
}`;

  apolloClient.query({ query, variables: data }).then(aqr => {
    dispatch(setSurroundingDates(aqr.data.alrededores));
  }).catch(err => {
    console.log(`apollo err: ${err}`);
    throw err;
  });
};
