'use strict';

<template>
<b-card no-body style="width: 926px; margin-left: auto; margin-right: auto;">
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
    cardStyle() {
      return {
	width: 10
      };
    }
  },
  methods: {
  },
  mounted() {
    this.$store.dispatch('setPoemsThunk');
  },
  data() {
    return {};
  }
}
</script>
