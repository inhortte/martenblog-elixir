'use strict';

import R from 'ramda';
import { maxPageNumbersToDisplay, EFormats } from '../config';

const selectPage = (pNum, pages) => {
  return R.map(p => {
    return {
      pNum: p.pNum,
      selected: p.pNum === pNum
    };
  }, pages);2
};

const mkPages = pageCount => {
  return R.map(p => {
    return {
      pNum: p,
      selected: false
    };
  }, R.range(1, pageCount));
};

const filterTopics = (fText, topics) => {
  console.log(`there are ${topics.length} topics`);
  let re = new RegExp(fText.trim(), 'i');
  return (R.trim(fText).length === 0 && topics) || R.filter(t => re.test(t.topic), topics);
};

const addTopic = (topic, _curTopics) => {
  let curTopics = R.clone(_curTopics);
  curTopics[topic.topic] = topic;
  console.log(`curTopics: ${JSON.stringify(curTopics)}`);
  return curTopics;
};
const removeTopic = (topic, _curTopics) => {
  let curTopics = R.clone(_curTopics);
  delete curTopics[topic.topic];
  return curTopics;
};

const toggleExpand = (entryId, expandedEntryIds) => {
  let eeIds = R.clone(expandedEntryIds);
  if(eeIds.includes(entryId)) {
    let idx = R.indexOf(entryId, eeIds);
    return R.remove(idx, 1, eeIds);
  } else {
    eeIds.push(entryId);
    return eeIds;
  }
};

const initialState = {
  eFormat: EFormats.BY_PAGE,
  sbOpen: false,
  pages: mkPages(15),
  entries: [],
  prevDate: null,
  nextDate: null,
  expandedEntryIds: [],
  topics: [],
  filteredTopics: [],
  curTopics: {},
  search: '',

  poems: []
};

export const mbApp = (state = initialState, action) => {
  switch(action.type) {
  case 'SELECT_PAGE':
    console.log(`reducer - select page: ${JSON.stringify(action)}`);
    return Object.assign({}, state, { pages: selectPage(action.pNum, state.pages) });
  case 'SET_PAGES':
    return Object.assign({}, state, { pages: mkPages(action.pageCount) });
  case 'SET_TOPICS':
    return Object.assign({}, state, { topics: action.topics });
  case 'SET_ENTRIES':
    return Object.assign({}, state, { entries: action.entries });
  case 'TOPIC_FILTER_CHANGE':
    return Object.assign({}, state, { filteredTopics: filterTopics(action.fText, state.topics) });
  case 'SEARCH_CHANGE':
    return Object.assign({}, state, { search: action.sText.trim() });
  case 'ADD_TOPIC':
    return Object.assign({}, state, { curTopics: addTopic(action.topic, state.curTopics) });
  case 'REMOVE_TOPIC':
    return Object.assign({}, state, { curTopics: removeTopic(action.topic, state.curTopics) });
  case 'TOGGLE_EXPAND':
    return Object.assign({}, state, { expandedEntryIds: toggleExpand(action.entryId, state.expandedEntryIds) });
  case 'TOGGLE_SIDEBAR':
    return Object.assign({}, state, { sbOpen: !state.sbOpen });
  case 'SHOW_SIDEBAR':
    return Object.assign({}, state, { sbOpen: true });
  case 'HIDE_SIDEBAR':
    return Object.assign({}, state, { sbOpen: false });
  case 'SET_SURROUNDING_DATES':
    return Object.assign({}, state, { prevDate: action.prevDate, nextDate: action.nextDate });
  case 'SET_E_FORMAT':
    return Object.assign({}, state, { eFormat: action.eFormat });
  case 'SET_POEMS':
    return Object.assign({}, state, { poems: action.poems });
  default:
    return state;
  };
};
