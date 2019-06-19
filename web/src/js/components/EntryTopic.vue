'use strict';

<template>
<b-list-group-item class="entry-topic">{{ formattedTopic }}</b-list-group-item>
</template>

<script>
import { capitalize } from '../utils';
export default {
  name: 'entry-topic',
  props: ['topic'],
  computed: {
    formattedTopic() {
      return capitalize(this.topic.topic);
    }
  }
}
</script>
