"use strict";

import Vue from "vue";
import Vuex from "vuex";
import { mapGetters } from "vuex";
import R from "ramda";
import { server } from "../config";

Vue.use(Vuex);

console.log(
  `let's look at slezina-token: ${localStorage.getItem("slezina-token")}`
);

export default new Vuex.Store({
  state: {
    poems: [],
    currentPoem: {},
    entries: [],
    dateEntries: [],
    prev: null,
    next: null,
    expanded: {},
    pCount: 1,
    token: localStorage.getItem("slezina-token") || null,
    authStatus: "",
    piecesOfShit: [],
    highVoltagePowerSupplies: [],
    lakifeVocabulary: [],
    filteredVocabulary: [],
    lakifePhrases: [],
    filteredPhrases: [],
    mihupola: "",
    grammar: "",
  },
  getters: {
    poems: (state) => {
      return state.poems;
    },
    entries: (state) => {
      return state.entries;
    },
    dateEntries: (state) => state.dateEntries,
    isEntryExpanded: (state) => (id) => {
      return !!state.expanded[id];
    },
    pCount: (state) => {
      return state.pCount;
    },
    prev: (state) => state.prev,
    next: (state) => state.next,
    isAuthenticated: (state) => !!state.token,
    authStatus: (state) => state.authStatus,
    token: (state) => state.token,
    piecesOfShit: (state) => state.piecesOfShit,
    highVoltagePowerSupplies: (state) => state.highVoltagePowerSupplies,
    filteredVocabulary: (state) => {
      return state.filteredVocabulary;
    },
    vocabCount: (state) => state.filteredVocabulary.length,
    filteredPhrases: (state) => state.filteredPhrases,
    phraseCount: (state) => state.filteredPhrases.length,
    grammar: (state) => state.grammar,
    mihupola: (state) => state.mihupola,
  },
  mutations: {
    setPoems: (state, poems) => {
      state.poems = poems;
    },
    setEntries: (state, entries) => {
      state.entries = entries;
    },
    setDateEntries: (state, dateEntries) => {
      state.dateEntries = dateEntries;
    },
    toggleExpand: (state, id) => {
      let expanded = Object.assign({}, state.expanded);
      Vue.set(state.expanded, id, !expanded[id]);
    },
    setPCount: (state, pCount) => {
      state.pCount = pCount.pcount;
    },
    setAlrededores: (state, [prev, next]) => {
      state.prev = prev;
      state.next = next;
    },
    authRequest: (state) => {
      state.authStatus = "the thurk is pulsing";
    },
    authSuccess: (state, token) => {
      state.authStatus = "the thurk has succeeded";
      state.token = token;
    },
    authError: (state) => {
      state.authStatus = "the thurk has plummeted to the depths";
    },
    authLogout: (state) => {
      state.authStatus = "";
      state.token = null;
    },
    federateEntry: (state, id) => {
      state.dateEntries = state.dateEntries.map((e) => {
        if (e.id === id) {
          e.federated = true;
        }
        return e;
      });
      state.entries = state.entries.map((e) => {
        if (e.id === id) {
          e.federated = true;
        }
        return e;
      });
    },
    setPiecesOfShit: (state, pos) => {
      state.piecesOfShit = pos;
    },
    setHighVoltagePowerSupplies: (state, hvps) => {
      state.highVoltagePowerSupplies = hvps;
    },
    setLakifeVocabulary: (state, vocab) => {
      state.lakifeVocabulary = Object.freeze(vocab);
    },
    setFilteredVocabulary: (state, vocab) => {
      state.filteredVocabulary = vocab;
    },
    setLakifePhrases: (state, phrases) => {
      state.lakifePhrases = Object.freeze(phrases);
    },
    setFilteredPhrases: (state, phrases) => {
      state.filteredPhrases = phrases;
    },
    setGrammar: (state, text) => {
      state.grammar = text;
    },
    setMihupola: (state, text) => {
      state.mihupola = text;
    },
  },
  actions: {
    authRequestThunk: ({ commit, dispatch }, heslo) => {
      return new Promise((resolve, reject) => {
        // The Promise used for router redirect in login
        commit("authRequest");
        let body = { heslo };
        console.log(`authRequestThunk -> body -> ${JSON.stringify(body)}`);
        fetch(`${server()}/login`, {
          method: "post",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
          body: JSON.stringify(body),
        })
          .then((resp) => resp.json())
          .then((json) => {
            console.log(`what are we receiving? ${JSON.stringify(json)}`);
            if (json.error) {
              commit("authError");
              localStorage.removeItem("slezina-token");
            } else {
              const token = json.token;
              localStorage.setItem("slezina-token", token); // store the token in localstorage
              commit("authSuccess", token);
              // you have your token, now log in your user :)
              // dispatch("userRequest");
            }
            resolve(json);
          })
          .catch((err) => {
            commit("authError", err);
            localStorage.removeItem("slezina-token"); // if the request fails, remove any possible user token if possible
            reject(err);
          });
      });
    },
    authLogoutThunk: ({ commit, dispatch, state }) => {
      return new Promise((resolve, reject) => {
        fetch(`${server()}/logout`, {
          method: "post",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ token: state.token }),
        })
          .then((resp) => {
            commit("authLogout");
            localStorage.removeItem("slezina-token"); // clear your user's token from localstorage
            resolve();
          })
          .catch((err) => {
            console.log(`logout error: ${err}`);
            reject();
          });
      });
    },
    setPoemsThunk: ({ commit }) => {
      (async () => {
        let res = await fetch(`${server()}/poems`, {
          method: "get",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
        });
        if (res.status === 200) {
          let json = await res.json();
          commit("setPoems", json);
          return true;
        } else {
          console.log(`couldn't fetch poems`);
          return false;
        }
      })();
    },
    setEntriesThunk: ({ commit }, page) => {
      (async () => {
        let res = await fetch(`${server()}/entry/page/${page}`, {
          method: "get",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
        });
        if (res.status === 200) {
          let json = await res.json();
          commit("setEntries", json);
          return true;
        } else {
          console.log(`couldn't fetch entries`);
          return false;
        }
      })();
    },
    setAlrededoresThunk: ({ commit }, ts) => {
      (async () => {
        let res = await fetch(`${server()}/alrededores/${ts}`, {
          method: "get",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
        });
        if (res.status === 200) {
          let json = await res.json();
          commit("setAlrededores", json);
          return true;
        } else {
          console.log(`couldn't fetch alrededores`);
          return false;
        }
      })();
    },
    setEntriesByDateThunk: ({ commit, dispatch }, { y, m, d }) => {
      console.log(`setEntriesbyDateThunk: ${y} ${m} ${d}`);
      (async () => {
        let res = await fetch(`${server()}/entry/by-date/${y}/${m}/${d}`, {
          method: "get",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
        });
        if (res.status === 200) {
          let json = await res.json();
          commit("setDateEntries", json);
          if (json.length > 0) {
            dispatch("setAlrededoresThunk", json[0].created_at);
          }
          return true;
        } else {
          console.log(`couldn't fetch entries`);
          return false;
        }
      })();
    },
    pCountThunk: ({ commit }) => {
      (async () => {
        let res = await fetch(`${server()}/pcount`, {
          method: "post",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
        });
        if (res.status === 200) {
          let json = await res.json();
          commit("setPCount", json);
          return true;
        } else {
          console.log(`couldn't fetch page count`);
          return false;
        }
      })();
    },
    federateEntryThunk: ({ commit, getters }, id) => {
      (async () => {
        let body = {
          id,
          federatedTo: [],
          token: getters["token"],
        };
        console.log(`federateEntryThunk:  body -> ${JSON.stringify(body)}`);
        let res = await fetch(`${server()}/federate`, {
          method: "post",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
          body: JSON.stringify(body),
        });
        if (res.status === 200) {
          let json = await res.json();
          console.log(
            `federateEntryThunk: the server returned -> ${JSON.stringify(json)}`
          );
          commit("federateEntry", id);
          return true;
        } else {
          console.log(`couldn't federate entry id ${id}`);
          return false;
        }
      })();
    },
    fetchPiecesOfShit: ({ commit }) => {
      (async () => {
        let res = await fetch(`${server()}/piece-of-shit`, {
          method: "get",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
        });
        if (res.status === 200) {
          let json = await res.json();
          /*
          console.log(
            `fetchPiecesOfShit: the server returned -> ${JSON.stringify(json)}`
          );
          */
          commit("setPiecesOfShit", json);
          return json;
        } else {
          console.log(`couldn't fetch piecesOfShit`);
          return false;
        }
      })();
    },
    fetchHighVoltagePowerSupplies: ({ commit }) => {
      (async () => {
        let res = await fetch(`${server()}/high-voltage-power-supply`, {
          method: "get",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
        });
        if (res.status === 200) {
          let json = await res.json();
          /*
          console.log(
            `fetchHighVoltagePowerSupplies: the server returned -> ${JSON.stringify(
              json
            )}`
          );
          */
          commit("setHighVoltagePowerSupplies", json);
          return json;
        } else {
          console.log(`couldn't fetch highVoltagePowerSupplies`);
          return false;
        }
      })();
    },
    async fetchLakifeVocabulary({ commit }) {
      let res = await fetch(`${server()}/lakife-vocabulary`, {
        method: "get",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
      });
      if (res.status == 200) {
        let json = await res.json();
        if (json.rows && json.rows.length > 0) {
          commit("setLakifeVocabulary", json.rows);
        }
      } else {
        console.log(`couldn't fetch lakife vocabulary`);
        return {};
      }
    },
    setFilteredVocabularyThunk({ state, commit }, f) {
      let vocabFilter = R.trim(f);
      let filteredVocabulary;
      if (R.isEmpty(vocabFilter)) {
        filteredVocabulary = state.lakifeVocabulary;
      } else {
        filteredVocabulary = R.filter((entry) => {
          let re = new RegExp(vocabFilter, "i");
          let _m1 = re.exec(entry[1]);
          let _m2 = re.exec(entry[2]);
          return _m1 || _m2;
        }, state.lakifeVocabulary);
      }
      // console.log(`filtered vocab -> ${JSON.stringify(filteredVocabulary)}`);
      commit("setFilteredVocabulary", filteredVocabulary);
    },
    async fetchLakifePhrases({ commit }) {
      let res = await fetch(`${server()}/lakife-phrases`, {
        method: "get",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
      });
      if (res.status == 200) {
        let json = await res.json();
        if (json.rows && json.rows.length > 0) {
          commit("setLakifePhrases", json.rows);
        }
      } else {
        console.log(`couldn't fetch lakife phrases`);
        return {};
      }
    },
    setFilteredPhrasesThunk({ state, commit }, f) {
      let phraseFilter = R.trim(f);
      let filteredPhrases;
      if (R.isEmpty(phraseFilter)) {
        filteredPhrases = state.lakifePhrases;
      } else {
        filteredPhrases = R.filter((entry) => {
          let re = new RegExp(phraseFilter, "i");
          let _m1 = re.exec(entry[1]);
          let _m2 = re.exec(entry[2]);
          return _m1 || _m2;
        }, state.lakifePhrases);
      }
      // console.log(`filtered phrases -> ${JSON.stringify(filteredPhrases)}`);
      commit("setFilteredPhrases", filteredPhrases);
    },
    async fetchGrammarThunk({ commit }) {
      let res = await fetch(`${server()}/lakife-grammar`);
      let text;
      if (res.status === 200) {
        text = await res.text();
      } else {
        console.log(`couldn't fetch lakife grammar: ${res.status}`);
        text = "### NULU";
      }
      commit("setGrammar", text);
      return text;
    },
    async fetchMihupolaThunk({ commit }) {
      let res = await fetch(`${server()}/lakife-mihupola`);
      let text;
      if (res.status === 200) {
        text = await res.text();
      } else {
        console.log(`couldn't fetch lakife mihupola: ${res.status}`);
        text = "### NULU";
      }
      commit("setMihupola", text);
      return text;
    },
  },
});
