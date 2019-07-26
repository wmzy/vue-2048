<template>
  <transition-group tag="div" :class="s.container" :leave-active-class="s.leave">
    <div
     v-for="n in numbers"
     :key="n.key"
     :k="n.key"
     :value="n.value"
     :x="n.x"
     :y="n.y"
     :class="s.numbers"
    >{{ n.value }}</div>
  </transition-group>
</template>

<script>
import _ from 'lodash';

const size = 5;
const moveTime = 1 * 1000;
const doubleTime = 0.5 * 1000;

function delay(delayTime = 0) {
  return new Promise(res => setTimeout(res, delayTime));
}

export default {
  name: 'Grid2048',
  data() {
    return {
      numbers: [],
    };
  },
  mounted() {
    this.addNumber();
    this.addNumber();
    delay(doubleTime).then(() => window.addEventListener('keydown', this.move));
  },
  methods: {
    async move({ key }) {
      const keys = ['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown'];
      if (!keys.includes(key)) return;

      window.removeEventListener('keydown', this.move);

      const axis = keys.slice(2).includes(key) ? ['x', 'y'] : ['y', 'x'];
      const direction = keys.indexOf(key) % 2 ? -1 : 1;
      const numberGroups = _.groupBy(this.numbers, axis[0]);
      const removeSet = new Set();
      const doubleSet = new Set();
      let hasMoved = false;
      const limit = direction > 0 ? 0 : size - 1;
      _.forEach(numberGroups, (numbers) => {
        const sortedNumbers = _.sortBy(numbers, n => n[axis[1]] * direction);
        if (sortedNumbers[0][axis[1]] !== limit) {
          hasMoved = true;
          sortedNumbers[0][axis[1]] = limit;
        }
        // eslint-disable-next-line no-plusplus
        for (let i = 1; i < sortedNumbers.length; i++) {
          const n = sortedNumbers[i];
          const n1 = sortedNumbers[i - 1];
          if (n.value === n1.value && !removeSet.has(n1)) {
            n[axis[1]] = n1[axis[1]];
            removeSet.add(n);
            doubleSet.add(n1);
          } else if (n[axis[1]] !== n1[axis[1]] + 1 * direction) {
            hasMoved = true;
            n[axis[1]] = n1[axis[1]] + 1 * direction;
          }
        }
      });

      if (!hasMoved && !removeSet.size) {
        window.addEventListener('keydown', this.move);
        return;
      }

      await delay(moveTime);
      if (removeSet.size) {
        this.numbers = this.numbers.filter(n => !removeSet.has(n));
        // eslint-disable-next-line no-param-reassign, no-return-assign
        doubleSet.forEach(n => (n.value *= 2));
      }
      this.addNumber();
      await delay(doubleTime);
      if (this.canMove()) window.addEventListener('keydown', this.move);
      else console.log('game over');
    },
    addNumber() {
      let points = _.range(size * size);
      this.numbers.forEach((n) => { points[n.x * size + n.y] = true; });
      points = points.filter(p => p !== true);
      const point = points[_.random(points.length - 1)];
      const y = point % size;
      const x = (point - y) / size;
      this.numbers.push({
        x, y, value: 2, key: _.uniqueId(),
      });
    },
    canMove() {
      if (this.numbers.length < size * size) return true;
      const points = new Array(size * size);
      return !!this.numbers.find(({ x, y, value }) => {
        if ([
          points[(x - 1) * size + y],
          points[(x + 1) * size + y],
          points[x * size + y - 1],
          points[x * size + y + 1],
        ].includes(value)) return true;

        points[x * size + y] = value;
        return false;
      });
    },
  },
};
</script>

<style module="s" lang="scss">
  .leave {
    display: none;
  }

.container {
  width: 40rem;
  height: 40rem;
  position: relative;
  border: 1px solid black;
  color: white;
  font-weight: bolder;
  font-size: 2rem;

  $size: 8rem;

  @keyframes fadeIn {
    0% {
      transform: scale(0);
      opacity: 0;
    }
    100% {
      transform: scale(1);
      opacity: 1;
    }
  }

  .numbers {
    position: absolute;
    transition: 1s top, 1s left, 0.5s background-color;
    width: $size;
    height: $size;
    animation: fadeIn 0.5s;
    line-height: $size;
    padding: 0.2rem;
    box-sizing: border-box;
    background-clip: content-box;

    $colors:
      2 yellow, 4 green, 8 blue, 16 yellowgreen, 32 orange,
      64 red, 128 red, 516 red, 1028 red, 2048 red;

    @each $number, $color in $colors {
      &[value="#{$number}"] {
        background-color: $color;
      }
    }

    @for $i from 0 to 5 {
      &[x="#{$i}"] {
        left: $i * $size
      }
      &[y="#{$i}"] {
        top: $i * $size
      }
    }
  }
}
</style>
