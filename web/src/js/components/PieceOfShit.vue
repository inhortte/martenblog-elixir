'use strict';

<template>
  <b-card-text>
    <b-list-group>
      <b-list-group-item v-for="pos in piecesOfShit">{{ pos }}</b-list-group-item>
    </b-list-group>
  </b-card-text>
</template>

<script>
export default {
  name: 'PieceOfShit',
  computed: {
    piecesOfShit() {
      return this.$store.getters['piecesOfShit'].slice(0, 11);
    }
  }
}
</script>

