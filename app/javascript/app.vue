<template>
  <div id="app">
    <div v-for="list in lists" class="list">
      <template v-if="list.in_edit">
        <input type="text" class="form-control" v-model="list.name" @blur="postList(list)">
      </template>
      <div v-else class="name" @click="editList(list)">
        {{ list.name }}
      </div>
    </div>
    <div class="list">
      <button class="btn btn-primary" @click="createList()">＋もう1つリストを追加</button>
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
    fetch('/lists.json')
      .then(response => response.json())
      .then(data => this.lists = data);
  },
  methods: {
    createList() {
      this.lists.push({
        id: null,
        name: '',
        in_edit: true,
        in_sync: false,
      })
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
          list.in_sync = false;
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
  padding: 1rem;
  border: 1px solid #999999;
  border-radius: 0.5rem;
  margin-right: 1rem;

  .name {
    border: 1px solid #ffffff;
    border-radius: .25rem;
    padding: .375rem .75rem;

    &:hover {
      border: 1px solid #ced4da;
    }
  }
}
</style>
