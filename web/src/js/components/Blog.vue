'use strict';

<template>
<b-card title="Blog -">
  <b-card v-for="entry in pagedEntries"  style="margin-bottom: 20px;">
    <div slot="header"><em>{{ entry.subject }}</em></div>
    <b-card-text v-html="formatEntry(entry.entry)"></b-card-text>
    <em slot="footer">{{ formatDate(entry.created_at) }}</em>
  </b-card>
</b-card>
</template>

<script>
const md = require('marked');
export default {
  name: 'blog',
  computed: {
    pagedEntries() {
      return this.$store.getters['entries'];
    }
  },
  methods: {
    formatDate(timestamp) {
      return new Date(timestamp).toUTCString();
    },
    formatEntry(entry) {
      return md(entry);
    }
  },
  created() {
    this.$store.dispatch('setEntriesThunk', this.$route.params.page);
  }
}
</script>
