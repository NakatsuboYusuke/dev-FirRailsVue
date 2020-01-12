# README
This Repository is for study Vue.js + Ruby on Rails
Referenced by
https://qiita.com/tatsurou313/items/4f18c0d4d231e2fb55f4

# 環境
- Ruby 2.6.5
- Ruby on Rails 5.2.3

## Rails と Vue.js をインストール

```
$ rails _5.2.3_ new dev-rails -d postgresql --webpack=vue
$ rails db:create
$ rails s
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

## Model を ActiveAdmin から操作できるようにする

```
$ rails generate active_admin:resource Employee

# app/admin/employees.rb
ActiveAdmin.register Employee do
  permit_params :name, :department, :gender, :birth, :joined_date, :payment, :note
end
```
