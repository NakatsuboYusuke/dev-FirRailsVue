class Api::V1::EmployeesController < ApiController
  before_action :set_employee, only: [:show, :update]

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

  def update
    if @employee.update_attributes(employee_params)
      head :no_content
    else
      render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy!
    # 削除に失敗した場合、例外処理を発生させ、rescue_from Exception で拾う。
    head :no_content
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
