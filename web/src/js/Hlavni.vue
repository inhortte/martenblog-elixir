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
  async mounted() {
    this.$store.dispatch('setPoemsThunk');
    await this.$store.dispatch('fetchLakifeVocabulary');
    this.$store.dispatch('setFilteredVocabularyThunk', '');
    await this.$store.dispatch('fetchLakifePhrases');
    this.$store.dispatch('setFilteredPhrasesThunk', '');
    this.$store.dispatch('fetchGrammarThunk');
    this.$store.dispatch('fetchMihupolaThunk');
  },
  data() {
    return {};
  }
}
</script>
