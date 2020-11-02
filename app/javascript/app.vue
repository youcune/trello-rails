<template>
  <div id="app">
    <div v-for="list in lists" class="list">
      <div class="status">
        <i class="fas fa-sync fa-spin" v-if="list.in_sync"></i>
      </div>
      <div class="name">
        <template v-if="list.in_edit">
          <input type="text" class="form-control" v-model="list.name" @blur="postList(list)">
        </template>
        <div v-else @click="editList(list)">
          {{ list.name }}
        </div>
      </div>
      <div v-for="card in list.cards" class="card">
        <div class="status">
          <i class="fas fa-sync fa-spin" v-if="card.in_sync"></i>
        </div>
        <template v-if="card.in_edit">
          <input type="text" class="form-control" v-model="card.name" @blur="postCard(card, list.id)">
        </template>
        <div v-else @click="editCard(card)">
          {{ card.name }}
        </div>
      </div>
      <button class="btn btn-primary" @click="newCardTo(list)">＋カードを追加</button>
    </div>
    <div class="list">
      <button class="btn btn-primary" @click="newList()">＋リストを追加</button>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      lists: [],
      editing: null
    }
  },
  mounted() {
    this.indexList();
  },
  methods: {
    newList() {
      this.lists.push({
        id: null,
        name: '',
        cards: [],
        in_edit: true,
        in_sync: false,
      });
    },
    indexList() {
      fetch('/lists.json')
        .then(response => response.json())
        .then(data => {
          this.lists = data.map(l => Object.assign(l, { cards: l.cards.map(c => Object.assign(c, { in_edit: false, in_sync: false })), in_edit: false, in_sync: false }))
        });
    },
    editList(list) {
      list.in_edit = true;
    },
    postList(list) {
      list.in_edit = false;
      list.in_sync = true;

      fetch('/lists.json', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ id: list.id, list: { name: list.name } })
      })
        .then(response => response.json())
        .then(data => {
          list.id = data.id;
          list.in_sync = false;
        });
    },
    newCardTo(list) {
      list.cards.push({
        id: null,
        name: '',
        in_edit: true,
        in_sync: false,
      });
    },
    editCard(card) {
      card.in_edit = true;
    },
    postCard(card, list_id) {
      card.in_edit = false;
      card.in_sync = true;

      fetch('/cards.json', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ id: card.id, card: { list_id, name: card.name } })
      })
        .then(response => response.json())
        .then(data => {
          card.id = data.id;
          card.in_sync = false;
        });
    },
  }
}
</script>

<style lang="scss" scoped>
#app {
  white-space: nowrap;
  overflow: scroll;
}
.list {
  width: 240px;
  display: inline-block;
  vertical-align: top;
  padding: 1rem;
  border: 1px solid #999999;
  border-radius: 0.5rem;
  margin-right: 1rem;
  position: relative;

  .status {
    position: absolute;
    top: 0;
    right: 0;
  }

  .name {
    margin-bottom: 1rem;

    div {
      border: 1px solid #ffffff;
      border-radius: .25rem;
      padding: .375rem .75rem;

      &:hover {
        border: 1px solid #ced4da;
      }
    }
  }

  .card {
    margin-bottom: 1rem;
    padding: 0.5rem;
  }
}
</style>
