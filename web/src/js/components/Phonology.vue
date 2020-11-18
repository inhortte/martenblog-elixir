'use strict';

<template>
  <b-card-text style="margin-top: 20px; margin-bottom: 20px; margin-left: 20px;">
    <h3>Phonology</h3>
    <h4>Vowels</h4>
    <b-img src="images/lakife-vowels.png" fluid />
    <h4>Consonants</h4>
    <b-table-simple striped bordered responsive>
      <b-thead>
        <b-tr>
          <b-th></b-th>
          <b-th class="text-center">Bi-labial</b-th>
          <b-th class="text-center">Labio-dental</b-th>
          <b-th class="text-center">Dental</b-th>
          <b-th class="text-center">Alveolar</b-th>
          <b-th class="text-center">Post-alveolar</b-th>
          <b-th class="text-center">Palatal</b-th>
          <b-th class="text-center">Velar</b-th>
          <b-th class="text-center">Glottal</b-th>
        </b-tr>
      </b-thead>
      <b-tbody>
        <b-tr>
          <b-td class="text-right">Nasal</b-td>
          <b-td class="text-center">m</b-td>
          <b-td></b-td>
          <b-td colspan="2" class="text-center">n</b-td>
          <b-td></b-td>
          <b-td class="text-center">nj</b-td>
          <b-td></b-td>
          <b-td></b-td>
        </b-tr>
        <b-tr>
          <b-td class="text-right">Plosive</b-td>
          <b-td class="text-center">p</b-td>
          <b-td></b-td>
          <b-td class="text-center">t</b-td>
          <b-td></b-td>
          <b-td></b-td>
          <b-td class="text-center">tj</b-td>
          <b-td class="text-center">k</b-td>
          <b-td class="text-center">q</b-td>
        </b-tr>
        <b-tr>
          <b-td class="text-right">Fricative</b-td>
          <b-td></b-td>
          <b-td class="text-center">f</b-td>
          <b-td></b-td>
          <b-td class="text-center">s</b-td>
          <b-td class="text-center">z</b-td>
          <b-td></b-td>
          <b-td class="text-center">x</b-td>
          <b-td class="text-center">h</b-td>
        </b-tr>
        <b-tr>
          <b-td class="text-right">Affricative</b-td>
          <b-td></b-td>
          <b-td></b-td>
          <b-td></b-td>
          <b-td></b-td>
          <b-td class="text-center">tz</b-td>
          <b-td></b-td>
          <b-td></b-td>
          <b-td></b-td>
        </b-tr>
        <b-tr>
          <b-td class="text-right">Trill</b-td>
          <b-td></b-td>
          <b-td></b-td>
          <b-td></b-td>
          <b-td class="text-center">r</b-td>
          <b-td></b-td>
          <b-td></b-td>
          <b-td></b-td>
          <b-td></b-td>
        </b-tr>
        <b-tr>
          <b-td class="text-right">Lateral Approximate</b-td>
          <b-td></b-td>
          <b-td></b-td>
          <b-td></b-td>
          <b-td></b-td>
          <b-td class="text-center">l</b-td>
          <b-td class="text-center">lj</b-td>
          <b-td></b-td>
          <b-td></b-td>
        </b-tr>
      </b-tbody>
    </b-table-simple>
  </b-card-text>
</template>

<script>
export default {
  name: 'Phonology',
  components: {
  },
  computed: {
  },
  methods: {
  }
};
</script>
