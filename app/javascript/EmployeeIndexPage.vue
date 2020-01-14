<template>
  <div id="app">
    <table>
      <tbody>
        <tr>
          <th>ID</th>
          <th>name</th>
          <th>department</th>
          <th>gender</th>
          <th>actions</th>
        </tr>
        <tr v-for="item in list" :key="item.id">
          <td>
            <router-link :to="{ name: 'EmployeeDetailPage', params: { id: item.id } }">{{ item.id }}</router-link>
          </td>
          <td>{{ item.name }}</td>
          <td>{{ item.department }}</td>
          <td>{{ item.gender }}</td>
          <td>
            <button v-on:click="deleteTarget = item.id; showModal = true">Delete</button>
          </td>
        </tr>
      </tbody>
      <modal v-if="showModal" v-on:cancel="showModal = false" v-on:ok="deleteEmployee(); showModal = false;">
        <div slot="body">Are you sure?</div>
      </modal>
    </table>
  </div>
</template>

<script>
import axios from 'axios';
import Modal from 'Modal.vue'

export default {
  components: {
    Modal
  },
  data: function () {
    return {
      list: [],
      showModal: false,
      deleteTarget: -1,
      errors: ''
    }
  },
  mounted () {
    this.updateEmployees();
  },
  methods: {
    deleteEmployee: function() {
      if (this.deleteTarget <= 0) {
        console.warn('deleteTarget should be grater than zero.');
        return;
      }

    axios
      .delete(`/api/v1/employees/${this.deleteTarget}`)
      .then(response => {
        this.deleteTarget = -1;
        this.updateEmployees();
      })
      .catch(error => {
        console.error(error);
        if (error.response.data && error.response.data.errors) {
          this.errors = error.response.data.errors;
        }
      });
    },
    updateEmployees: function() {
      axios
        .get('/api/v1/employees.json')
        .then(response => (this.list = response.data))
    }
  }
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
