'use strict';

<template>
  <b-card-text>
    <b-list-group>
      <b-list-group-item v-for="hvps in highVoltagePowerSupplies">{{ hvps }}</b-list-group-item>
    </b-list-group>
  </b-card-text>
</template>

<script>
export default {
  name: 'HighVoltagePowerSupply',
  computed: {
    highVoltagePowerSupplies() {
      return this.$store.getters['highVoltagePowerSupplies'].slice(0, 11);
    }
  }
}
</script>

