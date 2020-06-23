"use strict";

import Vue from "vue";
import BootstrapVue from "bootstrap-vue";
import VueRouter from "vue-router";
import Hlavni from "./Hlavni.vue";
import store from "./store";
import Blog from "./components/Blog.vue";
import BlogByDate from "./components/BlogByDate.vue";
import Poems from "./components/Poems.vue";
import Music from "./components/Music.vue";
import Login from "./components/Login.vue";
import Curiosities from "./components/Curiosities.vue";

const router = new VueRouter({
  routes: [
    {
      path: "/",
      component: Music,
      meta: {
        title: "The creations of a small, vicious animal",
        metaTags: [
          {
            name: "description",
            content:
              "Flavigula is a respository for music, poetry and writing.  Flavigula has released albums such as Bons Mots, Music Inspired by Dobbs' Cowboys, Polymorfóza, Unkle Barkestle and A Cube Beneath the Sand.  The poetry is influenced by the imagist and modernist movements.",
          },
          {
            name: "og:description",
            content:
              "Flavigula is a respository for music, poetry and writing.  Flavigula has released albums such as Bons Mots, Music Inspired by Dobbs' Cowboys, Polymorfóza, Unkle Barkestle and A Cube Beneath the Sand.  The poetry is influenced by the imagist and modernist movements.",
          },
        ],
      },
    },
    {
      path: "/login",
      name: "login",
      component: Login,
      meta: {
        title: "Polož slezinu na podložku",
      },
    },
    {
      path: "/curiosities",
      name: "curiosities",
      component: Curiosities,
    },
    {
      path: "/blog/:page",
      name: "blog",
      component: Blog,
      meta: {
        title: "A pointed stick for your troubles",
        metaTags: [
          {
            name: "description",
            content:
              "The mustelids of the earth (and possibly other nitrogen and oxygen rich planetoids) will rise up and destroy you",
          },
          {
            name: "description",
            content:
              "The mustelids of the earth (and possibly other nitrogen and oxygen rich planetoids) will rise up and destroy you",
          },
        ],
      },
    },
    {
      path: "/blog/:y/:m/:d",
      name: "blog-by-date",
      component: BlogByDate,
      meta: {
        title: "A barrage of olfactory residue",
        metaTags: [
          {
            name: "description",
            content:
              "The mustelids of the earth (and possibly other nitrogen and oxygen rich planetoids) will rise up and destroy you",
          },
          {
            name: "description",
            content:
              "The mustelids of the earth (and possibly other nitrogen and oxygen rich planetoids) will rise up and destroy you",
          },
        ],
      },
    },
    {
      path: "/poems",
      component: Poems,
      meta: {
        title: "Poetry written by a small, vicious animal",
        metaTags: [
          {
            name: "description",
            content:
              "The poetry of the resident mustelid is influenced by the imagist and modernist movements.",
          },
          {
            name: "og:description",
            content:
              "The poetry of the resident mustelid is influenced by the imagist and modernist movements.",
          },
        ],
      },
    },
    {
      path: "/music",
      component: Music,
      meta: {
        title: "Music composed by a small, vicious animal",
        metaTags: [
          {
            name: "description",
            content:
              "Bons Mots, Music Inspired by Dobbs' Cowboys, Polymorfóza, Unkle Barkestle, A Cube Beneath the Sand",
          },
          {
            name: "og:description",
            content:
              "Bons Mots, Music Inspired by Dobbs' Cowboys, Polymorfóza, Unkle Barkestle, A Cube Beneath the Sand",
          },
        ],
      },
    },
  ],
});

router.beforeEach((to, from, next) => {
  let firstWithTitle = to.matched
    .slice()
    .reverse()
    .find((route) => route.meta && route.meta.title);
  let firstWithMeta = to.matched
    .slice()
    .reverse()
    .find((route) => route.meta && route.meta.metaTags);
  if (firstWithTitle) {
    document.title = firstWithTitle.meta.title;
  }
  Array.from(document.querySelectorAll("[data-vue-router-controlled]")).map(
    (el) => el.parentNode.removeChild(el)
  );
  if (firstWithMeta) {
    firstWithMeta.meta.metaTags
      .map((def) => {
        const tag = document.createElement("meta");
        tag.setAttribute("data-vue-router-controlled", "");
        Object.keys(def).forEach((key) => {
          tag.setAttribute(key, def[key]);
        });
        return tag;
      })
      .forEach((tag) => {
        document.head.appendChild(tag);
      });
  }
  next();
});

Vue.use(VueRouter);
Vue.use(BootstrapVue);
new Vue({
  el: "#marten-block",
  store,
  router,
  render: (h) => h(Hlavni),
});
