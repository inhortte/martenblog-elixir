'use strict';

<template>
<b-card title="Blog -" no-body>
  <h4 slot="header">Blog -</h4>
  <b-container>
    <b-row style="font-size: smaller; font-weight: bold;">
      <b-col sm="12" md="3" style="text-align: left;" @click="loadPrev">
	<router-link v-if="prev" :to="dateLink('prev')">&lt; {{ prev }}</router-link>
      </b-col>
      <b-col sm="12" md="6" style="text-align: center;">
	<router-link to="/blog/1">back</router-link>
      </b-col>
      <b-col sm="12" md="3" style="text-align: right;" @click="loadNext">
	<router-link v-if="next" :to="dateLink('next')">{{ next }} &gt;</router-link>
      </b-col>
    </b-row>
    <b-row>
      <b-col>
	<date-entry v-for="dateEntry in dateEntries" :dateEntry="dateEntry" />
      </b-col>
    </b-row>
  </b-container>
</b-card>
</template>

<script>
import DateEntry from './DateEntry.vue';
export default {
  name: 'blog-by-date',
  components: { DateEntry },
  computed: {
    dateEntries() {
      return this.$store.getters['dateEntries'];
    },
    prev() {
      let ts = this.$store.getters['prev'];
      if(ts) {
	console.log(`prev: ${ts}`);
	return new Date(ts).toDateString();
      } else {
	return null;
      }
    },
    next() {
      let ts = this.$store.getters['next'];
      if(ts) {
	return new Date(ts).toDateString();
      } else {
	return null;
      }
    }
  },
  methods: {
    dateLink(tipo) {
      let ts = this.$store.getters[tipo];
      if(ts) {
	let d = new Date(ts);
	return `/blog/${d.getUTCFullYear()}/${d.getUTCMonth() + 1}/${d.getUTCDate()}`;
      } else {
	return `/blog/1`;
      }
    },
    loadPrev() {
      let ts = this.$store.getters['prev'];
      if(ts) {
	let d = new Date(ts);
	this.$store.dispatch('setEntriesByDateThunk', { y: d.getUTCFullYear(), m: d.getUTCMonth() + 1, d: d.getUTCDate() });
      }
    },
    loadNext() {
      let ts = this.$store.getters['next'];
      if(ts) {
	let d = new Date(ts);
	this.$store.dispatch('setEntriesByDateThunk', { y: d.getUTCFullYear(), m: d.getUTCMonth() + 1, d: d.getUTCDate() });
      }
    }
  },
  created() {
    this.$store.dispatch('setEntriesByDateThunk', this.$route.params);
  }
}
</script>
