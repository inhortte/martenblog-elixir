'use strict';

<template>
<b-jumbotron>
  <h1>Flavigula</h1>
  <p>Here lies Martes Flavigula, eternally beneath the splintered earth.</p>
  <hr class="my-4" />
  <p>
    <router-link to="/blog/1">blog</router-link> | <router-link to="/music">music</router-link> | <router-link to="/poems">poems</router-link> |
    <router-link v-if="loggedIn" to="/login">log in</router-link>
    <b-link v-if="loggedOut" @click="logout">log out</b-link>
  </p>
</b-jumbotron>
</template>


<script>
export default {
  name: 'cabeza',
  computed: {
    loggedIn() {
      this.$store.getters['isAuthenticated'];
    },
    loggedOut() {
      !this.$store.getters['isAuthenticated'];
    }
  },
  methods: {
    logout: () => {
      this.$store.dispatch('authLogoutThunk');
    }
  }
}
</script>
