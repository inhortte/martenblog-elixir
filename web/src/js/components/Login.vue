'use strict';

<template>
<b-card title="Login -" class="overflow-hidden" no-body>
  <h4 slot="header">Login -</h4>
  <b-card-body>
    <b-form inline @submit.prevent="login">
      <label class="sr-only" for="input-password">Password</label>
      <b-input required id="input-password" class="mr-sm-2" v-model="heslo" type="password" placeholder="Slezina"/>
      <b-button type="submit" variant="outline-primary">Oouh!</b-button>
    </b-form>
  </b-card-body>
</b-card>
</template>

<script>
export default {
  name: 'login',
  data: () => {
    return {
      heslo: ''
    };
  },
  methods: {
    login() {
      const { heslo } = this;
      console.log(`heslo -> ${heslo}`);
      this.$store.dispatch('authRequestThunk', heslo).then(() => {
        this.$router.push('/')
      })
    }
  }
}
</script>
