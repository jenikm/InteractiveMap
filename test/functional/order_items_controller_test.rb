require File.dirname(__FILE__) + '/../test_helper'

class OrderItemsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:order_items)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_order_item
    assert_difference('OrderItem.count') do
      post :create, :order_item => { }
    end

    assert_redirected_to order_item_path(assigns(:order_item))
  end

  def test_should_show_order_item
    get :show, :id => order_items(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => order_items(:one).id
    assert_response :success
  end

  def test_should_update_order_item
    put :update, :id => order_items(:one).id, :order_item => { }
    assert_redirected_to order_item_path(assigns(:order_item))
  end

  def test_should_destroy_order_item
    assert_difference('OrderItem.count', -1) do
      delete :destroy, :id => order_items(:one).id
    end

    assert_redirected_to order_items_path
  end
end
