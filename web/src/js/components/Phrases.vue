'use strict';

<template>
  <b-card-text style="margin: 20px;">
    <p>
      <b-form inline>
        <label for="phraseFilter" style="margin-right: 8px;">Filter</label>
        <b-input v-model="phraseFilter" id="phraseFilter" placeholder="Die the mud death"></b-input>
      </b-form>
    </p>
    <p>
      <div v-for="entry in phrases" style="border-top: 2px; padding-top: 2px;">
        <hr />
        <strong>{{ entry.lakife }}</strong><br />
        {{ entry.english }}
      </div>
    </p>
  </b-card-text>
</template>

<script>
export default {
  name: 'Phrases',
  data() {
    return {
      phraseFilter: ''
    };
  },
  components: {
  },
  computed: {
    phrases() {
      this.$store.dispatch('setFilteredPhrasesThunk', this.phraseFilter);
      let bastard = this.$store.getters['filteredPhrases'].map(entry => ({ lakife: entry[1], english: entry[2] }));
      return bastard;
    },
    isPhrases() {
      return this.$store.getters['phraseCount'] > 0;
    }
  },
  methods: {
  }
};
</script>
