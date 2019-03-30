'use strict';

import Vue from 'vue';
import BootstrapVue from 'bootstrap-vue';
import Hlavni from './Hlavni.vue';
import store from './store';

Vue.use(BootstrapVue);
new Vue({
  el: '#marten-block',
  store,
  render: h => h(Hlavni)
});
