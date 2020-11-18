'use strict';

<template>
  <b-card-text style="margin: 20px;" v-html="mihupola" />
</template>

<script>
const md = require('marked');
const fs = require('fs');
export default {
  name: 'Mihupola',
  computed: {
    mihupola() {
      return md(this.$store.getters['mihupola']);
    }
  },
  methods: {
  }
};
</script>
