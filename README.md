# README
This Repository is for study Vue.js + Ruby on Rails<br>
<br>
Referenced by<br>
https://bit.ly/2R71Dg4

- Frontend Vue.js
- Backend Ruby on Rails

## 環境
- Ruby 2.6.5
- Ruby on Rails 5.2.3
- Vue.js 2.6.11

## Rails と Vue.js をインストール

```
$ rails _5.2.3_ new dev-rails -d postgresql --webpack=vue
```

## Model を作成

```
$ rails g model employee name:string department:string gender:integer birth:date joined_date:date payment:bigint note:text
```

## ActiveAdmin をインストール

```
# Gemfile
gem 'activeadmin'

$ rails g active_admin:install --skip-users
$ rails db:create db:migrate
```

## Modelにバリデーションを設定

```
# app/models/employee.rb
class Employee < ApplicationRecord
  GENDERS = { other: 0, male: 1, female: 2 }
  enum gender: GENDERS

  validates :gender, inclusion: { in: GENDERS.keys.concat(GENDERS.keys.map(&:to_s)) }, exclusion: { in: [nil] }
  validates :name, exclusion: { in: [nil, ""] }
  validates :department, exclusion: { in: [nil] }
  validates :payment, numericality: true, exclusion: { in: [nil] }
  validates :note, exclusion: { in: [nil] }
end
```

## Model を ActiveAdmin から操作できるようにする

```
$ rails generate active_admin:resource Employee

# app/admin/employees.rb
ActiveAdmin.register Employee do
  permit_params :name, :department, :gender, :birth, :joined_date, :payment, :note
end
```

## API を作成

```
# app/controllers/api_controller.rb
class ApiController < ActionController::API
end

# app/controllers/api/v1/employees_controller.rb
class Api::V1::EmployeesController < ApiController
  before_action :set_employee, only: [:show]

  # rescue_from ActiveRecord::RecordNotFound do |exception|
    # render json: { error: '404 not found' }, status: 404
  # end

  def index
    employees = Employee.all
    render json: employees
  end

  def show
    render json: @employee
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end
end

# config/routes.rb
Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  # namespece でパスを指定
  namespace :api, { format: 'json' } do
    namespace :v1 do
      resources :employees, only: [:index, :show]
    end
  end
end
```

## Active_admin でユーザーを作成
以下のアドレスで、JSONが返ってきているか確認する

```
http://localhost:3000/api/v1/employees/
http://localhost:3000/api/v1/employees/1
```

## homes コントローラを作成

```
$ rails g controller homes index

# config/routes.rb
resources :homes, only: [:index]
root to: 'homes#index'
```

## Vue.js のタグを記述。"Hello, Vue!"を表示

```
# app/views/homes/index.html.erb
<%= javascript_pack_tag 'hello_vue' %>
<%= stylesheet_pack_tag 'hello_vue' %>

# =>
<div data-v-6fb8108a="" id="app">
  <p data-v-6fb8108a="">Hello Vue!</p>
</div>
```

## フロントエンドとバックエンドを連携

### axios をインストール

```
$ yarn add axios
```

### app.vue ファイルを書き換えJSONを出力

```
# app/javascript/app.vue

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
        <tr v-for="list in employees" :key="list.id">
          <td>{{ list.id }}</td>
          <td>{{ list.name }}</td>
          <td>{{ list.birth }}</td>
          <td>{{ list.department }}</td>
          <td>{{ list.gender }}</td>
          <td>{{ list.joined_date }}</td>
          <td>{{ list.payment }}</td>
          <td>{{ list.note }}</td>
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
```

## アプリケーションをカスタマイズ

```
# app/javascript/app.vue

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
          <td>{{ item.id }}</td>
          <td>{{ item.name }}</td>
          <td>{{ item.department }}</td>
          <td>{{ item.gender }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

# app/javascript/EmployeeIndexPage.vue
def index
  employees = Employee.select(:id, :name, :department, :gender)
  render json: employees
end
```

## 一覧画面から詳細画面へ遷移

### vue-router をインストール

```
$ yarn add vue-router
```

### EmployeeIndexPage.vue を作成し、app.vue の内容をコピー

```
# app/javascript/EmployeeIndexPage.vue
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
          <td>{{ item.id }}</td>
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
```

### EmployeeIndexPage.vue を作成

```
# app/javascript/EmployeeDetailPage.vue
<template>
  <dl>
    <dt>ID</dt>
    <dd>{{ employee.id }}</dd>
    <dt>Name</dt>
    <dd>{{ employee.name }}</dd>
    <dt>Department</dt>
    <dd>{{ employee.department }}</dd>
    <dt>Gender</dt>
    <dd>{{ employee.gender }}</dd>
    <dt>Birth</dt>
    <dd>{{ employee.birth }}</dd>
    <dt>Joined Date</dt>
    <dd>{{ employee.joined_date }}</dd>
    <dt>Payment</dt>
    <dd>{{ employee.payment }}</dd>
    <dt>Note</dt>
    <dd>{{ employee.note }}</dd>
  </dl>
</template>

<script>
import axios from 'axios';

export default {
  data: function () {
    return {
      employee: {}
    }
  },
  mounted () {
    axios
      .get(`/api/v1/employees/${this.$route.params.id}.json`)
      .then(response => (this.employee = response.data))
  }
}
</script>

<style scoped>
</style>
```

### app.vue にルーティングを記述

```
# app/javascript/app.vue
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
// ルーティングを設定
const router = new VueRouter({
  routes: [
    {
      path: '/',
      component: EmployeeIndexPage
    },
    // :id は数値のみに制限する
    {
      path: '/employees/:id(\\d+)',
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
```

### ルーティングの確認
以下のアドレスで、レスポンスが返ってきているか確認する

```
http://localhost:3000/#/
http://localhost:3000/#/employees/1
```

### リンクを追加

```
# app/javascript/app.vue
:<snip>
{
  path: '/employees/:id(\\d+)',
  name: 'EmployeeDetailPage',
  component: EmployeeDetailPage
}
:<snip>

# app/javascript/EmployeeIndexPage.vue
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
:<snip>
```

## 新規作成ページを作成

```
# app/javascript/EmployeeNewPage.vue
// .prevent 修飾子で、通常の submitで処理されるページ遷移をキャンセルする。
<template>
  <form v-on:submit.prevent="createEmployee">
    <div v-if="errors.length != 0">
      <ul v-for="item in errors" :key="item">
        <li><font color="red">{{ item }}</font></li>
      </ul>
    </div>
    <div>
      <label>Name</label>
      <input v-model="employee.name" type="text">
    </div>
    <div>
      <label>Department</label>
      <input v-model="employee.department" type="text">
    </div>
    <div>
      <label>Gender</label>
      <select v-model="employee.gender">
        <option>other</option>
        <option>male</option>
        <option>female</option>
      </select>
    </div>
    <div>
      <label>Birth</label>
      <input v-model="employee.birth" type="date">
    </div>
    <div>
      <label>Joined Date</label>
      <input v-model="employee.joined_date" type="date">
    </div>
    <div>
      <label>Payment</label>
      <input v-model="employee.payment" type="number" min="0">
    </div>
    <div>
      <label>Note</label>
      <input v-model="employee.note" type="text">
    </div>
    <button type="submit">Commit</button>
  </form>
</template>

<script>
import axios from 'axios';

export default {
  data: function () {
    return {
      employee: {
        name: '',
        department: '',
        gender: '',
        birth: '',
        joined_date: '',
        payment: '',
        note: ''
      },
      errors: ''
    }
  },
  methods: {
    createEmployee: function() {
      axios
        .post('/api/v1/employees', this.employee)
        .then(response => {
          let event = response.data;
          this.$router.push({ name: 'EmployeeDetailPage', params: { id: event.id } });
        })
        .catch(error => {
          console.error(error);
          if (error.response.data && error.response.data.errors) {
            this.errors = error.response.data.errors;
          }
        });
    }
  }
}
</script>

<style scoped>
</style>

```

### ルーティングを追加

```
# app/javascript/app.vue
:<snip>
import Vue from 'vue'
import VueRouter from 'vue-router'

import EmployeeIndexPage from 'EmployeeIndexPage.vue'
import EmployeeDetailPage from 'EmployeeDetailPage.vue'
import EmployeeNewPage from 'EmployeeNewPage.vue'

const router = new VueRouter({
  routes: [
    {
      path: '/',
      component: EmployeeIndexPage
    },
    {
      path: '/employees/:id(\\d+)',
      name: 'EmployeeDetailPage',
      component: EmployeeDetailPage
    },
    {
      path: '/employees/new',
      name: 'EmployeeNewPage',
      component: EmployeeNewPage
    }
  ]
})
:<snip>
```

### ルーティングの確認
以下のアドレスで、レスポンスが返ってきているか確認する

```
http://localhost:3000/#/employees/new
```

### ルーティングにcreateアクションを追加

```
# config/routes.rb
:<snip>
namespace :api, { format: 'json' } do
  namespace :v1 do
    resources :employees, only: [:index, :show, :create]
  end
end
:<snip>
```

### コントローラにcreateアクションを追加

```
# app/controllers/api/v1/employees_controller.rb
class Api::V1::EmployeesController < ApiController
  before_action :set_employee, only: [:show]

  rescue_from Exception, with: :render_status_500

  rescue_from ActiveRecord::RecordNotFound, with: :render_status_404

  def index
    employees = Employee.select(:id, :name, :department, :gender)
    render json: employees
  end

  def show
    render json: @employee
  end

  def create
    employee = Employee.new(employee_params)
    if employee.save
      render json: employee, status: :created
    else
      render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.fetch(:employee, {}).permit(:name, :department, :gender, :birth, :joined_date, :payment, :note)
  end

  def render_status_404(exception)
    render json: { errors: [exception] }, status: 404
  end

  def render_status_500(exception)
    render json: { errors: [exception] }, status: 500
  end
end
```

## 編集ページを作成

### フォーム部分をコンポーネント化する

- v-on:submit.prevent="$emit('submit')" で submitイベントを発行し、<employee-form-pane v-on:submit="createEmployee"></employee-form-pane> で submitイベントを受け取り
createEmployee メソッドを実行する。

- props では親コンポーネントから受け取れる値を設定する。

```
# app/javascript/EmployeeFormPane.vue
<template>
  <form v-on:submit.prevent="$emit('submit')">
    <div v-if="errors.length != 0">
      <ul v-for="item in errors" :key="item">
        <li><font color="red">{{ item }}</font></li>
      </ul>
    </div>
    <div>
      <label>Name</label>
      <input v-model="employee.name" type="text">
    </div>
    <div>
      <label>Department</label>
      <input v-model="employee.department" type="text">
    </div>
    <div>
      <label>Gender</label>
      <select v-model="employee.gender">
        <option>other</option>
        <option>male</option>
        <option>female</option>
      </select>
    </div>
    <div>
      <label>Birth</label>
      <input v-model="employee.birth" type="date">
    </div>
    <div>
      <label>Joined Date</label>
      <input v-model="employee.joined_date" type="date">
    </div>
    <div>
      <label>Payment</label>
      <input v-model="employee.payment" type="number" min="0">
    </div>
    <div>
      <label>Note</label>
      <input v-model="employee.note" type="text">
    </div>
    <button type="submit">Commit</button>
  </form>
</template>

<script>
export default {
  props: {
    employee: {},
    errors: ''
  }
}
</script>

<style>
</style>
```

```
# app/javascript/EmployeeNewPage.vue
<template>
  <employee-form-pane :errors="errors" :employee="employee" v-on:submit="createEmployee"></employee-form-pane>
</template>

<script>
import axios from 'axios';
import EmployeeFormPane from 'EmployeeFormPane.vue';

export default {
  components: {
    EmployeeFormPane
  },
  data() {
    return {
      employee: {
        name: '',
        department: '',
        gender: '',
        birth: '',
        joined_date: '',
        payment: '',
        note: ''
      },
      errors: ''
    }
  },
  methods: {
    createEmployee: function() {
      axios
        .post('/api/v1/employees', this.employee)
        .then(response => {
          let event = response.data;
          this.$router.push({ name: 'EmployeeDetailPage', params: { id: event.id } });
        })
        .catch(error => {
          console.error(error);
          if (error.response.data && error.response.data.errors) {
            this.errors = error.response.data.errors;
          }
        });
    }
  }
}
</script>

<style scoped>
</style>
```

### 編集画面を作成

```
# EmployeeEditPage.vue
<template>
  <employee-form-pane :errors="errors" :employee="employee" @submit="updateEmployee"></employee-form-pane>
</template>

<script>
import axios from 'axios';
import EmployeeFormPane from 'EmployeeFormPane.vue';

export default {
  components: {
    EmployeeFormPane
  },
  data() {
    return {
      employee: {},
      errors: ''
    }
  },
  mounted() {
    axios
      .get(`/api/v1/employees/${this.$route.params.id}.json`)
      .then(response => (this.employee = response.data))
  },
  methods: {
    updateEmployee: function() {
      axios
        .patch(`/api/v1/employees/${this.employee.id}`, this.employee)
        .then(response => {
          this.$router.push({ name: 'EmployeeDetailPage', params: { id: this.employee.id } });
        })
        .catch(error => {
          console.error(error);
          if (error.response.data && error.response.data.errors) {
            this.errors = error.response.data.errors;
          }
        });
    }
  }
}
</script>

<style scoped>
</style>
```

### ルーティングを作成

```
#
:<snip>
import Vue from 'vue'
import VueRouter from 'vue-router'

import EmployeeIndexPage from 'EmployeeIndexPage.vue'
import EmployeeDetailPage from 'EmployeeDetailPage.vue'
import EmployeeNewPage from 'EmployeeNewPage.vue'
import EmployeeEditPage from 'EmployeeEditPage.vue'

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
    },
    {
      path: '/employees/new',
      name: 'EmployeeNewPage',
      component: EmployeeNewPage
    },
    {
      path: '/employees/:id(\\d+)/edit',
      name: 'EmployeeEditPage',
      component: EmployeeEditPage
    }
  ]
})
:<:snip>
```

### ルーティングの確認
以下のアドレスで、レスポンスが返ってきているか確認する

```
http://localhost:3000/#/employees/1/edit
```

### ルーティングにupdateアクションを追加

```
# config/routes.rb
:<snip>
namespace :api, { format: 'json' } do
  namespace :v1 do
    resources :employees, only: [:index, :show, :create, :update]
  end
end
:<snip>
```

### コントローラにupdateアクションを追加

```
# app/controllers/api/v1/employees_controller.rb
class Api::V1::EmployeesController < ApiController
  before_action :set_employee, only: [:show, :update]

:<snip>
  def update
    if @employee.update_attributes(employee_params)
    head :no_content
    else
      render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
    end
  end
:<snip>
end
```
