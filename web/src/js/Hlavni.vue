'use strict';

<template>
<b-card no-body>
  <head />
  <abdomen />
</b-card>
</template>

<script>
import Head from './components/Head.vue';
import Abdomen from './components/Abdomen.vue';
export default {
  name: 'hlavni',
  components: {
    Head, Abdomen
  },
  computed: {
  },
  methods: {
  },
  mounted() {
  },
  data() {
  }
}
</script>
