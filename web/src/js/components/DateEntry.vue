'use strict';

<template>
<b-card style="margin-bottom: 20px">
  <b-row>
    <b-col md="9" sm="12">
      <div slot="header">
        <div><em>{{ dateEntry.subject }}</em></div>
        <div><em>{{ formattedDate }}</em></div>
        <b-list-group horizontal="sm">
          <entry-topic v-for="topic in dateEntry.topics" :topic="topic" />
        </b-list-group>
      </div>
    </b-col>
    <b-col md="3" sm="12">
      <div><em style="font: smaller">{{ isFederated }}</em></div>
      <div>
        <a href="#" @click="federate">{{ toFederate }}</a>
      </div>
    </b-col>
  </b-row>
  <b-row>
    <b-col sm="12">
      <b-card-text class="entry" v-html="formattedEntry" />
    </b-col>
  </b-row>
</b-card>
</template>

<script>
const md = require('marked');
import EntryTopic from './EntryTopic.vue';
export default {
  name: 'date-entry',
  props: ['dateEntry'],
  components: { EntryTopic },
  computed: {
    formattedDate() {
      return new Date(this.dateEntry.created_at).toUTCString();
    },
    formattedEntry() {
      let entry = this.dateEntry.entry;
      Array.from(document.querySelectorAll("[data-vue-router-controlled]")).map(
        el => el.parentNode.removeChild(el)
      );
      const mTag = document.createElement("meta");
      const ogMTag = document.createElement("meta");
      mTag.setAttribute('data-vue-router-controlled', '');
      ogMTag.setAttribute('data-vue-router-controlled', '');
      mTag.setAttribute('name', 'description');
      mTag.setAttribute('content', entry.slice(0, 512));
      ogMTag.setAttribute('name', 'og:description');
      ogMTag.setAttribute('content', entry.slice(0, 512));
      document.head.appendChild(mTag);
      document.head.appendChild(ogMTag);
      return md(this.dateEntry.entry);
    },
    isFederated() {
      if(this.$store.getters['isAuthenticated']) {
        return this.dateEntry.federated ? "Federated" : "Not federated";
      } else {
        return '';
      }
    },
    toFederate() {
      if(this.$store.getters['isAuthenticated']) {
        return this.dateEntry.federated ? "refederate" : "federate";
      } else {
        return '';
      }
    }
  },
  methods: {
    federate(e) {
      console.log(`DateEntry: federate -> dateEntry: ${JSON.stringify(this.dateEntry)}`);
      this.$store.dispatch("federateEntryThunk", this.dateEntry["_id"]);
    }
  }
}
</script>
