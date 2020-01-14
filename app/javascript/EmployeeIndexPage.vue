<template>
  <div id="app">
    <table>
      <tbody>
        <tr>
          <th>ID</th>
          <th>name</th>
          <th>department</th>
          <th>gender</th>
        </tr>
        <tr v-for="item in list" :key="item.id">
          <td>
            <router-link :to="{ name: 'EmployeeDetailPage', params: { id: item.id } }">{{ item.id }}</router-link>
          </td>
          <td>{{ item.name }}</td>
          <td>{{ item.department }}</td>
          <td>{{ item.gender }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data: function () {
    return {
      list: []
    }
  },
  mounted () {
    axios
      .get('/api/v1/employees.json')
      .then(response => (this.list = response.data))
  }
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
