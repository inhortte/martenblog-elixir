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
          <b-list-group horizontal="md">
            <entry-topic v-for="topic in entry.topics" :topic="topic" />
          </b-list-group>
        </b-col>
        <b-col sm="2" class="expand-collapse">
          <div>
            <a @click="toggleExpand(entry._id)" style="cursor: pointer;">
              <span v-if="expanded">collapse</span>
              <span v-if="!expanded">expand</span>
            </a>
          </div>
          <div><em style="font: smaller">{{ isFederated }}</em></div>
          <div>
            <a href="#" @click="federate">{{ toFederate }}</a>
          </div>
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
    canFederate() {
      return this.$store.getters['isAuthenticated'];
    },
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
    },
    isFederated() {
      if(this.$store.getters['isAuthenticated']) {
        return this.entry.federated ? "Federated" : "Not federated";
      } else {
        return '';
      }
    },
    toFederate() {
      if(this.$store.getters['isAuthenticated']) {
        return this.entry.federated ? "refederate" : "federate";
      } else {
        return '';
      }
    }
  },
  methods: {
    formatDate(timestamp) {
      return new Date(timestamp).toUTCString();
    },
    toggleExpand(id) {
      this.$store.commit('toggleExpand', id);
    },
    federate(e) {
      console.log(`Entry: federate -> entry: ${JSON.stringify(this.entry)}`);
      this.$store.dispatch("federateEntryThunk", this.entry["_id"]);
    }
  }
}
</script>
