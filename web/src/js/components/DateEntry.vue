'use strict';

<template>
<b-card style="margin-bottom: 20px">
  <div slot="header">
    <div><em>{{ dateEntry.subject }}</em></div>
    <div><em>{{ formattedDate }}</em></div>
    <b-list-group horizontal="sm">
      <entry-topic v-for="topic in dateEntry.topics" :topic="topic" />
    </b-list-group>
  </div>
  <b-card-text class="entry" v-html="formattedEntry" />
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
    }
  }
}
</script>
