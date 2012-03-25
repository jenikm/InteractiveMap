require File.dirname(__FILE__) + '/../test_helper'

class ShipmentsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:shipments)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_shipment
    assert_difference('Shipment.count') do
      post :create, :shipment => { }
    end

    assert_redirected_to shipment_path(assigns(:shipment))
  end

  def test_should_show_shipment
    get :show, :id => shipments(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => shipments(:one).id
    assert_response :success
  end

  def test_should_update_shipment
    put :update, :id => shipments(:one).id, :shipment => { }
    assert_redirected_to shipment_path(assigns(:shipment))
  end

  def test_should_destroy_shipment
    assert_difference('Shipment.count', -1) do
      delete :destroy, :id => shipments(:one).id
    end

    assert_redirected_to shipments_path
  end
end
