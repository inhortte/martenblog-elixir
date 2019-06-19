'use strict';

<template>
<b-container class="hlavni">
  <cabeza />
  <router-view></router-view>
  <abdomen class="abdomen" />
</b-container>
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
