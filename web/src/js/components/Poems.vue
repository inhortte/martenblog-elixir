'use strict';

<template>
<b-card title="Poems -">
  <b-card-group deck v-for="poemGroup in poemGroups" style="margin-bottom: 20px;">
    <b-card v-for="poem in poemGroup" :title="poem.title">
      <b-card-text><pre>{{ poem.poem }}</pre></b-card-text>
      <div slot="footer"><small class="text-muted">{{ poem.fecha }}</small></div>
    </b-card>
  </b-card-group>
</b-card>
</template>

<script>
import R from 'ramda';
export default {
  name: 'poems',
  computed: {
    poemGroups() {
      return R.compose(
	R.splitEvery(2),
	R.sort((a, b) => {
	  let aTitle = a.normalised_title.toUpperCase();
	  let bTitle = b.normalised_title.toUpperCase();
	  if(aTitle < bTitle) {
	    return -1;
	  } else if(aTitle > bTitle) {
	    return 1;
	  } else {
	    return 0;
	  }
	})
      )(this.$store.getters['poems']);
    }
  }
}
</script>
