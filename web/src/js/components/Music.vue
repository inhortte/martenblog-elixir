'use strict';

<template>
<b-card  title="Musics -" class="overflow-hidden" no-body>
  <h4 slot="header">Music -</h4>
  <b-container>
    <b-card-body>
      <b-row no-gutters>
        <b-col md="4" sm="12" style="padding-right: 146px;">
          <a href="https://flavigula.bandcamp.com" target="_blank">
            <b-card-img src="images/flavigula-white-logo-square.png" width="200" height="200" top left></b-card-img>
          </a>
          <a href="https://flavigula.bandcamp.com/album/ll">
            <b-card-img src="images/allai.jpg" height="200" width="200" bottom left></b-card-img>
          </a>
        </b-col>
        <b-col md="8" sm="12">
          <b-card-text style="margin-top: 20px; margin-bottom: 20px; margin-left: 20px;">
            <div>
              <p>
                This space is intentionally a part of the <strong>void</strong>.<br /><br />
                That being said, our new album <a href="https://flavigula.bandcamp.com/album/ll">Älläï</a>, as of 16 December, has been released. Please give it a listen!<br /><br />
                Were you not compressed by the singularity, you'd visit the myriad places well suited to Flavigula listening.
              </p>
              <p>
                The <a href="https://flavigula.bandcamp.com" target="_blank">bandcamp page</a>.
                <br />
                The venerable <a href="https://audius.co/flavigula" target="_blank">Audius</a>.
                <br />
                El rincón de <a href="https://choon.co/artists/flavigula/" target="_blank">Choon</a>
                <br />
                Our <a href="https://open.spotify.com/artist/6hHcK3iE7Yc58gekrURJez" target="_blank">lucrative Spotify</a> home.
                <br />
                A humble <a href="https://www.deezer.com/en/artist/64909162" target="_blank">hovel on Deezer</a>.
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
