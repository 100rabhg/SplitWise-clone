# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[edit update show destroy]
  before_action :authorize_owner!, only: %i[edit update destroy]

  def new
    load_friends
    @expense = ExpenseTransaction.new(paid_by: current_user)
  end

  def create
    @expense = ExpenseTransaction.new(expense_params.merge(paid_by: current_user))
    handle_persistence(@expense.save, :new, :create, 'created')
  end

  def edit
    load_friends
  end

  def update
    handle_persistence(@expense.update(expense_params), :edit, :update, 'updated')
  end

  def show; end

  def destroy
    @expense.destroy
    redirect_to root_path, notice: 'Expense deleted successfully.'
  end

  private

  def handle_persistence(success, error_view, error_js, action_verb)
    respond_to do |format|
      if success
        format.html { redirect_to root_path, notice: "Expense #{action_verb} successfully." }
        format.js { render js: "window.location = '#{root_path}';" }
      else
        load_friends
        format.html { render error_view }
        format.js { render error_js }
      end
    end
  end

  def load_friends
    @users = current_user.friends_with_self
  end

  def expense_params
    params.require(:expense_transaction).permit(
      :amount, :notes,
      expense_items_attributes: [
        :id, :type, :name, :amount, :_destroy,
        { item_splits_attributes: %i[id user_id friendship_id amount _destroy] }
      ]
    )
  end

  def set_expense
    @expense = ExpenseTransaction.find(params[:id])
  end

  def authorize_owner!
    return if @expense.paid_by_id == current_user.id

    redirect_to root_path,
                alert: 'You are not allowed to edit this expense.'
  end
end
