'use strict';

<template>
  <b-card-text style="margin: 20px;" v-html="grammar" />
</template>

<script>
const md = require('marked');
const fs = require('fs');
export default {
  name: 'Grammar',
  computed: {
    grammar() {
      return md(this.$store.getters['grammar']);
    }
  },
  methods: {
  }
};
</script>
