'use strict';

<template>
<b-card no-body>
  <cabeza />
  <router-view></router-view>
  <abdomen />
</b-card>
</template>

<script>
import Cabeza from './components/Cabeza.vue';
import Abdomen from './components/Abdomen.vue';
export default {
  name: 'hlavni',
  components: {
    Cabeza, Abdomen
  },
  computed: {
  },
  methods: {
  },
  mounted() {
  },
  data() {
    return {};
  }
}
</script>
