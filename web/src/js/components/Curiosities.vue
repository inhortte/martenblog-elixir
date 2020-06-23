'use strict';

<template>
  <div>
    <b-card title="Curiosities -" no-body>
      <h4 slot="header">Curiosities -</h4>
      <b-card-text>
        <b-list-group horizontal>
          <b-list-group-item v-for="curio in curios" button @click="loadCurio(curio)">{{ curio.name }}</b-list-group-item>
        </b-list-group>
      </b-card-text>
    </b-card>
    <b-card v-if="sentient">
      <component :is="currentCuriosity" />
    </b-card>
  </div>
</template>

<script>
import PieceOfShit from './PieceOfShit.vue';
import HighVoltagePowerSupply from './HighVoltagePowerSupply.vue';
export default {
  name: 'Curiosities',
  components: {
    PieceOfShit,
    HighVoltagePowerSupply
  },
  data() {
    return {
      curiosity: null,
      curioList: [
        {
          name: "Piece of Shit",
          component: 'piece-of-shit',
          thunk: 'fetchPiecesOfShit'
        },
        {
          name: "The High Voltage Power Supply",
          component: 'high-voltage-power-supply',
          thunk: 'fetchHighVoltagePowerSupplies'
        }
      ]
    };
  },
  computed: {
    sentient() {
      return !!this.curiosity;
    },
    currentCuriosity() {
      if(this.curiosity) {
        return this.curiosity.component;
      } else {
        return null;
      }
    },
    curios() {
      return this.curioList;
    }
  },
  methods: {
    loadCurio(curio) {
      this.curiosity = curio;
      this.$store.dispatch(curio.thunk);
    }
  }
};
</script>
