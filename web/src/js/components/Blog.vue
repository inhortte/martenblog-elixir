'use strict';

<template>
<b-card title="Blog -">
  <entry v-for="entry in pagedEntries" :entry="entry" />
</b-card>
</template>

<script>
import R from 'ramda';
import htmlToText from 'html-to-text';
import Entry from './Entry.vue';
export default {
  name: 'blog',
  components: { Entry },
  computed: {
    pagedEntries() {
      return this.$store.getters['entries'];
    }
  },
  methods: {
  },
  created() {
    this.$store.dispatch('setEntriesThunk', this.$route.params.page);
  }
}
</script>
