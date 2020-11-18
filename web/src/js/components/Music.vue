'use strict';

<template>
<b-card  title="Musics -" class="overflow-hidden" no-body>
  <h4 slot="header">Music -</h4>
  <b-container>
    <b-card-body>
      <b-row no-gutters>
        <b-col md="4" sm="12" style="padding-right: 146px;">
          <a href="https://flavigula.bandcamp.com" target="_blank">
            <b-card-img src="images/flavigula-white-logo-square.png" width="200" height="200" top center></b-card-img>
          </a>
          <a href="https://submarinebroadcastingco.bandcamp.com/album/j-maraz">
            <b-card-img src="images/jemaraz.png"  width="200" bottom center></b-card-img>
          </a>
        </b-col>
        <b-col md="8" sm="12">
          <b-card-text style="margin-top: 20px; margin-bottom: 20px; margin-left: 20px;">
            <div>
              <p>
                This space is intentionally a part of the <strong>void</strong>.<br /><br />

                Now that the credo of this site has been stated, I'll mention that our new album
                <a href="https://submarinebroadcastingco.bandcamp.com/album/j-maraz">Jēmaraz</a> 
                was released by the 
                <a href="https://submarinebroadcastingco.bandcamp.com/">Submarine Broadcasting Company</a> 
                on 15 September. It's a delicate balance between weirdness and psychedelia, or so I am told. 
                One can also hear it on 
                <a href="https://funkwhale.thurk.org">Funkwhale</a> 
                <a href="https://funkwhale.thurk.org/library/albums/21/">here</a>.
                <br /><br /><hr />

                Were you not compressed by the singularity, you'd visit the myriad places well suited to Flavigula listening, some of which are listed below.
              </p>
              <p>
                Firstly, our <a href="https://flavigula.bandcamp.com" target="_blank">bandcamp page</a>.
                <br />
                Secondly, the <a href="https://funkwhale.thurk.org">thurk.org funkwhale</a> is brimming with both current and antique Flavigula. These include <a href="https://funkwhale.thurk.org/library/albums/13/">Omnivorous Expanse</a>, a project with Tim Rowe, and <a href="https://funkwhale.thurk.org/library/albums/7/">Bricked-up Cupboard</a>, a collection of tunes that may or not be refined for future "release".
                <br />
                Speaking of Tim Rowe, his music can be found <a href="https://timrowe.bandcamp.com/">aquí on bandcamp.</a> 
                <br />
                And Kris Boudreau, who contributes electric bass guitar to our recent recordings, has a number of fantastic atmospheric releases <a href="https://kynduum.bandcamp.com">here</a>.
                <br />
                Furthermore -<br />
                Upon the venerable <a href="https://audius.co/flavigula" target="_blank">Audius</a> floats Flavigula albums.
                <br />
                Our <a href="https://open.spotify.com/artist/6hHcK3iE7Yc58gekrURJez" target="_blank">lucrative Spotify</a> home is aching for a few streams.
                <br />
                The humble <a href="https://www.deezer.com/en/artist/64909162" target="_blank">hovel that is Deezer</a> pines equally.
              </p>
            </div>
          </b-card-text>
        </b-col>
      </b-row>
    </b-card-body>
  </b-container>
</b-card>
</template>

<script>
export default {
  name: 'music',
  data: {
    cardStyle: {
      padding: '20px'
    }
  }
}
</script>
