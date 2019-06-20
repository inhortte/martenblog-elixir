'use strict';

<template>
<b-card title="Blog -">
  <b-container>
    <b-row>
      <b-col>
	<b-pagination-nav use-router :link-gen="linkGen" :number-of-pages="pCount" @change="loadEntries" />
      </b-col>
    </b-row>
    <b-row>
      <b-col>
	<entry v-for="entry in pagedEntries" :entry="entry" />
      </b-col>
    </b-row>
  </b-container>
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
    },
    pCount() {
      return Math.ceil(this.$store.getters['pCount'] / 11);
    }
  },
  methods: {
    linkGen(pNum) {
      return {
	name: 'blog',
	params: { page: pNum }
      }
    },
    loadEntries(page) {
      this.$store.dispatch('setEntriesThunk', page);
    }
  },
  created() {
    this.$store.dispatch('setEntriesThunk', this.$route.params.page);
    this.$store.dispatch('pCountThunk');
  }
}
</script>
