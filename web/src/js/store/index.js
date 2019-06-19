'use strict';

import Vue from 'vue';
import Vuex from 'vuex';
import { mapGetters } from 'vuex';
import R from 'ramda';
import { server } from '../config';

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    poems: [],
    currentPoem: {},
    entries: [],
    expanded: {},
    trigger: 0
  },
  getters: {
    poems: state => {
      return state.poems;
    },
    entries: state => {
      return state.entries;
    },
    isEntryExpanded: state => id => {
      return !!state.expanded[id];
    }
  },
  mutations: {
    setPoems: (state, poems) => {
      state.poems = poems;
    },
    setEntries: (state, entries) => {
      state.entries = entries;
    },
    toggleExpand: (state, id) => {
      let expanded = Object.assign({}, state.expanded);
      Vue.set(state.expanded, id, !expanded[id]);
    }
  },
  actions: {
    setPoemsThunk: ({ commit }) => {
      (async() => {
	let res = await fetch(`${server()}/poems`, {
	  method: 'get',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          }
	});
	if(res.status === 200) {
	  let json = await res.json();
	  commit('setPoems', json);
	  return true;
	} else {
	  console.log(`couldn't fetch poems`);
	  return false;
	}
      })();
    },
    setEntriesThunk: ({ commit }, page) => {
      (async() => {
	let res = await fetch(`${server()}/entry/page/${page}`, {
	  method: 'get',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          }
	});
	if(res.status === 200) {
	  let json = await res.json();
	  commit('setEntries', json);
	  return true;
	} else {
	  console.log(`couldn't fetch entries`);
	  return false;
	}
      })();
    }
  }
});
