'use strict';

<template>
  <b-card-text style="margin-top: 20px; margin-bottom: 20px; margin-left: 20px;">
    <p>
      Lakife uses the
      <a target="_blank" href="https://en.wikipedia.org/wiki/Ergative%E2%80%93absolutive_alignment">
        Ergative-Absolutive
      </a>
      alignment. This contransts with the Subject-Object alignment that most Indo-European languages use.
      The unfamiliar can click the link to be enlightened.<br />
      That being stated, the ergative marker is <em>-jo</em> and is usually attached to a pronoun.
    </p>
    <p>
      <b-table-simple striped bordered responsive>
        <b-thead>
          <b-th></b-th>
          <b-th class="text-center">First Person Inclusive</b-th>
          <b-th class="text-center">First Person Exclusive</b-th>
          <b-th class="text-center">Second Person</b-th>
          <b-th class="text-center">Third Person</b-th>
        </b-thead>
        <b-tbody>
          <b-tr>
            <b-td class="text-right">Singular</b-td>
            <b-td class="text-center">et</b-td>
            <b-td class="text-center"></b-td>
            <b-td class="text-center">is</b-td>
            <b-td class="text-center">an (-ja / -ju)</b-td>
          </b-tr>
          <b-tr>
            <b-td class="text-right">Plural</b-td>
            <b-td class="text-center">solet</b-td>
            <b-td class="text-center">yz</b-td>
            <b-td class="text-center">solis</b-td>
            <b-td class="text-center">solan</b-td>
          </b-tr>
        </b-tbody>
      </b-table-simple>
    </p>
    <hr />
    <p>
      Lakife doesn't habitually use a 
      <a target="_blank" href="https://en.wikipedia.org/wiki/Zero_copula">copula</a> 
      in present tense. There are exceptions. They will not be mentioned here (yet).<br />
      <em>Kop koz liz tenu.</em> - The goat's head is white.<br />
      <em>Tetju isiz kolepuk pes lamu jetz</em> - Your father is a huge, nameless pigeon.<br />
      <em>Kototz tosin sima.</em> - The small diety is ice coloured.<br />
      <em>Jatul maru.</em> - The apple is red.<br />
      <em>An jatul kolep liz ten.</em> - It is the white pigeon's apple.<br />
      <div border-variant="secondary" style="font-size: smaller;">
        <ul>
          <li>I'm unsure of the correct way to place <em>liz</em>. Should it come after <em>kolep</em> or after <em>ten</em>?</li>
        </ul>
      </div>
    </p>
    <hr />
    <p>
      Transitive verbs require the ergative particle <em>-jo</em> to be attached to or follow the agent (subject).<br />
      <em>Keze jo qotzikaren kitap.</em> - That goat wrote a book.<br />
      <em>Anja jo kez tziplez. Nofek an qismet.</em> She kisses the goat. Then she dies.
      <div border-variant="secondary" style="font-size: smaller;">
        <ul>
          <li><em>-jo</em> marks <em>anja</em> (she) as the agent in the first sentence.</li>
          <li>The second sentence is intransitive. No agent, no <em>jo</em>.</li>
        </ul>
      </div>

    </p>
  </b-card-text>
</template>

<script>
export default {
  name: 'Pronouns',
  components: {
  },
  computed: {
  },
  methods: {
  }
};
</script>
