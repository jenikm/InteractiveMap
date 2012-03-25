require File.dirname(__FILE__) + '/../test_helper'

class OrderItemTrackingNumbersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:order_item_tracking_numbers)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_order_item_tracking_number
    assert_difference('OrderItemTrackingNumber.count') do
      post :create, :order_item_tracking_number => { }
    end

    assert_redirected_to order_item_tracking_number_path(assigns(:order_item_tracking_number))
  end

  def test_should_show_order_item_tracking_number
    get :show, :id => order_item_tracking_numbers(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => order_item_tracking_numbers(:one).id
    assert_response :success
  end

  def test_should_update_order_item_tracking_number
    put :update, :id => order_item_tracking_numbers(:one).id, :order_item_tracking_number => { }
    assert_redirected_to order_item_tracking_number_path(assigns(:order_item_tracking_number))
  end

  def test_should_destroy_order_item_tracking_number
    assert_difference('OrderItemTrackingNumber.count', -1) do
      delete :destroy, :id => order_item_tracking_numbers(:one).id
    end

    assert_redirected_to order_item_tracking_numbers_path
  end
end
