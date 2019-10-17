'use strict';

<template>
<b-card title="Login -" class="overflow-hidden" no-body>
  <h4 slot="header">Login -</h4>
  <b-card-body>
    <b-form inline @submit.prevent="login">
      <label class="sr-only" for="input-name">Login</label>
      <b-input required id="input-login" class="mr-sm-2" v-model="username" type="text" placeholder="Slezina"/>
      <label class="sr-only" for="input-password">Password</label>
      <b-input required id="input-password" class="mr-sm-2" v-model="password" type="password" placeholder="Heslo"/>
      <b-button type="submit" variant="outline-primary">Oouh!</b-button>
    </b-form>
  </b-card-body>
</b-card>
</template>

<script>
export default {
  name: 'login',
  data: {
  },
  methods: {
    login: () => {
      const { username, password } = this;
      this.$store.dispatch('authRequestThunk', { username, password }).then(() => {
        this.$router.push('/')
      })
    }
  }
}
</script>
