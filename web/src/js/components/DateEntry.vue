'use strict';

<template>
<b-card style="margin-bottom: 20px">
  <div slot="header">
    <div><em>{{ dateEntry.subject }}</em></div>
    <div><em>{{ formattedDate }}</em></div>
    <b-list-group horizontal>
      <entry-topic v-for="topic in dateEntry.topics" :topic="topic" />
    </b-list-group>
  </div>
  <b-card-text v-html="formattedEntry" />
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
      return md(this.dateEntry.entry);
    }
  }
}
</script>
