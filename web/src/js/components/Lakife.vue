'use strict';

<template>
  <div>
    <b-card title="Lakife -" no-body>
      <h4 slot="header">Lakife -</h4>
      <ul style="padding-top: 20px;">
        <li><router-link to="/lakife/phonology">Phonology</router-link></li>
        <li><router-link to="/lakife/pronouns">Pronouns</router-link></li>
        <li><router-link to="/lakife/grammar">Various Grammar Musings</router-link></li>
        <li><router-link to="/lakife/mihupola">Mihupola</router-link></li>
        <li><router-link to="/lakife/babeltext">Babel Text</router-link></li>
        <li><router-link to="/lakife/vocabulary">Vocabulary</router-link></li>
        <li><router-link to="/lakife/phrases">Arbitrary Phrases</router-link></li>
      </ul>
      <router-view></router-view>
    </b-card>
  </div>
</template>

<script>
export default {
  name: 'Lakife',
  components: {
  },
  computed: {
  },
  methods: {
  }
};
</script>
