'use strict';

<template>
<b-card class="entry-card" >
  <div slot="header">
    <b-container>
      <b-row>
	<b-col md="12">
	  <em><router-link :to="dateLink">{{ entry.subject }}</router-link></em>
	</b-col>
      </b-row>
      <b-row>
	<b-col sm="10">
<<<<<<< HEAD
	  <b-list-group horizontal="md">
=======
	  <b-list-group horizontal="sm">
>>>>>>> fe3593d72eda8e65ca57a366a924e1ad64494a38
	    <entry-topic v-for="topic in entry.topics" :topic="topic" />
	  </b-list-group>
	</b-col>
	<b-col sm="2" class="expand-collapse">
	  <a @click="toggleExpand(entry._id)" style="cursor: pointer;">
	    <span v-if="expanded">collapse</span>
	    <span v-if="!expanded">expand</span>
	  </a>
	</b-col>
      </b-row>
    </b-container>
  </div>
  <b-card-text class="entry" v-html="formattedEntry"></b-card-text>
  <em slot="footer">{{ formatDate(entry.created_at) }}</em>
</b-card>
</template>

<script>
const md = require('marked');
import R from 'ramda';
import htmlToText from 'html-to-text';
import EntryTopic from './EntryTopic.vue';
export default {
  name: 'entry',
  props: ['entry'],
  components: { EntryTopic },
  computed: {
    expanded() {
      return this.$store.getters['isEntryExpanded'](this.entry._id);
    },
    formattedEntry() {
      if(this.$store.getters['isEntryExpanded'](this.entry._id)) {
	return md(this.entry.entry);
      } else {
	return R.compose(R.flip(R.concat)('...'), R.slice(0, 144), htmlToText.fromString)(this.entry.entry);
      }
    },
    dateLink() {
      let d = new Date(this.entry.created_at);
      return `/blog/${d.getUTCFullYear()}/${d.getUTCMonth() + 1}/${d.getUTCDate()}`;
    }
  },
  methods: {
    formatDate(timestamp) {
      return new Date(timestamp).toUTCString();
    },
    toggleExpand(id) {
      this.$store.commit('toggleExpand', id);
    }
  }
}
</script>
