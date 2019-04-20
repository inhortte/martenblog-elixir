'use strict';

<template>
<b-jumbotron>
  <h1>Flavigula</h1>
  <p>Here likes Martes Flavigula, eternally beneath the splintered earth.</p>
  <hr class="my-4" />
  <p><router-link to="/blog/1">blog</router-link> | <router-link to="/music">music</router-link> | <router-link to="/poems">poems</router-link></p>
</b-jumbotron>
</template>


<script>
export default {
  name: 'cabeza'
}
</script>
