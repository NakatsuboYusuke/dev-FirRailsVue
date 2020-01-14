<template>
  <div id="app">
    <table>
      <tbody>
        <tr>
          <th>ID</th>
          <th>name</th>
          <th>birth</th>
          <th>department</th>
          <th>gender</th>
          <th>joined_date</th>
          <th>payment</th>
          <th>note</th>
        </tr>
        <tr v-for="item in list" :key="item.id">
          <td>{{ item.id }}</td>
          <td>{{ item.name }}</td>
          <td>{{ item.birth }}</td>
          <td>{{ item.department }}</td>
          <td>{{ item.gender }}</td>
          <td>{{ item.joined_date }}</td>
          <td>{{ item.payment }}</td>
          <td>{{ item.note }}</td>
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
