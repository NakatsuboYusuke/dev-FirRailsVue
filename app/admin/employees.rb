ActiveAdmin.register Employee do
  permit_params :name, :department, :gender, :birth, :joined_date, :payment, :note
end
