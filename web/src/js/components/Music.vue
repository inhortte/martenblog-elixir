'use strict';

<template>
<b-card  title="Musics -" class="overflow-hidden" no-body>
  <h4 slot="header">Music -</h4>
  <b-container>
    <b-row no-gutters>
      <b-col md="6" sm="12">
	<a href="https://flavigula.bandcamp.com" target="_blank">
	  <b-card-img src="images/flavigula-white-logo-square.png" width="300" right bottom></b-card-img>
	</a>
      </b-col>
      <b-col md="6" sm="12">
	<b-card-body>
	  <b-card-text style="margin-top: 20px; margin-bottom: 20px;">
	    <div>
	      <p>
		This space is intentionally a part of the <strong>void</strong>.<br /><br />
		Were you not compressed by the singularity, you'd visit the myriad places well suited to Flavigula listening.
	      </p>
	      <p>
		The <a href="https://flavigula.bandcamp.com" target="_blank">bandcamp page</a>.
		<br />
		The venerable <a href="https://peertracks.com/album/flavigula-a-cube-beneath-the-sand" target="_blank">Peertracks</a>.
		<br />
		El rincón de <a href="https://choon.co/artists/flavigula/" target="_blank">Choon</a>
		<br />
		Our <a href="https://open.spotify.com/artist/6hHcK3iE7Yc58gekrURJez" target="_blank">lucrative Spotify</a> home.
		<br />
		A humble <a href="https://www.deezer.com/en/artist/64909162" target="_blank">hovel on Deezer</a>.
	      </p>
	    </div>
	  </b-card-text>
	</b-card-body>
      </b-col>
    </b-row>
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
