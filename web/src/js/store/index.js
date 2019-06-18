'use strict';

import Vue from 'vue';
import Vuex from 'vuex';
import { mapGetters } from 'vuex';
import R from 'ramda';

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    poems: [],
    currentPoem: {},
    entries: []
  },
  getters: {
    poems: state => {
      return state.poems;
    },
    entries: state => {
      return state.entries;
    }
  },
  mutations: {
    setPoems: (state, poems) => {
      state.poems = poems;
    },
    setEntries: (state, entries) => {
      state.entries = entries;
    }
  },
  actions: {
    setPoemsThunk: ({ commit }) => {
      (async() => {
	let res = await fetch('http://localhost:8777/poems', {
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
	let res = await fetch(`http://localhost:8777/entry/page/${page}`, {
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
