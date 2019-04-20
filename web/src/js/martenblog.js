'use strict';

import Vue from 'vue';
import BootstrapVue from 'bootstrap-vue';
import VueRouter from 'vue-router';
import Hlavni from './Hlavni.vue';
import store from './store';
import Blog from './components/Blog.vue';
import Poems from './components/Poems.vue';
import Music from './components/Music.vue';

const router = new VueRouter({
  routes: [
    { path: '/blog', component: Blog },
    { path: '/poems', component: Poems },
    { path: '/music', component: Music }
  ]
});

Vue.use(VueRouter);
Vue.use(BootstrapVue);
new Vue({
  el: '#marten-block',
  store,
  router,
  render: h => h(Hlavni)
});
