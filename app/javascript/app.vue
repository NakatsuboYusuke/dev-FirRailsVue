<template>
  <div>
    <router-view></router-view>
  </div>
</template>

<script>
import Vue from 'vue'
import VueRouter from 'vue-router'

import EmployeeIndexPage from 'EmployeeIndexPage.vue'
import EmployeeDetailPage from 'EmployeeDetailPage.vue'

// Vue componentに VueRouterのインスタンスを引数とするコンポーネントを作成
// ルーティング設定
const router = new VueRouter({
  routes: [
    {
      path: '/',
      component: EmployeeIndexPage
    },
    // :id は数値のみに制限する
    {
      path: '/employees/:id(\\d+)',
      name: 'EmployeeDetailPage',
      component: EmployeeDetailPage
    }
  ]
})

// CommonJS 環境では Vue.useを使って VueRouterを指定する
// ref. https://jp.vuejs.org/v2/guide/plugins.html#%E3%83%97%E3%83%A9%E3%82%B0%E3%82%A4%E3%83%B3%E3%81%AE%E4%BD%BF%E7%94%A8
Vue.use(VueRouter)

export default {
  router
}
</script>

<style scoped>
</style>
