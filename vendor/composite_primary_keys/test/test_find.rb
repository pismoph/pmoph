require 'abstract_unit'

# Testing the find action on composite ActiveRecords with two primary keys
class TestFind < ActiveSupport::TestCase
  fixtures :capitols, :reference_types, :reference_codes, :suburbs

  CLASSES = {
    :single => {
      :class => ReferenceType,
      :primary_keys => [:reference_type_id],
    },
    :dual   => {
      :class => ReferenceCode,
      :primary_keys => [:reference_type_id, :reference_code],
    },
    :dual_strs   => {
      :class => ReferenceCode,
      :primary_keys => ['reference_type_id', 'reference_code'],
    },
  }

  def setup
    self.class.classes = CLASSES
  end

  def test_find_first
    testing_with do
      obj = @klass.find(:first)
      assert obj
      assert_equal @klass, obj.class
    end
  end

  def test_find
    testing_with do
      found = @klass.find(*first_id) # e.g. find(1,1) or find 1,1
      assert found
      assert_equal @klass, found.class
      assert_equal found, @klass.find(found.id)
    end
  end

  def test_find_composite_ids
    testing_with do
      found = @klass.find(first_id) # e.g. find([1,1].to_composite_ids)
      assert found
      assert_equal @klass, found.class
      assert_equal found, @klass.find(found.id)
    end
  end

  def things_to_look_at
    testing_with do
      assert_equal found, @klass.find(found.id.to_s) # fails for 2+ keys
    end
  end

  def test_find_with_strings_as_composite_keys
    found = Capitol.find('The Netherlands', 'Amsterdam')
    assert found
  end

  def test_not_found
    assert_raise(::ActiveRecord::RecordNotFound) do
      ReferenceCode.find(['999', '999'])
    end
  end

  def test_find_last_suburb
    suburb = Suburb.find(:last)
    assert_equal([2,1], suburb.id)
  end

  def test_find_last_suburb_with_order
    # Rails actually changes city_id DESC to city_id ASC
    suburb = Suburb.find(:last, :order => 'suburbs.city_id DESC')
    assert_equal([1,1], suburb.id)
  end
end
