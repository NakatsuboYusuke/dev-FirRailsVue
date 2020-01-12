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
  # namespece で指定のパスを設定
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
        <tr v-for="e in employees" :key="e.id">
          <td>{{ e.id }}</td>
          <td>{{ e.name }}</td>
          <td>{{ e.birth }}</td>
          <td>{{ e.department }}</td>
          <td>{{ e.gender }}</td>
          <td>{{ e.joined_date }}</td>
          <td>{{ e.payment }}</td>
          <td>{{ e.note }}</td>
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
      employees: []
    }
  },
  mounted () {
    axios
      .get('/api/v1/employees.json')
      .then(response => (this.employees = response.data))
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
        <tr v-for="e in employees" :key="e.id">
          <td>{{ e.id }}</td>
          <td>{{ e.name }}</td>
          <td>{{ e.department }}</td>
          <td>{{ e.gender }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

# app/controllers/api/v1/employees_controller.rb
def index
  employees = Employee.select(:id, :name, :department, :gender)
  render json: employees
end
```
