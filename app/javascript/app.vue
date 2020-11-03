<template>
  <div id="app">
    <div
      v-for="list in lists"
      class="list"
      :id="`list-${list.id}`"
      @dragover.prevent
      @drop="dropOnList($event, list)"
    >
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
      <div
        v-for="card in list.cards"
        class="card" :id="`card-${card.id}`"
        :draggable="canDragCard(card) ? true : false"
        @dragstart="dragStartCard($event, card)"
      >
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
      <button class="btn btn-primary" @click="newList">＋リストを追加</button>
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
        list_id: list.id,
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
    canDragCard(card) {
      return !card.in_edit && card.id
    },
    dragStartCard(event, card) {
      // DOMString しか渡せないので JSON にしている
      event.dataTransfer.setData('application/trello-rails-card', JSON.stringify(card));
      event.dataTransfer.effectAllowed = 'move';
    },
    dropOnList(event, targetList) {
      const sourceCard = JSON.parse(event.dataTransfer.getData('application/trello-rails-card'));
      sourceCard.in_sync = true;

      const sourceList = this.lists.find(l => l.id == sourceCard.list_id);
      sourceList.cards = sourceList.cards.filter(c => c.id != sourceCard.id);
      targetList.cards.push(Object.assign(sourceCard, { list_id: targetList.id }));

      fetch(`/cards/${sourceCard.id}.json`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ card: { list_id: targetList.id } })
      })
        .then(response => response.json())
        .then(_ => sourceCard.in_sync = false);
    }
  }
}
</script>

<style lang="scss" scoped>
#app {
  white-space: nowrap;
  height: 90%;
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
    top: .25rem;
    right: .25rem;
  }

  .name {
    margin-bottom: 1rem;
    font-weight: bold;

    input {
      font-weight: bold;
    }

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

[draggable] {
  cursor: grab;
}
</style>
