'use strict';

<template>
<b-jumbotron>
  <h1>Flavigula</h1>
  <p>Here lies Martes Flavigula, eternally beneath the splintered earth.</p>
  <hr class="my-4" />
  <p>
    <router-link to="/blog/1">blog</router-link> | <router-link to="/music">music</router-link> | <router-link to="/poems">poems</router-link> |
    <router-link v-show="loggedOut" to="/login">log in</router-link>
    <b-link v-show="loggedIn" @click="logout">log out</b-link>
  </p>
  <p class="sd text-muted" text-muted v-show="authStatusRelevant">
    {{ authStatus }}
  </p>
</b-jumbotron>
</template>


<script>
export default {
  name: 'cabeza',
  computed: {
    loggedIn() {
      let thurk = this.$store.getters['isAuthenticated'];
      console.log(`loggedIn -> ${thurk}`);
      return thurk;
    },
    loggedOut() {
      return !this.$store.getters['isAuthenticated'];
    },
    authStatusRelevant() {
      return this.$store.getters['authStatus'] !== '';
    },
    authStatus() {
      let status = this.$store.getters['authStatus'];
      return status;
    }
  },
  methods: {
    logout() {
      this.$store.dispatch('authLogoutThunk');
    }
  }
}
</script>
