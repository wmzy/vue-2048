<template>
  <div id="app">
    <the-game />
  </div>
</template>

<script>
import TheGame from './components/Game.vue';

export default {
  name: 'app',
  components: {
    TheGame,
  },
};
</script>

<style lang="scss">
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
</style>
