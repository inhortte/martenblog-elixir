'use strict';

import Vue from 'vue';
import Vuex from 'vuex';
import { mapGetters } from 'vuex';
import R from 'ramda';

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    poems: [],
    currentPoem: {}
  },
  getters: {
    poems: state => {
      return state.poems;
    }
  },
  mutations: {
    setPoems: (state, poems) => {
      state.poems = poems;
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
    }
  }
});
