'use strict';

<template>
  <b-card-text style="margin: 20px;">
    <p>
      <b-form inline>
        <label for="vocabFilter" style="margin-right: 8px;">Filter</label>
        <b-input v-model="vocabFilter" id="vocabFilter" placeholder="Die the flame death"></b-input>
      </b-form>
    </p>
    <p>
      <div v-for="entry in vocab">
        {{ entry.lakife }} - {{ entry.english }}
      </div>
    </p>
  </b-card-text>
</template>

<script>
export default {
  name: 'Vocabulary',
  data() {
    return {
      vocabFilter: ''
    };
  },
  components: {
  },
  computed: {
    vocab() {
      this.$store.dispatch('setFilteredVocabularyThunk', this.vocabFilter);
      let bastard = this.$store.getters['filteredVocabulary'].map(entry => ({ lakife: entry[1], english: entry[2] }));
      console.log(`vocab: ${JSON.stringify(bastard)}`);
      return bastard;
    },
    isVocab() {
      console.log(`vocabCount is ${this.$store.getters['vocabCount']}`);
      return this.$store.getters['vocabCount'] > 0;
    }
  },
  methods: {
  }
};
</script>
